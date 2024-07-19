const express = require("express");
const cors = require("cors"); // Include CORS middleware
const app = express();
const port = 3000;
let balance = 813083240;  /// ------- 120000000 gold 

// Middleware for logging requests
app.use(cors()); // Enable CORS for all routes and origins
app.use(express.json()); // Middleware to parse JSON bodies
app.use((req, res, next) => {
  console.log(`${req.method} request for '${req.url}'`);
  next();
});

// Delay function
function delay(req, res, next) {
  const duration = req.query.duration ? parseInt(req.query.duration, 10) : 10000; // Default to 1000ms if no duration is specified
  if (isNaN(duration)) {
    return res.status(400).json({ error: "Invalid duration" });
  }
  setTimeout(next, duration);
}

// Route handling
app.get("/", (req, res) => {
  res.status(200).json({ balance: balance });  // Simulated reserve balance
});

app.get("/delay", delay, (req, res) => {
  res.status(200).json({ message: `Response delayed by ${req.query.duration || 1000} milliseconds` });
});

app.post("/updateReserve", (req, res) => {
  balance = req.body.newReserve;  // Update the global balance variable
  res.status(200).json({ balance: balance });  // Return the updated balance
});

// Error handling middleware for unspecified routes
app.use((req, res, next) => {
  res.status(404).send('Sorry, that route does not exist.');
});

// Error handling middleware for server errors
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Something broke!');
});

// Starting the server
app.listen(port, () => {
  console.log(`Mock API listening at http://localhost:${port}`);
});
