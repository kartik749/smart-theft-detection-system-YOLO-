const express = require("express");
const router = express.Router();

const multer = require("multer");
const Alert = require("../models/Alert");

const storage = multer.diskStorage({
    destination: "../uploads/",
    filename: (req, file, cb) => {
        cb(null, Date.now() + ".jpg");
    }
});

const upload = multer({ storage });

router.post("/", upload.single("image"), async (req, res) => {
    console.log("Request received");

    try {
        const alert = new Alert({
            imagePath: req.file.path,
            status: "motion detected"
        });

        await alert.save();

        res.json({
            message: "Alert Saved",
            path: req.file.path
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;