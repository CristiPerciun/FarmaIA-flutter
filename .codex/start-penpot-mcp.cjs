const net = require("node:net");
const { spawn, spawnSync } = require("node:child_process");

const nodeExecutable = process.execPath;
const penpotEntry =
  "C:\\Users\\c.perciun\\AppData\\Roaming\\npm\\node_modules\\@penpot\\mcp\\bin\\mcp-local.js";
const proxyEntry =
  "C:\\Users\\c.perciun\\AppData\\Roaming\\npm\\node_modules\\mcp-remote\\dist\\proxy.js";
const mcpUrl = "http://localhost:4401/sse";

function isPortOpen(port) {
  return new Promise((resolve) => {
    const socket = net.createConnection({ host: "localhost", port });
    const finish = (open) => {
      socket.removeAllListeners();
      socket.destroy();
      resolve(open);
    };

    socket.setTimeout(500);
    socket.once("connect", () => finish(true));
    socket.once("timeout", () => finish(false));
    socket.once("error", () => finish(false));
  });
}

async function waitForPort(port, timeoutMs) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (await isPortOpen(port)) return;
    await new Promise((resolve) => setTimeout(resolve, 500));
  }
  throw new Error(`Penpot MCP did not open port ${port} in time.`);
}

function stopTree(child) {
  if (!child || child.exitCode !== null) return;
  if (process.platform === "win32") {
    spawnSync("taskkill", ["/PID", String(child.pid), "/T", "/F"], {
      windowsHide: true,
      stdio: "ignore",
    });
  } else {
    child.kill("SIGTERM");
  }
}

async function main() {
  let penpotProcess;

  if (!(await isPortOpen(4401))) {
    penpotProcess = spawn(nodeExecutable, [penpotEntry], {
      windowsHide: true,
      stdio: ["ignore", "ignore", "inherit"],
    });
    penpotProcess.once("error", (error) => {
      process.stderr.write(`Unable to start Penpot MCP: ${error.message}\n`);
    });
    await waitForPort(4401, 120_000);
  }

  const proxyProcess = spawn(
    nodeExecutable,
    [proxyEntry, mcpUrl, "--allow-http"],
    { windowsHide: true, stdio: "inherit" },
  );

  const shutdown = () => {
    stopTree(proxyProcess);
    stopTree(penpotProcess);
  };

  process.once("SIGINT", shutdown);
  process.once("SIGTERM", shutdown);
  process.once("exit", shutdown);

  proxyProcess.once("exit", (code) => {
    stopTree(penpotProcess);
    process.exit(code ?? 1);
  });
}

main().catch((error) => {
  process.stderr.write(`${error.stack || error.message}\n`);
  process.exit(1);
});
