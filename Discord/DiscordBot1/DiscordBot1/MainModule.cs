using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Discord;
using Discord.WebSocket;
using Discord.Commands;

namespace DiscordBot1
{
    public class MainModule : ModuleBase<SocketCommandContext>
    {
        [Command("repeat")]
        public async Task RepeatCommand(string value)
        {
            await Context.Channel.SendMessageAsync(value);
        }
    }
}
