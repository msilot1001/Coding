import datetime,pytz,discord.embeds,math,time,discord,discord.member,discord.user,discord.role,random,pickle,os
from typing import Optional
from discord.ext import commands



#변수


bot = commands.Bot(command_prefix='$')
bot.remove_command("help")
data_filename = "data.pickle"
class Data:
    def __init__(self, wallet, bank, gametoken, gametry, gamewin):
        self.wallet = wallet
        self.bank = bank
        self.gametoken = gametoken
        self.gametry = gametry
        self.gamewin = gamewin



#이벤트


@bot.event
async def on_ready():#봇 실행
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]",": Logged as",bot.user.name,", ID : ",bot.user.id)
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]",": Bot Ready")
    await bot.change_presence(status=discord.Status.online, activity=discord.Game("명령어는 $help"))
@bot.event
async def on_command_error(ctx, error):
    if isinstance(error, commands.CommandOnCooldown):
        msg = '**쿨타임**이 {:.2f}초 남았습니다'.format(error.retry_after) 
        await ctx.send(msg)


#커맨드


@bot.command()
async def resetstats(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"resetstats \" Command Detected")
    member_data = load_member_data(ctx.author.id)
    member_data.bank = 0
    member_data.wallet = 0
    member_data.gametoken = 0
    member_data.gametry = 0
    member_data.gamewin = 0
    save_member_data(ctx.author.id, member_data)
    em = discord.Embed(title = "사용자 정보가 리셋되었습니다",description = "리셋된 정보는 복구될수 없습니다")
    await ctx.send(embed = em)

@bot.group(invoke_without_command = True)
async def game(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"game \" Command Detected")
    member_data = load_member_data(ctx.author.id)
    em = discord.Embed(title = f"{ctx.author.name}님의 게임정보")
    em.add_field(name="게임토큰:",value=f"{member_data.gametoken}개",inline=False)
    em.add_field(name="게임횟수:",value=f"{member_data.gametry}개")
    em.add_field(name="우승횟수:",value=f"{member_data.gamewin}개")
    winrate = 0
    try:
        result = int(member_data.gametry)/int(member_data.gamewin)
        winrate = result
    except ZeroDivisionError:
        winrate = "NON"
    em.add_field(name="승률:",value=f"{str(winrate)}%")
    await ctx.send(embed = em)
@game.command()
async def dice(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"game dice \" Command Detected")
    embed = discord.Embed(title = ':smiley: 주사위!', timestamp=datetime.datetime.now(pytz.timezone('UTC')), description = random.randrange(1,7),color = 0x8dceee)
    await ctx.send(embed = embed)


    #command

    
@bot.command() #핑(ping) 커맨드
async def ping(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"ping\" Command Detected")
    embed = discord.Embed(title = ':ping_pong: 퐁!', timestamp=datetime.datetime.now(pytz.timezone('UTC')), description = str(math.floor(bot.latency * 1000)) + 'ms', color = 0x8dceee)
    await ctx.send(embed = embed)
@bot.command()#앵무새(parrot) 커맨드
async def parrot(ctx,text):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"parrot\" Command Detected")
    embed = discord.Embed(title = ':bird:따라하기무새!', timestamp=datetime.datetime.now(pytz.timezone('UTC')), description = text, color = 0x8dceee)
    await ctx.send(embed = embed)
@bot.command()
async def userinfo(ctx, member: discord.Member):
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"userinfo\" Command Detected")
    roles = [role for role in member.roles]
    embed = discord.Embed(timestamp=ctx.message.created_at, color = member.color)
    embed.set_author(name=f"User Info {member}")
    embed.set_thumbnail(url=member.avatar_url)
    embed.set_footer(text=f"Requested by {ctx.author}" , icon_url=ctx.author.avatar_url)
    embed.add_field(name="ID:",value=member.id)
    embed.add_field(name="Nickname:",value=member.display_name)
    embed.add_field(name="Created at:",value=member.created_at.strftime(f"%Y %B %#d , %I:%M %p UTC"))
    embed.add_field(name=f"Roles ({len(roles)})",value="   ".join([role.mention for role in roles]))
    embed.add_field(name="Top role:", value=member.top_role.mention)
    embed.add_field(name="Bot?",value= member.bot)
    embed.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    embed.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = embed) 



