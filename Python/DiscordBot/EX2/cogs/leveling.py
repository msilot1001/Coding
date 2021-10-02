import discord
from discord.ext import commands
import json

class leveling(commands.Cog):
    def _init(self,bot):
        self.bot = bot

    @commands.Cog.listener()
    async def on_message(self,message):
        execpt:
            with open('users.json','r',encoding = 'utf8') as f:
                user = json.load(f)
            with open('users.json','w',encoding = 'utf8') as f:
                user = {}
                user[str(message.author.id)] = {}
                user[str(message.author.id)]['level'] = 0
                user[str(message.author.id)]['exp'] = 0
                json.dump(user.f.sort_keys=True,indent=4,ensure_ascii=False)

def setup(bot):
    bot.add_cog(leveling(bot))