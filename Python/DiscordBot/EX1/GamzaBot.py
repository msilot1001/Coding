import discord
import time
import asyncio
import datetime
import pytz



client = discord.Client()

@client.event
async def on_ready(): # 봇이 실행되면 한 번 실행됨
    timesec = time.time()
    tm = time.gmtime(timesec)
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]","봇 준비중..")
    await client.change_presence(status=discord.Status.online, activity=discord.Game("테스트중"))

@client.event
async def on_message(message):
    timesec = time.time()
    tm = time.gmtime(timesec)
    print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]","메세지 감지")
    if message.content == "/test": # 메세지 감지
        await message.channel.send ("{} | {}, Hello".format(message.author, message.author.mention))
        await message.author.send ("{}, User, Hello".format(message.author.mention))
    
    if message.content == "특정입력":
        ch = client.get_channel(847469532535980052)
        await ch.send ("{} | {}, User, Hello".format(ch.author, ch.author.mention))


# 봇을 실행시키기 위한 토큰을 작성해주는 곳
timesec = time.time()
tm = time.gmtime(timesec)
print("[",tm.tm_hour+9,":",tm.tm_min,":",tm.tm_sec,"]","봇 실행")
