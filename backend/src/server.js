require("dotenv").config();
const http = require("http");
const { Server } = require("socket.io");
const app = require("./app");
const { connectDatabase } = require("./config/db");

const port = Number(process.env.PORT || 5000);

async function start() {
  await connectDatabase();
  
  // Create HTTP server
  const server = http.createServer(app);
  
  // Setup Socket.io for WebRTC signaling
  const io = new Server(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"]
    }
  });

  // Store connected users: userId -> socketId
  const connectedUsers = new Map();

  io.on("connection", (socket) => {
    console.log(`User connected: ${socket.id}`);

    // User registers with their userId
    socket.on("register", (userId) => {
      connectedUsers.set(userId, socket.id);
      console.log(`User ${userId} registered with socket ${socket.id}`);
      socket.userId = userId;
    });

    // Initiate video call
    socket.on("call-user", async ({ to, offer, callerName, callerRole }) => {
      const toSocketId = connectedUsers.get(to);
      if (toSocketId) {
        io.to(toSocketId).emit("incoming-call", {
          from: socket.userId,
          offer,
          callerName,
          callerRole
        });
        console.log(`Call initiated from ${socket.userId} to ${to}`);
      } else {
        socket.emit("call-error", { message: "User not online" });
      }
    });

    // Accept call
    socket.on("accept-call", async ({ to, answer }) => {
      const toSocketId = connectedUsers.get(to);
      if (toSocketId) {
        io.to(toSocketId).emit("call-accepted", {
          from: socket.userId,
          answer
        });
        console.log(`Call accepted by ${socket.userId}`);
      }
    });

    // Reject call
    socket.on("reject-call", ({ to }) => {
      const toSocketId = connectedUsers.get(to);
      if (toSocketId) {
        io.to(toSocketId).emit("call-rejected", {
          from: socket.userId
        });
      }
    });

    // Exchange ICE candidates
    socket.on("ice-candidate", ({ to, candidate }) => {
      const toSocketId = connectedUsers.get(to);
      if (toSocketId) {
        io.to(toSocketId).emit("ice-candidate", {
          from: socket.userId,
          candidate
        });
      }
    });

    // End call
    socket.on("end-call", ({ to }) => {
      const toSocketId = connectedUsers.get(to);
      if (toSocketId) {
        io.to(toSocketId).emit("call-ended", {
          from: socket.userId
        });
      }
    });

    // User disconnects
    socket.on("disconnect", () => {
      if (socket.userId) {
        connectedUsers.delete(socket.userId);
        console.log(`User ${socket.userId} disconnected`);
      }
    });
  });

  server.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
    console.log(`Socket.io signaling server ready`);
  });
}

start().catch((error) => {
  console.error("Failed to start server:", error.message);
  process.exit(1);
});
