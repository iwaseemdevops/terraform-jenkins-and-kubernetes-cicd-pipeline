const express = require("express");
const cors = require("cors");

const app = express();
const PORT = 5000; // run backend on 5000 so it doesn't clash with React (3000)

// Enable CORS so frontend (3000) can talk to backend (5000)
app.use(cors());

// Simple in-memory visitor counter
let visitors = 0;

app.get("/api/hello", (req, res) => {
  visitors++;
  res.json({
    message: "Hello from Backend 👋",
    visitors: visitors,
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`✅ Backend running on http://localhost:${PORT}`);
});
