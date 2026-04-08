require("dotenv").config();
const http = require("http");
const { Server } = require("socket.io");
const app = require("./app");
const { connectDatabase } = require("./config/db");

const PORT = Number(process.env.PORT || 5000);

async function start() {
  await connectDatabase();

  const server = http.createServer(app);

  const io = new Server(server, {
    cors: {
      origin: "*",
      methods: ["GET", "POST"],
    },
  });

  io.on("connection", (socket) => {
    console.log("✅ User connected:", socket.id);

    // ================= REGISTER =================
    socket.on("register", (userId) => {
      if (!userId) return;

      socket.userId = userId;
      socket.join(userId);

      console.log(`👤 ${userId} registered`);
    });

    // ================= CALL USER =================
    socket.on("call-user", ({ to, offer, callerName, callerRole }) => {
      if (!to) return;

      io.to(to).emit("incoming-call", {
        from: socket.userId,
        offer,
        callerName,
        callerRole,
      });

      console.log(`📞 ${socket.userId} → ${to}`);
    });

    // ================= ACCEPT CALL =================
    socket.on("accept-call", ({ to, answer }) => {
      if (!to) return;

      io.to(to).emit("call-accepted", {
        from: socket.userId,
        answer,
      });

      console.log(`✅ Accepted by ${socket.userId}`);
    });

    // ================= REJECT CALL =================
    socket.on("reject-call", ({ to }) => {
      if (!to) return;

      io.to(to).emit("call-rejected", {
        from: socket.userId,
      });

      console.log(`❌ Rejected by ${socket.userId}`);
    });

    // ================= ICE =================
    socket.on("ice-candidate", ({ to, candidate }) => {
      if (!to) return;

      io.to(to).emit("ice-candidate", {
        from: socket.userId,
        candidate,
      });

      console.log(`🧊 ICE ${socket.userId} → ${to}`);
    });

    // ================= END CALL =================
    socket.on("end-call", ({ to }) => {
      if (!to) return;

      io.to(to).emit("end-call", {
        from: socket.userId,
      });

      console.log(`📴 Ended by ${socket.userId}`);
    });

    // ================= DISCONNECT =================
    socket.on("disconnect", () => {
      console.log(`🔌 ${socket.userId || "Unknown"} disconnected`);
    });

    socket.on("error", (err) => {
      console.error("Socket error:", err);
    });
  });

  server.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
}

start().catch((err) => {
  console.error("❌ Server failed:", err.message);
  process.exit(1);
});