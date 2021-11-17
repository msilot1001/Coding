const mongoose = require("mongoose")

const userSchema = mongoose.Schema({
id: {
    type: Number,
},
username: {
    type: String,
},
bank: {
    type: Number,
},
wallet: {
    type: Number,
},
bitcoins: {
    type: Number,
},
agreed: {
    type: Boolean,
}
})

const User = mongoose.model("User", userSchema)

module.exports = { User }