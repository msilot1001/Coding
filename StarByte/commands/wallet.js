const { SlashCommandBuilder } = require('@discordjs/builders');
const { MessageEmbed } = require('discord.js');

module.exports = {
	data: new SlashCommandBuilder()
		.setName('wallet')
		.setDescription('Checks your wallet\'s balance'),
	async execute(client, interaction, userinfo, User, db) {
        if (userinfo.wallet = null) { return interaction.reply({content:`Please try ${lefttime} seconds later.`, ephemeral : true }); }
        const balance = userinfo.wallet;

        const WalletEmbed = new MessageEmbed()
        .setColor('#CB7ACF')
        .setTitle('Wallet')
        .setAuthor('StarByte', 'https://media.discordapp.net/attachments/786810256709255179/898209754533474324/StarByte.png?width=676&height=676')
        .setDescription(`${interaction.user.username}'s balance'`)
        .addFields(
            { name: 'Wallet', value: `${balance}` }
        )
        .setTimestamp()
        .setFooter('StarByte', 'https://media.discordapp.net/attachments/786810256709255179/898209754533474324/StarByte.png?width=676&height=676');
		await interaction.reply({ embeds : [WalletEmbed]});
	},
};