import http from "http";
import dotenv from "dotenv";
import { load } from "@azure/app-configuration-provider";

dotenv.config();

const connectionString = process.env.AZURE_APPCONFIG_CONNECTION_STRING;
if (!connectionString) {
  console.error("❌ Missing AZURE_APPCONFIG_CONNECTION_STRING in .env");
  process.exit(1);
}

let appConfig;

async function initializeConfig() {
  console.log("🚀 Loading configuration from Azure App Configuration...");
  try {
    appConfig = await load(connectionString, {
      refreshOptions: {
        enabled: true,
        refreshIntervalInMs: 5_000,
      },
    });
    console.log("✅ Configuration loaded successfully!");
  } catch (err) {
    console.error("⚠️ Failed to load config:", err.message);
    process.exit(1);
  }
}

function startServer() {
  const server = http.createServer(async (req, res) => {
    try {
      await appConfig.refresh();

      const title = appConfig.get("ui:title") || "🏪 Default Title";
      const themeColor = appConfig.get("ui:themeColor") || "midnightblue";
      const fontSize = appConfig.get("ui:fontSize") || "26px";

      res.writeHead(200, { "Content-Type": "text/html" });
      res.end(`
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>${title}</title>
          <style>
            body {
              background-color: ${themeColor};
              color: white;
              font-family: 'Segoe UI', sans-serif;
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
              height: 100vh;
              margin: 0;
              transition: background-color 0.6s ease;
            }
            h1 {
              font-size: ${fontSize};
              margin-bottom: 10px;
            }
            .card {
              background: rgba(255, 255, 255, 0.15);
              padding: 20px 40px;
              border-radius: 16px;
              box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
              text-align: center;
            }
            p {
              margin: 8px 0;
            }
            .github {
              margin-top: 20px;
              font-size: 18px;
            }
            a {
              color: #fff;
              font-weight: bold;
              text-decoration: none;
            }
            a:hover {
              text-decoration: underline;
            }
            .emoji {
              font-size: 36px;
            }
          </style>
        </head>
        <body>
          <div class="card">
            <div class="emoji">🚀</div>
            <h1>${title}</h1>
            <p>Background color: <strong>${themeColor}</strong></p>
            <p>Font size: <strong>${fontSize}</strong></p>
            <small>Last update: ${new Date().toLocaleTimeString()}</small>
          </div>
          <div class="github">
            <p>👨‍💻 Created by <a href="https://github.com/francotel" target="_blank">@francotel</a></p>
          </div>
        </body>
        </html>
      `);
    } catch (err) {
      res.writeHead(500, { "Content-Type": "text/plain" });
      res.end("Error loading configuration: " + err.message);
    }
  });

  const port = process.env.PORT || 3000;
  server.listen(port, "0.0.0.0", () => {
    console.log(`🌍 Server running at http://localhost:${port}/`);
  });
}

initializeConfig().then(startServer);
