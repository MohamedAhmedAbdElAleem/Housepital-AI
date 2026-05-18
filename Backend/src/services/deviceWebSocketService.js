const { WebSocketServer } = require("ws");
const url = require("url");
const Device = require("../models/Device");
const { processVitals } = require("./deviceVitalsService");
const { logEvents } = require("../middleware/logger");

let wss;

// Maps deviceId -> WebSocket instance
const activeConnections = new Map();

const initDeviceWebSocket = (server) => {
	// We run 'noServer: true' because Express might also be handling HTTP upgrades for Socket.IO
	wss = new WebSocketServer({ noServer: true });

	// Handle the upgrade event on the main HTTP server
	server.on("upgrade", async (request, socket, head) => {
		const parsedUrl = url.parse(request.url, true);

		// Only intercept requests to our specific stream endpoint
		if (parsedUrl.pathname === "/api/device/stream") {
			const token = parsedUrl.query.token;

			if (!token) {
				socket.write("HTTP/1.1 401 Unauthorized\r\n\r\n");
				socket.destroy();
				return;
			}

			try {
				const device = await Device.findByToken(token);
				if (!device) {
					console.error(`[WS Auth] ❌ Invalid token attempt from ${request.connection.remoteAddress}`);
					socket.write("HTTP/1.1 403 Forbidden\r\n\r\n");
					socket.destroy();
					return;
				}

				// Authentication successful
				wss.handleUpgrade(request, socket, head, (ws) => {
					wss.emit("connection", ws, request, device);
				});
			} catch (error) {
				socket.write("HTTP/1.1 500 Internal Server Error\r\n\r\n");
				socket.destroy();
			}
		}
	});

	wss.on("connection", (ws, request, device) => {
		const deviceId = device.deviceId;
		console.log(`[WS] 🔌 Device ${deviceId} connected`);

		// Close any existing connection for this device to prevent zombies
		if (activeConnections.has(deviceId)) {
			activeConnections.get(deviceId).close();
		}
		activeConnections.set(deviceId, ws);

		// Send initial welcome message
		ws.send(JSON.stringify({ type: "connected", message: "Welcome to Housepital AI Cloud" }));

		// Handle incoming messages
		ws.on("message", async (data) => {
			try {
				const payload = JSON.parse(data.toString());

				if (payload.type === "vitals") {
					// We need to fetch a fresh device document to ensure assignedBooking is current
					const currentDevice = await Device.findOne({ deviceId });
					if (currentDevice) {
						await processVitals(currentDevice, payload);
						ws.send(JSON.stringify({ type: "ack", status: "ok" }));
					}
				} else if (payload.type === "ping") {
					// Update lastSeenAt
					await Device.updateOne({ deviceId }, { lastSeenAt: new Date() });
					ws.send(JSON.stringify({ type: "pong" }));
				}
			} catch (error) {
				logEvents(`WS Vitals Error [${deviceId}]: ${error.message}`, "deviceErrLog.log");
				ws.send(JSON.stringify({ type: "error", message: error.message }));
			}
		});

		ws.on("close", () => {
			console.log(`[WS] 🔌 Device ${deviceId} disconnected`);
			if (activeConnections.get(deviceId) === ws) {
				activeConnections.delete(deviceId);
			}
		});

		ws.on("error", (error) => {
			console.error(`[WS] 🔥 Error on device ${deviceId}: ${error.message}`);
		});
	});
};

module.exports = { initDeviceWebSocket };
