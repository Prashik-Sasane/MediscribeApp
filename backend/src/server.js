require("dotenv").config();
const http = require("http");
const { Server } = require("socket.io");
const app = require("./app");
const { connectDatabase } = require("./config/db");
const Message = require("./models/Message");

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

    
    socket.on("register", (userId) => {
      if (!userId) return;

      socket.userId = userId;
      socket.join(userId);

      console.log(`👤 ${userId} registered`);
    });

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

      console.log(`🧊 ICE from ${socket.userId} to ${to}:`, candidate?.sdpMid || 'unknown');

      io.to(to).emit("ice-candidate", {
        from: socket.userId,
        candidate,
      });
    });

    // ================= CHAT =================
    socket.on("join-chat", ({ appointmentId }) => {
      if (!appointmentId) return;
      
      const roomName = `chat_${appointmentId}`;
      socket.join(roomName);
      console.log(`💬 ${socket.userId} joined chat room: ${roomName}`);
    });

    socket.on(
      "send-message",
      async ({ appointmentId, text, senderName, senderRole, messageId, createdAt, senderId }) => {
        if (!appointmentId || !text) return;

        const roomName = `chat_${appointmentId}`;

        // If the message was already persisted via REST, just broadcast it.
        if (messageId) {
          io.to(roomName).emit("receive-message", {
            id: messageId,
            text,
            senderName: senderName || "Unknown",
            senderRole: senderRole || "patient",
            createdAt: createdAt || new Date().toISOString(),
          });
          return;
        }

        try {
          // Store message in MongoDB
          const message = await Message.create({
            appointmentId,
            senderId: socket.userId || senderId || "unknown",
            senderName: senderName || "Unknown",
            senderRole: senderRole || "patient",
            text,
          });

          console.log(`💬 Message saved: ${message._id}`);

          // Broadcast to chat room
          io.to(roomName).emit("receive-message", {
            id: message._id.toString(),
            text: message.text,
            senderName: message.senderName,
            senderRole: message.senderRole,
            createdAt: message.createdAt,
          });

          console.log(`💬 Message broadcasted to ${roomName}`);
        } catch (error) {
          console.error("❌ Error saving message:", error);
        }
      }
    );

    socket.on("leave-chat", ({ appointmentId }) => {
      if (!appointmentId) return;
      
      const roomName = `chat_${appointmentId}`;
      socket.leave(roomName);
      console.log(`💬 ${socket.userId} left chat room: ${roomName}`);
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