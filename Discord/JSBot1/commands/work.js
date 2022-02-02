const { SlashCommandBuilder } = require('@discordjs/builders');
const { MessageEmbed } = require('discord.js');

module.exports = {
	data: new SlashCommandBuilder()
		.setName('work')
		.setDescription('Work to earn money!'),
	async execute(client, interaction, userinfo, User, db) {
        if (userinfo.wallet = null) { return interaction.reply({content:`Please try ${lefttime} seconds later.`, ephemeral : true }); }
        const min = Math.ceil(400);
        const max = Math.floor(1000);
        const result = Math.floor(Math.random() * (max - min + 1)) + min; //최댓값도 포함, 최솟값도 포함

        userinfo.wallet += result;

        await userinfo.save((err, doc) => {
            if (err) console.log(`Failed to save user ${interaction.user.id}!`, err)
            console.log(`user ${interaction.user.id} saved`);
        });

        const WorkEmbed = new MessageEmbed()
        .setColor('#CB7ACF')
        .setTitle('Work!')
        .setAuthor('StarByte', 'https://media.discordapp.net/attachments/786810256709255179/898209754533474324/StarByte.png?width=676&height=676')
        .setDescription(`Earned ${result} starcoin!`)
        .addFields(
            { name: 'Requested by', value: `${interaction.user.username}, ${interaction.user.id}` }
        )
        .setTimestamp()
        .setFooter('StarByte', 'https://media.discordapp.net/attachments/786810256709255179/898209754533474324/StarByte.png?width=676&height=676');
		await interaction.reply({ embeds : [WorkEmbed]});
	},
};