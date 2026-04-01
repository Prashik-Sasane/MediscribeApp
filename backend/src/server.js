require("dotenv").config();
const app = require("./app");
const { connectDatabase } = require("./config/db");

const port = Number(process.env.PORT || 5000);

async function start() {
  await connectDatabase();
  app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
  });
}

start().catch((error) => {
  console.error("Failed to start server:", error.message);
  process.exit(1);
});