#help


@bot.group(invoke_without_command = True)
async def help(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"help \" Command Detected")
    print("help")
    em = discord.Embed(title = "Help",description = "Use $help <command> for extended information",inline = False,color = 0x8dceee)
    em.add_field(name="기능성(Utility)",value="`ping`",inline = False)
    em.add_field(name="놀이용(Fun)",value="`game(추가예정)`,`money`,`beg`,`work`,`hello`,`parrot`",inline = False)
    em.add_field(name="관리용(Moderation)",value="`NON`",inline = False)
    em.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    em.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = em)
@help.command()
async def ping(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"help ping\" Command Detected")
    print("help ping")
    em = discord.Embed(title = "Ping",description = "핑을 확인합니다",color = 0x8dceee)
    em.add_field(name="**문법**",value="$cmd ping")
    em.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    em.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = em)
@help.command()
async def game(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"help ping\" Command Detected")
    print("help ping")
    em = discord.Embed(title = "Ping",description = "핑을 확인합니다",color = 0x8dceee)
    em.add_field(name="**문법**",value="$cmd ping")
    em.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    em.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = em)
@help.command()
async def parrot(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"help ping\" Command Detected")
    print("help ping")
    em = discord.Embed(title = "Ping",description = "핑을 확인합니다",color = 0x8dceee)
    em.add_field(name="**문법**",value="$cmd ping")
    em.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    em.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = em)
@help.command()
async def userinfo(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"help ping\" Command Detected")
    print("help ping")
    em = discord.Embed(title = "Ping",description = "핑을 확인합니다",color = 0x8dceee)
    em.add_field(name="**문법**",value="$cmd ping")
    em.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    em.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = em)
@help.command()
async def work(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"help ping\" Command Detected")
    print("help ping")
    em = discord.Embed(title = "Ping",description = "핑을 확인합니다",color = 0x8dceee)
    em.add_field(name="**문법**",value="$cmd ping")
    em.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    em.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = em)
@help.command()
async def money(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"help ping\" Command Detected")
    print("help ping")
    em = discord.Embed(title = "Ping",description = "핑을 확인합니다",color = 0x8dceee)
    em.add_field(name="**문법**",value="$cmd ping")
    em.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    em.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = em)
@help.command()
async def beg(ctx):
    tm = gettime()
    print(f"[ {tm.tm_hour+9} : {tm.tm_min} : {tm.tm_sec} ] : \"help ping\" Command Detected")
    print("help ping")
    em = discord.Embed(title = "Beg",description = "핑을 확인합니다",color = 0x8dceee)
    em.add_field(name="**문법**",value="$cmd ping")
    em.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    em.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = em)


#함수


def gettime():
    timesec = time.time()
    tm = time.gmtime(timesec)
    return tm
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

bot.run('ODQ3MzgzOTQ1NjE0OTgzMTY4.YK9RzA.ifiZW0fHwsVcNDl--nb4camgc2M')

#embed.add_field(name="$botsetting changestatus [상태메세지]", value="봇의 상태메세지를 바꿉니다", inline=False)
#embed.add_field(name="$help", value="명령어 목록", inline=False)
#embed.add_field(name="$userinfo [사용자이름]", value="사용자의 정보를 안내합니다", inline=False)
#embed.add_field(name="$ping", value="현재 핑", inline=False)
#embed.add_field(name="$parrot", value="감자가 말을 따라합니다", inline=False)
#embed.add_field(name="$hello", value="감자가 인사합니다", inline=False)
#embed.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
#embed.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")