import discord,time,math,discord.embeds,asyncio,json,os,random

os.chdir("C:\Coding\Python\GamzaBot\EX2")

from discord.ext import commands
import json
import os

os.chdir("C:\\Coding\\Python\\GamzaBot\\economy")
client = commands.Bot(command_prefix='e!')

@client.event
async def on_ready():
    print("start")
    await client.change_presence(status=discord.Status.online, activity=None)

@client.command()
async def balance(ctx):
    await open_account(ctx.author)
    user = ctx.author
    
    users = await get_bank_data()

    wallet_amt = users[str(user.id)["wallet"]]
    bank_amt = users[str(user.id)["bank"]]
    embed  = discord.Embed(title = f"{ctx.author.name}'s balance", color = 0x8dceee)
    embed.add_field(name="Wallet:",value=wallet_amt)
    embed.add_field(name="Bank:",value=bank_amt)
    await ctx.send(embed = embed)

@client.command()
async def beg(ctx):
    await open_account(ctx.author)
    user = ctx.author
    users = await get_bank_data()
    earnings = random.randrange(51) * 1000
    users[str(user.id)["wallet"]] += earnings
    await ctx.send(f"{earnings}원을 얻었습니다")
    with open('mainbank.json', 'w') as f:
        json.dump(users,f)

async def get_bank_data():
    with open('mainbank.json', 'r') as f:
        users = json.load(f)
    return users

async def open_account(user):
    users = get_bank_data()
    
    if user.id in users:
        return False
    else:
        users[str(user.id)] = {}
        users[str(user.id)]["wallet"] = 0
        users[str(user.id)]["bank"] = 0

    with open('mainbank.json', 'w') as f:
        json.dump(users,f)
        return True

=