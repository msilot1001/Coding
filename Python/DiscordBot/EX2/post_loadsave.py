import discord
import time
import math
import discord.embeds

from discord.ext import commands

bot = commands.Bot(command_prefix='$')

@bot.event
async def on_ready():
    print("start")
    await bot.change_presence(status=discord.Status.online, activity=discord.Game("테스트"))

bot.run('ODQ3MzgzOTQ1NjE0OTgzMTY4.YK9RzA.ifiZW0fHwsVcNDl--nb4camgc2M')