const fs = require('fs');
let rawdata = fs.readFileSync('config.json');
let config = JSON.parse(rawdata);


module.exports = async ( ) => {
    await mongoose.connect(dbkey, {
        useNewUrlParser : true,
        useUnifiedTopology : true,
    });
    return mongoose
}