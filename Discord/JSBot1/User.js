const mongoose = require("mongoose")

const userSchema = mongoose.Schema({
id: {
    type: String,
    require : true
},
username: {
    type: String,
    required : true
},
bank: {
    type: Number,
    required : true
},
wallet: {
    type: Number,
    required : true
},
bitcoins: {
    type: Number,
    required : true
}
})

const User = mongoose.model("User", userSchema)

module.exports = { User }