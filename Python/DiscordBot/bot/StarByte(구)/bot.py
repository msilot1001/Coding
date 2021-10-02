import discord,os,time,pickle

from discord.ext import commands

#0:Gamza
#1:Star
#2:ID


bot = commands.Bot(command_prefix='&')
bot.remove_command("help")
Gamzadata_filename = "data.pickle"
IDdata_filename = "id.pickle"
StarBytedata_filename = "coin.pickle"
class GamzaData:
    def __init__(self, wallet, bank, gametoken, gametry, gamewin):
        self.wallet = wallet
        self.bank = bank
        self.gametoken = gametoken
        self.gametry = gametry
        self.gamewin = gamewin
class StarData:
    def __init__(self,name,owner,count,value):
        self.name = name
        self.owner = owner
        self.count = count
        self.value = value
class IDData:
    def __init__(self,id,name):
        self.id = id
        self.name = name

@bot.event
async def on_ready():#봇 실행
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]",": Logged as",bot.user.name,", ID : ",bot.user.id)
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]",": Bot Ready")
    await bot.change_presence(status=discord.Status.online, activity=discord.Game("개발중임"))

@bot.command()
async def reset():
    print("reset")




def gettime():
    timesec = time.time()
    tm = time.gmtime(timesec)
    return tm
def load_data(type):
    if type is 0:
        if os.path.isfile(Gamzadata_filename):
            with open(Gamzadata_filename, "rb") as file:
                return pickle.load(file)
        else:
            return dict()
    if type is 1:
        if os.path.isfile(StarBytedata_filename):
            with open(StarBytedata_filename, "rb") as file:
                return pickle.load(file)
        else:
            return dict()
    if type is 2:
        if os.path.isfile(IDdata_filename):
            with open(IDdata_filename, "rb") as file:
                return pickle.load(file)
        else:
            return dict()
    
def load_member_data(member_ID,type):
    data = load_data(type)
    if type is 0:
        if member_ID not in data:
            return GamzaData(0, 0, 0, 0, 0)
        return data[member_ID]
    if type is 1:
        if member_ID not in data:
            return StarData(0, 0, 0, 0, 0)
        return data[member_ID]
    if type is 2:
        if member_ID not in data:
            return IDData(0,"NON")
        return data[member_ID]
def save_member_data(member_ID, member_data,type):
    data = load_data(type)
    if type is 0:
        data[member_ID] = member_data
        with open(Gamzadata_filename, "wb") as file:
            pickle.dump(data, file)
    if type is 1:
        data[member_ID] = member_data
        with open(StarBytedata_filename, "wb") as file:
            pickle.dump(data, file)
    if type is 2:
        data[member_ID] = member_data
        with open(IDdata_filename, "wb") as file:
            pickle.dump(data, file)

