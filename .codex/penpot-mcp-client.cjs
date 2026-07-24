const fs = require("node:fs");

const endpoint = "http://localhost:4401/mcp";
let sessionId;
let nextId = 1;

function parseResponse(text, expectedId) {
  const candidates = [];
  for (const line of text.split(/\r?\n/)) {
    if (!line.startsWith("data:")) continue;
    const value = line.slice(5).trim();
    if (!value || value === "[DONE]") continue;
    try {
      candidates.push(JSON.parse(value));
    } catch (_) {}
  }
  if (candidates.length === 0 && text.trim()) {
    candidates.push(JSON.parse(text));
  }
  return (
    candidates.find((item) => item && item.id === expectedId) ??
    candidates.at(-1)
  );
}

async function send(method, params, notification = false) {
  const id = notification ? undefined : nextId++;
  const payload = { jsonrpc: "2.0", method };
  if (id !== undefined) payload.id = id;
  if (params !== undefined) payload.params = params;

  const headers = {
    "Content-Type": "application/json",
    Accept: "application/json, text/event-stream",
  };
  if (sessionId) headers["mcp-session-id"] = sessionId;

  const response = await fetch(endpoint, {
    method: "POST",
    headers,
    body: JSON.stringify(payload),
  });
  sessionId = response.headers.get("mcp-session-id") || sessionId;
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`${response.status} ${response.statusText}: ${text}`);
  }
  if (notification) return null;
  const parsed = parseResponse(text, id);
  if (parsed?.error) throw new Error(JSON.stringify(parsed.error, null, 2));
  return parsed?.result;
}

async function initialize() {
  await send("initialize", {
    protocolVersion: "2025-03-26",
    capabilities: {},
    clientInfo: { name: "codex-penpot-client", version: "1.0.0" },
  });
  await send("notifications/initialized", undefined, true);
}

async function main() {
  await initialize();
  const [command, ...args] = process.argv.slice(2);

  if (command === "list") {
    const result = await send("tools/list", {});
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    return;
  }

  if (command === "call") {
    const [toolName, jsonFile] = args;
    if (!toolName || !jsonFile) {
      throw new Error("Usage: call <tool-name> <arguments-json-file>");
    }
    const toolArgs = JSON.parse(fs.readFileSync(jsonFile, "utf8"));
    const result = await send("tools/call", {
      name: toolName,
      arguments: toolArgs,
    });
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    return;
  }

  throw new Error("Usage: list | call <tool-name> <arguments-json-file>");
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exit(1);
});
