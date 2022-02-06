const { SlashCommandBuilder } = require('@discordjs/builders');
const { REST } = require('@discordjs/rest');
const { Routes } = require('discord-api-types/v9');
const { clientId,  token } = require('./config.json');

const commands = [
	new SlashCommandBuilder().setName('ping')
	.setDescription('Replies Ping!'),
	new SlashCommandBuilder().setName('work')
	.setDescription('Work to earn money!'),
	new SlashCommandBuilder().setName('wallet')
	.setDescription('Checks your wallet balance'),
	new SlashCommandBuilder().setName('subcomtest')
	.setDescription('SubCommand Test Command')
	.addSubcommand(subcommand => 
		subcommand
		.setName('user')
		.setDescription('Mention User')
		.addUserOption(option => option.setName('target').setDescription('The User')))
].map(command => command.toJSON());

const rest = new REST({ version: '9' }).setToken(token);

rest.put(Routes.applicationCommands(clientId), { body: commands })
	.then(() => console.log(`Successfully registered application commands. : ${commands}`))
	.catch(console.error);
	