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

  // 🔥 Store users: userId -> socketId
  const connectedUsers = new Map();

  io.on("connection", (socket) => {
    console.log("✅ User connected:", socket.id);

    // ================= REGISTER =================
    socket.on("register", (userId) => {
      connectedUsers.set(userId, socket.id);
      socket.userId = userId;

      // Join room (better scalability)
      socket.join(userId);

      console.log(`👤 ${userId} registered`);
    });

    // ================= CALL USER =================
    socket.on("call-user", ({ to, offer, callerName, callerRole }) => {
      const toSocketId = connectedUsers.get(to);

      if (toSocketId) {
        io.to(to).emit("incoming-call", {
          from: socket.userId,
          offer,
          callerName,
          callerRole,
        });

        console.log(`📞 Call from ${socket.userId} → ${to}`);
      } else {
        socket.emit("call-error", {
          message: "User is offline",
          to,
        });
      }
    });

    // ================= ACCEPT CALL =================
    socket.on("accept-call", ({ to, answer }) => {
      io.to(to).emit("call-accepted", {
        from: socket.userId,
        answer,
      });

      console.log(`✅ Call accepted by ${socket.userId}`);
    });

    // ================= REJECT CALL =================
    socket.on("reject-call", ({ to }) => {
      io.to(to).emit("call-rejected", {
        from: socket.userId,
      });

      console.log(`❌ Call rejected by ${socket.userId}`);
    });

    // ================= ICE CANDIDATE =================
    socket.on("ice-candidate", ({ to, candidate }) => {
      io.to(to).emit("ice-candidate", {
        from: socket.userId,
        candidate,
      });

      console.log(`🧊 ICE ${socket.userId} → ${to}`);
    });

    // ================= END CALL (FIXED) =================
    socket.on("end-call", ({ to }) => {
      io.to(to).emit("end-call", {
        from: socket.userId,
      });

      console.log(`📴 Call ended by ${socket.userId}`);
    });

    // ================= DISCONNECT =================
    socket.on("disconnect", () => {
      if (socket.userId) {
        connectedUsers.delete(socket.userId);
        console.log(`🔌 ${socket.userId} disconnected`);
      } else {
        console.log(`🔌 Unknown user disconnected`);
      }
    });
  });

  // ================= HEALTH CHECK =================
  app.get("/", (req, res) => {
    res.send("🚀 Server is running");
  });

  server.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
}

start().catch((err) => {
  console.error("❌ Server failed:", err.message);
  process.exit(1);
});