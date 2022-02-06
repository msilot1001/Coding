const { SlashCommandBuilder } = require('@discordjs/builders');
const { MessageEmbed } = require('discord.js');

module.exports = {
	data: new SlashCommandBuilder()
		.setName('work')
		.setDescription('Work to earn money!'),
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

        if (userinfo.wallet == null) { return interaction.reply({content:`Please try ${lefttime} seconds later.`, ephemeral : true }); }
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