const jwt = require("jsonwebtoken");

const JWT_SECRET = "mysecretkey";

module.exports = function (req, res, next) {
    const authHeader = req.header("Authorization");

    if (!authHeader) {
        return res.status(401).json({ message: "No token, access denied" });
    }

    // Expecting: Bearer <token>
    const token = authHeader.split(" ")[1];

    if (!token) {
        return res.status(401).json({ message: "Token format invalid" });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        console.error("JWT Error:", err.message);
        res.status(400).json({ message: "Invalid token" });
    }
};