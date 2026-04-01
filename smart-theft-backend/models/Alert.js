const mongoose = require("mongoose");

const alertSchema = new mongoose.Schema({
    userId : {
        type : mongoose.Schema.Types.ObjectId,
        ref : "User"
    },
    imagePath : String,
    status : String,
    timestamp : {
        type : Date,
        default : Date.now()
    }
});

module.exports = mongoose.model("Alert", alertSchema);