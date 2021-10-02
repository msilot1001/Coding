import discord,json,os

from discord.ext import commands
bot = commands.Bot(command_prefix='$')
os.chdir(r'C:\Coding\Python\GamzaBot\json')

data_filename = "data.pickle"

class Data:
    def __init__(self, wallet, bank):
        self.wallet = wallet
        self.bank = bank

@bot.event
async def on_ready():
    print("bot start")


@bot.event
async def on_member_join(member):
    with open('users.json', 'r') as f:
        users = json.load(f)

    await update_data(users, member)

    with open('users.json' , 'w') as f:
        json.dump(users, f)

@bot.event
async def on_message(message):
    print("message")
    with open('users.json', 'r') as f:
        users = json.load(f)
    user = message.author
    with open('users.json' , 'w') as f:
        inputexp = users[user.id]['experience']
        users[user.id]['experience'] = inputexp + 5
        json.dump(users, f)

async def update_data(users,user):
    if not user.id in users:
        users[user.id] = {}
        users[user.id]['experience'] = 0
        users[user.id]['level'] = 1

async def add_experience(users,user, exp):
    inputexp = users[user.id]['experience']
    users[user.id]['experience'] = inputexp + 5

bot.run('ODQ3MzgzOTQ1NjE0OTgzMTY4.YK9RzA.ifiZW0fHwsVcNDl--nb4camgc2M')  