import discord,time,asyncio,os,pickle,random

from discord.ext import commands
client = commands.Bot(command_prefix="%")

data_filename = "data.pickle"
agree_filename = "agree.pickle"
class Data:
    def __init__(self, wallet, bank, gametoken, gametry, gamewin):
        self.wallet = wallet
        self.bank = bank
        self.gametoken = gametoken
        self.gametry = gametry
        self.gamewin = gamewin
class AgreeData:
    def __init__(self, agree):
        self.agree = agree







@client.event
async def on_command_error(ctx, error):
    if isinstance(error, commands.CommandOnCooldown):
        msg = '**쿨타임**이 {:.2f}초 남았습니다'.format(error.retry_after) 
        await ctx.send(msg)
@client.event
async def on_ready():#봇 실행
    tm = return_time()
    print(f"[ {tm} ] : Logged as {client.user.name}, ID : {client.user.id}")
    tm = return_time()
    print(f"[ {tm} ] : Bot Ready")
    await client.change_presence(status=discord.Status.online, activity=discord.Game("봇 개발"))

@client.command()
async def agree(ctx):
    tm = return_time()
    print(f"[ {tm} ] : \"%agree\" Command Detected")
    member_data = load_member_agreedata(ctx.author.id)
    em = discord.Embed(title = "사용자 정보 수집에 동의하십니까?(네,아니오):", description = "수집목록:사용자 아이디,사용자 이름,채팅 기록",color = 0xCF77CB)
    await ctx.send(embed = em)
    try:
        message = await client.wait_for("message", check=lambda m: m.author == ctx.author and m.channel == ctx.channel, timeout= 30.0)
    except asyncio.TimeoutError:
        em = discord.Embed(title = "시간이 초과되었습니다", description = "다시 시도해주세요",color = 0xCF77CB)
        await ctx.send(embed = em)
    else:
        if message.content.lower() == "네":
            timesec = time.time()
            tm = time.gmtime(timesec)
            em = discord.Embed(title = f"사용자 정보 수집에 동의하셨습니다", description = f"{tm.tm_year}년 {tm.tm_mon}월 {tm.tm_mday}일 {tm.tm_hour +9}시 {tm.tm_min}분 {tm.tm_sec}초",color = 0xCF77CB)
            await ctx.send(embed = em)
            member_data.agree = 1
            save_member_agreedata(ctx.author.id , member_data)
        if message.content.lower() == "아니오":
            em = discord.Embed(title = "동의하지 않으셨습니다", description = "다시 시도해주세요",color = 0xCF77CB)
            await ctx.send(embed = em)
@client.command()
async def resetstats(ctx):
    tm = return_time()
    print(f"[ {tm} ] : \"%resetstats\" Command Detected")
    data = load_member_data(ctx.author.id)
    agreedata = load_member_agreedata(ctx.author.id)
    #wallet, bank, gametoken, gametry, gamewin
    data.wallet = 0
    data.bank = 0
    data.gametoken = 0
    data.gametry = 0
    data.gamewin = 0
    agreedata.agree = 0
    save_member_data(ctx.author.id, data)
    save_member_agreedata(ctx.author.id, agreedata)
    em = discord.Embed(title = "정보가 초기화되었습니다", description = "이용약관도 다시 동의해주세요",color = 0xCF77CB)
    await ctx.send(embed = em)
@client.command()
@commands.cooldown(1,60,commands.BucketType.user)
async def work(message):
    tm = return_time()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"work\" Command Detected")
    member_data = load_member_data(message.author.id)
    member_data.wallet += 1
    await message.channel.send("일을 하여 500스타머니을 획득하였습니다")
    save_member_data(message.author.id, member_data)
@client.command()
async def money(message):
    tm = return_time()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"money\" Command Detected")
    member_data = load_member_data(message.author.id)
    embed = discord.Embed(title=f"{message.author.display_name}'s Balance")
    embed.add_field(name="Wallet", value=str(member_data.wallet))
    embed.add_field(name="bank", value=str(member_data.bank))
    await message.channel.send(embed=embed)
@client.command()
@commands.cooldown(5,300,commands.BucketType.user)
async def beg(message):
    tm = return_time()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"beg\" Command Detected")
    member_data = load_member_data(message.author.id)
    randvalue = random.randrange(1001)
    member_data.wallet += randvalue
    embed = discord.Embed(title=f"{randvalue}스타머니을 얻었습니다")
    await message.channel.send(embed=embed)
    save_member_data(message.author.id, member_data)

def return_time():
    timesec = time.time()
    tm = time.gmtime(timesec)
    result = f"{tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec}"
    return result
def load_data():
    if os.path.isfile(data_filename):
        with open(data_filename, "rb") as file:
            return pickle.load(file)
    else:
        return dict()
def load_member_data(member_ID):
    data = load_data()
    if member_ID not in data:
        return Data(0, 0, 0, 0, 0)
    return data[member_ID]
def save_member_data(member_ID, member_data):
    data = load_data()
    data[member_ID] = member_data
    with open(data_filename, "wb") as file:
        pickle.dump(data, file)

#{0} = false
#{1} = true
def load_agreedata():
    if os.path.isfile(agree_filename):
        with open(agree_filename, "rb") as file:
            return pickle.load(file)
    else:
        return dict()
def load_member_agreedata(member_ID):
    data = load_agreedata()
    if member_ID not in data:
        return AgreeData(0)
    return data[member_ID]
def save_member_agreedata(member_ID, member_data):
    data = load_agreedata()
    data[member_ID] = member_data
    with open(agree_filename, "wb") as file:
        pickle.dump(data, file)

def if_agreed(id):
    agreedata = load_member_agreedata(id)
    return agreedata.agree