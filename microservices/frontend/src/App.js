import React, { useState, useEffect } from "react";
import axios from "axios";

function App() {
  const [message, setMessage] = useState("Loading...");
  const [visitors, setVisitors] = useState(0);
  const [error, setError] = useState("");

  const fetchData = async () => {
    try {
      // This will be updated to use the service name in Kubernetes
      const response = await axios.get("http://13.235.0.29:5000/api/hello");
      setMessage(response.data.message);
      setVisitors(response.data.visitors);
      setError("");
    } catch (err) {
      setError("Failed to connect to backend");
      setMessage("Error");
      console.error("Error fetching data:", err);
    }
  };

  useEffect(() => {
    fetchData();
    // Refresh data every 10 seconds
    const interval = setInterval(fetchData, 10000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ padding: "20px", textAlign: "center" }}>
      <h1>CICD Project Demo</h1>
      <h2>Frontend Service</h2>
      <div
        style={{ margin: "20px", padding: "20px", border: "1px solid #ccc" }}
      >
        <h3>Backend Response:</h3>
        <p>{message}</p>
        <p>Visitor count: {visitors}</p>
        {error && <p style={{ color: "red" }}>{error}</p>}
      </div>
      <button onClick={fetchData} style={{ padding: "10px 20px" }}>
        Refresh Data
      </button>
    </div>
  );
}

export default App;
