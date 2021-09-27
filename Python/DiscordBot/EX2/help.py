import discord

from discord.ext import commands
cli = commands.Bot(command_prefix = ">")
cli.remove_command("help")

@cli.event
async def on_ready():
    print("bot start")
@cli.group(invoke_without_command = True)
async def help(ctx):
    print("help")
    em = discord.Embed(title = "Help",description = "Use $help <command> for extended information",inline = False,color = 0x8dceee)
    em.add_field(name="기능성(Utility)",value="ping",inline = False)
    em.add_field(name="놀이용(Fun)",value="game(추가예정),money,beg,work,hello,parrot",inline = False)
    em.add_field(name="관리용(Moderation)",value="NON",inline = False)
    await ctx.send(embed = em)
@help.command()
async def ping(ctx):
    print("help ping")
    em = discord.Embed(title = "Ping",description = "핑을 확인합니다")
    em.add_field(name="**문법**",value="$cmd ping")
    await ctx.send(embed = em)

cli.run('ODQ3MzgzOTQ1NjE0OTgzMTY4.YK9RzA.ifiZW0fHwsVcNDl--nb4camgc2M')