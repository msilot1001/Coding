# 파이썬의 기본 내장 함수가 아닌 다른 함수 혹은 다른 기능이 필요할 때 사용함
import discord, asyncio, datetime, pytz

client = discord.Client()

@client.event
async def on_ready(): # 봇이 실행되면 한 번 실행됨
    print("이 문장은 Python의 내장 함수를 출력하는 터미널에서 실행됩니다\n지금 보이는 것 처럼 말이죠")
    await client.change_presence(status=discord.Status.online, activity=discord.Game("봇의 상태매세지"))

@client.event
async def on_message(message):#메세지 감지
    if message.content == "테스트": #"테스트" 감지
        await message.channel.send ("{} | {}, Hello".format(message.author, message.author.mention))
        await message.author.send ("{} | {}, User, Hello".format(message.author, message.author.mention))

    if message.content == "특정입력":#"특정입력" 감지
        ch = client.get_channel(848896838920830997)
        await ch.send ("{} | {}, User, Hello".format(ch.author, ch.author.mention))

    if message.content == "임베드": # "임베드" 감지
        embed = discord.Embed(title="제목", description="부제목",timestamp=datetime.datetime.now(pytz.timezone('UTC')), color=0x8dceee)

        embed.add_field(name="임베드 라인 1 - inline = false로 책정", value="라인 이름에 해당하는 값", inline=False)
        embed.add_field(name="임베드 라인 2 - inline = false로 책정", value="라인 이름에 해당하는 값", inline=False)

        embed.add_field(name="임베드 라인 3 - inline = true로 책정", value="라인 이름에 해당하는 값", inline=True)
        embed.add_field(name="임베드 라인 4 - inline = true로 책정", value="라인 이름에 해당하는 값", inline=True)

        embed.set_footer(text="Bot Made by. GamzaBotu#1402", icon_url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
        embed.set_thumbnail(url="https://cdn.discordapp.com/attachments/847469532535980052/848559221767143424/2.jpg")
        await message.channel.send (embed=embed)


# 봇을 실행시키기 위한 토큰을 작성해주는 곳
client.run('ODQ3MzgzOTQ1NjE0OTgzMTY4.YK9RzA.ifiZW0fHwsVcNDl--nb4camgc2M')