import datetime,pytz,discord.embeds,math,time,discord,discord.member,discord.user,discord.role

from discord.ext import commands

bot = commands.Bot(command_prefix='$')

def gettime():
    timesec = time.time()
    tm = time.gmtime(timesec)
    return tm

@bot.event
async def on_ready():#봇 실행
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]",": Logged as",bot.user.name,", ID : ",bot.user.id)
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]",": Bot Ready")
    await bot.change_presence(status=discord.Status.online, activity=discord.Game("테스트"))

@bot.command()#봇세팅(botsetting) 커맨드
@commands.has_role("Operator")
async def botsetting(ctx,text,status):
    
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"botstatus\" Command Detected")
    if str(text) == "changestatus":
        embed = discord.Embed(title = f'상태메세지가 \"{status}\"로 변경되었습니다', timestamp=datetime.datetime.now(pytz.timezone('UTC')), color = 0x8dceee)
        await bot.change_presence(activity=discord.Game(status))
        await ctx.send(embed = embed)

@bot.command()
async def game(ctx):
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"game\" Command Detected")
    

@bot.command() #핑(ping) 커맨드
async def ping(ctx):
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"ping\" Command Detected")
    embed = discord.Embed(title = ':ping_pong: 퐁!', timestamp=datetime.datetime.now(pytz.timezone('UTC')), description = str(math.floor(bot.latency * 1000)) + 'ms', color = 0x8dceee)
    await ctx.send(embed = embed)

@bot.command()#앵무새(parrot) 커맨드
async def parrot(ctx,text):
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"parrot\" Command Detected")
    embed = discord.Embed(title = ':bird:따라하기무새!', timestamp=datetime.datetime.now(pytz.timezone('UTC')), description = text, color = 0x8dceee)
    await ctx.send(embed = embed)

@bot.command()#인사(hello) 커맨드
async def hello(ctx):
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"hello\" Command Detected")
    embed = discord.Embed(title = ':grinning:안뇽!', timestamp=datetime.datetime.now(pytz.timezone('UTC')), description = "반갑다 감자!", color = 0x8dceee)
    await ctx.send(embed = embed)

@bot.command()#명령어 목록(list) 커맨드
async def list(ctx):
    tm = gettime()
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]"," : \"list\" Command Detected")
    embed = discord.Embed(title = ':question:도움말', timestamp=datetime.datetime.now(pytz.timezone('UTC')), description = "명령어 리스트",color = 0x8dceee)
    embed.add_field(name="$botsetting changestatus [상태메세지]", value="봇의 상태메세지를 바꿉니다", inline=False)
    embed.add_field(name="$help", value="명령어 목록", inline=False)
    embed.add_field(name="$userinfo [사용자이름]", value="사용자의 정보를 안내합니다", inline=False)
    embed.add_field(name="$ping", value="현재 핑", inline=False)
    embed.add_field(name="$parrot", value="감자가 말을 따라합니다", inline=False)
    embed.add_field(name="$hello", value="감자가 인사합니다", inline=False)
    embed.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    embed.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
    await ctx.send(embed = embed)

@bot.command()
async def server(ctx):
    tm = gettime()
    embed = discord.Embed(timestamp=ctx.message.created_at, color = 0x8dceee)

@bot.command()
async def userinfo(ctx, member: discord.Member):
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
    await ctx.send(embed = embed) 




bot.run('ODQ3MzgzOTQ1NjE0OTgzMTY4.YK9RzA.ifiZW0fHwsVcNDl--nb4camgc2M')