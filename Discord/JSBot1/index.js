const { User } = require("./User.js")
var db = require('quick.db')
const { Client, Collection, Intents } = require('discord.js');
const fs = require('fs');
const client = new Client({ intents: [Intents.FLAGS.GUILDS] });
client.commands = new Collection();

let rawdata = fs.readFileSync('config.json');
let config = JSON.parse(rawdata);

const token = config.token
const dbkey = config.dbkey;

client.commands = new Collection();
const commandFiles = fs.readdirSync('./commands').filter(file => file.endsWith('.js'));

for (const file of commandFiles) {
	const command = require(`./commands/${file}`);
	client.commands.set(command.data.name, command);
}

const mongoose = require("mongoose");

function DBConnect() {
	const connect = mongoose.connect(dbkey, {
		useNewUrlParser : true,
		useUnifiedTopology : true,
		useFindAndModify : true,
	}).then(() => console.log("==> MongoDB Connected..."))
	.catch(err => console.error(err));
}

DbConnect();

client.once('ready', () => {
	console.log('Ready!');
});

client.on('interactionCreate', async interaction => {
	try {
		if (!interaction.isCommand()) return;

		const command = client.commands.get(interaction.commandName);

		if (!command) return;

		var userinfo;

		console.log(`${interaction.user.username}#${interaction.user.discriminator} Requested Command \"${interaction.commandName}\"`)

		await mongoose.connection.on('disconnected', DbConnect);

		await User.findOne({ id: interaction.user.id}, async (err, user) => {
			if(err) { interaction.reply({ content: 'Error occured. Please try after.', ephemeral: true }); }
			else{
				console.log(user);
			}
			if (!user) {
				const newUser = new User({
					id: interaction.user.id,
					username: interaction.user.username,
					bank: 0,
					wallet: 0,
					bitcoins: 0,
					agreed: 0
				});
				await newUser.save((err, doc) => {
					if (err) console.log(`Failed to save user ${interaction.user.id}!`, err)
					console.log(`new user ${interaction.user.id} saved`);
				});
			}
			userinfo = user;
		})

		if(interaction.commandName == 'work') {
			let workcooldown = 60000;
			let lastwork = await db.fetch(`work_${interaction.user.id}`);
			console.log(lastwork);

			lastwork = Number(lastwork);

			if ( lastwork != null && (workcooldown - (Date.now() - lastwork)) > 0) {
				//cooldown left
				const lefttime = Math.floor((workcooldown - (Date.now() - lastwork)) / 1000)
				return interaction.reply({content:`Please try ${lefttime} seconds later.`, ephemeral : true })
			}
			else{
				//update and pass
				await db.set(`workbefore_${interaction.user.id}`, lastwork)
				await db.set(`work_${interaction.user.id}`, Date.now())
			}
		}
		
		await command.execute(client, interaction, userinfo, User, db);
	} catch (error) {
		console.error(error);
		console.log(`Error Occured at \"${interaction.commandName}\" Requested by ${interaction.user.username}#${interaction.user.discriminator} `)
		if(interaction.commandName == 'work') {
			let workcooldown = 60000;
			let lastwork = await db.fetch(`workbefore_${interaction.user.id}`);
			await db.set(`work_${interaction.user.id}`, lastwork)
		}
		return interaction.reply({ content: 'Error occured. Please try after.', ephemeral: true });
	}
});
	
client.login(token)