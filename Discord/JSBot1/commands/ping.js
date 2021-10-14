const { SlashCommandBuilder } = require('@discordjs/builders');
const { MessageEmbed } = require('discord.js');

module.exports = {
	data: new SlashCommandBuilder()
		.setName('ping')
		.setDescription('Replies with Pong!'),
	async execute(client, interaction) {
        const PingEmbed = new MessageEmbed()
        .setColor('#CB7ACF')
        .setTitle('Ping(Latency) :ping_pong:')
        .setAuthor('StarByte', 'https://discord.com/channels/786390843082014744/786810256709255179/898209754730598440')
        .setDescription(`Ping : ${client.ws.ping}ms`)
        .setTimestamp()
        .setFooter('StarByte', 'https://discord.com/channels/786390843082014744/786810256709255179/898209754730598440');
		await interaction.reply({ embeds : [PingEmbed]});
	},
};
