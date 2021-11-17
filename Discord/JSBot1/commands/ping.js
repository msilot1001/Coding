const { SlashCommandBuilder } = require('@discordjs/builders');
const { MessageEmbed } = require('discord.js');

module.exports = {
	data: new SlashCommandBuilder()
		.setName('ping')
		.setDescription('Replies with Pong!'),
	async execute(client, interaction, userinfo, User) {
        const PingEmbed = new MessageEmbed()
        .setColor('#CB7ACF')
        .setTitle(':ping_pong:\u0020\u0020Ping! Pong! ')
        .setAuthor('StarByte', 'https://media.discordapp.net/attachments/786810256709255179/898209754533474324/StarByte.png?width=676&height=676')
        .setDescription(`Ping : ${client.ws.ping}ms`)
        .addFields(
            { name: 'Requested by', value: `${interaction.user.username}, ${interaction.user.id}` }
        )
        .setTimestamp()
        .setFooter('StarByte', 'https://media.discordapp.net/attachments/786810256709255179/898209754533474324/StarByte.png?width=676&height=676');
		await interaction.reply({ embeds : [PingEmbed]});
	},
};