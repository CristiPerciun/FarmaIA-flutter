/**
 * OpenAI-compatible chat client for the customer assistant (§12.2, ADR 0003).
 *
 * Model-agnostic by design: `LLM_BASE_URL` + `LLM_MODEL` + `LLM_API_KEY`
 * live in config/Secret Manager (`functions/.env` on the emulator), so
 * swapping Qwen 3 ⇄ Mistral Small ⇄ DeepSeek-on-EU-hosting is a config
 * change, zero refactoring. All the providers under evaluation (Scaleway,
 * OVHcloud, La Plateforme) expose this same API shape.
 *
 * Without a key the caller falls back to the deterministic mock path — repo
 * convention (`generate_texts.ts`): never ship a half-wired external call.
 */

import * as logger from "firebase-functions/logger";

export type ChatMessage = {
  role: "system" | "user" | "assistant";
  content: string;
};

export type LlmConfig = {
  baseUrl: string;
  model: string;
  apiKey: string;
  configured: boolean;
};

type FetchResponse = {
  ok: boolean;
  status: number;
  text: () => Promise<string>;
};
type FetchLike = (url: string, init: {
  method: string;
  headers: Record<string, string>;
  body: string;
}) => Promise<FetchResponse>;

const DEFAULT_TIMEOUT_MS = 25_000;

/** Reads the LLM endpoint configuration from the environment. */
export function llmConfig(): LlmConfig {
  const baseUrl = (process.env.LLM_BASE_URL ?? "").replace(/\/+$/, "");
  const model = process.env.LLM_MODEL ?? "";
  const apiKey = process.env.LLM_API_KEY ?? process.env.OPENAI_API_KEY ?? "";
  return {
    baseUrl,
    model,
    apiKey,
    configured: baseUrl.length > 0 && model.length > 0 && apiKey.length > 0,
  };
}

/** Host of the configured inference endpoint — logged as provenance so the
 * EU data-residency requirement is auditable (§12.5, step 4B.4). */
export function llmEndpointHost(): string {
  const {baseUrl} = llmConfig();
  const match = baseUrl.match(/^https?:\/\/([^/]+)/);
  return match ? match[1] : "unconfigured";
}

/**
 * Calls `POST {baseUrl}/chat/completions` and returns the assistant text.
 * Throws on any transport/HTTP/format error — the caller degrades to the
 * fallback answer (§12.3: the chat degrades, it never blocks).
 */
export async function chatComplete(
  messages: ChatMessage[],
  opts?: {temperature?: number; maxTokens?: number; json?: boolean},
): Promise<string> {
  const cfg = llmConfig();
  if (!cfg.configured) throw new Error("llm-not-configured");

  const fetchImpl = (globalThis as unknown as {fetch: FetchLike}).fetch;
  const body: Record<string, unknown> = {
    model: cfg.model,
    messages,
    temperature: opts?.temperature ?? 0.2,
    max_tokens: opts?.maxTokens ?? 700,
  };
  if (opts?.json) body.response_format = {type: "json_object"};

  const timeout = new Promise<never>((_, reject) => {
    const t = setTimeout(
      () => reject(new Error("llm-timeout")), DEFAULT_TIMEOUT_MS);
    // Do not keep the function alive just for the timer.
    (t as unknown as {unref?: () => void}).unref?.();
  });

  const res = await Promise.race([
    fetchImpl(`${cfg.baseUrl}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${cfg.apiKey}`,
      },
      body: JSON.stringify(body),
    }),
    timeout,
  ]);

  if (!res.ok) {
    logger.error("LLM HTTP error", {status: res.status, host: llmEndpointHost()});
    throw new Error(`llm-http-${res.status}`);
  }
  const payload = JSON.parse(await res.text()) as {
    choices?: {message?: {content?: string}}[];
  };
  const content = payload.choices?.[0]?.message?.content;
  if (typeof content !== "string" || content.length === 0) {
    throw new Error("llm-empty-response");
  }
  return content;
}
