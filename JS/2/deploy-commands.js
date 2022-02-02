const { SlashCommandBuilder } = require('@discordjs/builders');
const { REST } = require('@discordjs/rest');
const { Routes } = require('discord-api-types/v9');
const { clientId,  token } = require('./config.json');

const commands = [
	new SlashCommandBuilder().setName('work').setDescription('Work to earn money!'),
	new SlashCommandBuilder().setName('wallet').setDescription('Checks your wallet balance'),
].map(command => command.toJSON());

console.log('14')
const rest = new REST({ version: '9' }).setToken(token);

console.log('16')
rest.put(Routes.applicationCommands(clientId), { body: commands })
	.then(() => console.log(`Successfully registered application commands. : ${commands}`))
	.catch(console.error);
