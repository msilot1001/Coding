from traceback import format_stack
import discord
import time
import math
import discord.embeds
import asyncio

from discord.ext import commands

f = open('C:\Coding\Python\GamzaBot\EX2.stat.txt', 'w')

agreed = 0
cooltime = 5

bot = commands.Bot(command_prefix='$')

async def update_stat():
    await bot.wait_until_ready
    global agreed
    global cooltime

    while not bot.is_closed():
        try:
            with open("stat.txt", "a") as t:
                f.write(f"agreed : {str(agreed)}")
            
            await asyncio.sleep(cooltime)
        except Exception as e:
            print(e)
            await asyncio.sleep(cooltime)


@bot.event
async def on_ready():
    print("start")
    await bot.change_presence(status=discord.Status.online, activity=None)

@bot.command()
async def game(ctx,text):
    global agreed
    agreed = text
    print("game")



bot.loop.create_task(update_stat())
bot.run('ODQ3MzgzOTQ1NjE0OTgzMTY4.YK9RzA.ifiZW0fHwsVcNDl--nb4camgc2M')