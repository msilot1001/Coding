import discord
import discord.embeds

from discord.ext import commands

bot = commands.Bot(command_prefix='$')

@bot.event
async def on_ready():
    print("start")
    await bot.change_presence(status=discord.Status.online, activity=None)

@bot.command()
async def status(ctx):
    print("수사현황")
    embed = discord.Embed(title = f"수사현황",timestamp=ctx.message.created_at, color = 0x8dceee)
    embed.add_field(name="1차 퇴사사건 : 2021/05/31 12:52 pm",value="장난으로 이루어진 퇴사라고 생각됨",inline=False)
    embed.add_field(name="1차 재입사 : 2021/05/31 03:20 pm",value="장난으로 이루어진 퇴사라고 생각됨",inline=False)
    embed.add_field(name="여담:",value="1차 퇴사 전부터 조현준의 이름이 \"음악부 (근데 거의 퇴사함)\" 이었음",inline=False)
    embed.add_field(name="2차 퇴사사건 : 2021/06/02 10:44 am",value="장난으로 이루어진 퇴사라고 생각됨 및 무언가 뒤에 있을거라고 생각",inline=False)
    embed.add_field(name="2차 재입사 : 2021/06/03 07:59 pm",value="재초대",inline=False)
    embed.add_field(name="강제퇴장 : 2021/06/03 09:04 pm",value="새로운 비밀방이 있다는걸 알고 추방",inline=False)
    embed.add_field(name="비밀방 입장: 2021/06/03 09:37 pm ",value="새로운 비밀방 입장",inline=False)
    embed.add_field(name="비밀방 추방: 2021/06/03 09:40 pm 추정",value="도배 후 강제 퇴장",inline=False)
    await ctx.send(embed = embed)

bot.run('ODQ3MzgzOTQ1NjE0OTgzMTY4.YK9RzA.ifiZW0fHwsVcNDl--nb4camgc2M')