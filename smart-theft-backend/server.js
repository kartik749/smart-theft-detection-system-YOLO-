require("dotenv").config()
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

mongoose.connect("mongodb://127.0.0.1:27017/theftDB")
.then(() => console.log("MongoDB connected"))
.catch(err => console.log(err));

app.use("/api/auth",require("./routes/auth"));

app.use("/api/alerts", require("./routes/alertRoutes"));

app.use("/users",require("./routes/userRoutes"));

app.use("/uploads",express.static("uploads"));

app.listen(5000, () => {
    console.log("Server Running on Port 5000");
});