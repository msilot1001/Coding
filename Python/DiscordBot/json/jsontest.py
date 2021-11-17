import discord

from discord.ext.commands import Bot
import random
import pickle
import os

client = Bot(command_prefix="c!") #Make sure to put ur prefix here doods

data_filename = "data.pickle"

class Data:
    def __init__(self, wallet, bank):
        self.wallet = wallet
        self.bank = bank

#Events
@client.event
async def on_ready():
    print(f"Logged in as {client.user}")
#Commands
@client.command()
async def work(message):
    member_data = load_member_data(message.author.id)
    member_data.wallet += 1
    await message.channel.send("일을 하여 500감자코인을 획득하였습니다")
    save_member_data(message.author.id, member_data)
@client.command()
async def bal(message):
    member_data = load_member_data(message.author.id)
    embed = discord.Embed(title=f"{message.author.display_name}'s Balance")
    embed.add_field(name="Wallet", value=str(member_data.wallet))
    embed.add_field(name="bank", value=str(member_data.bank))
    await message.channel.send(embed=embed)
@client.command()
async def beg(message):
    member_data = load_member_data(message.author.id)
    randvalue = random.randrange(1001)
    member_data.wallet += randvalue
    embed = discord.Embed(title=f"{randvalue}감자코인을 얻었습니다")
    await message.channel.send(embed=embed)
    save_member_data(message.author.id, member_data)
#Functions
def load_data():
    if os.path.isfile(data_filename):
        with open(data_filename, "rb") as file:
            return pickle.load(file)
    else:
        return dict()
def load_member_data(member_ID):
    data = load_data()
    if member_ID not in data:
        return Data(0, 0)
    return data[member_ID]
def save_member_data(member_ID, member_data):
    data = load_data()
    data[member_ID] = member_data
    with open(data_filename, "wb") as file:
        pickle.dump(data, file)