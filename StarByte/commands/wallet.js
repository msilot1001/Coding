const { SlashCommandBuilder } = require('@discordjs/builders');
const { MessageEmbed } = require('discord.js');

module.exports = {
	data: new SlashCommandBuilder()
		.setName('wallet')
		.setDescription('Checks your wallet\'s balance'),
	async execute(client, interaction, User, db, mongoose, DBConnect) {
        let userinfo;

        await mongoose.connection.on('disconnected', DBConnect);

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
		}).clone().catch(function(err){ console.log(err)})

        console.log(userinfo.wallet)
        if (userinfo.wallet == null) { return interaction.reply({content:`Wallet value null`, ephemeral : true }); }
        var balance = userinfo.wallet;

        console.log(balance);

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