using Discord;
using Discord.Commands;
using Discord.WebSocket;
using System;
using System.Threading.Tasks;
using System.Reflection;

namespace DiscordBot1
{
    class Program
    {
        DiscordSocketClient client; //봇 클라이언트
        CommandService commands;

        MainModule mainModule = new MainModule();
        //명령어 수신 클라이언트
        /// <summary>
        /// 프로그램의 진입점
        /// </summary>
        /// <param name="args"></param>
        static void Main(string[] args)
        {
            new Program().BotMain().GetAwaiter().GetResult();   //봇의 진입점 실행
        }

        public async Task BotMain()
        {
            //디스코드 봇 초기화
            client = new DiscordSocketClient(new DiscordSocketConfig() { LogLevel = LogSeverity.Verbose /*봇의 로그 레벨 설정*/ });
            //명령어 수신 클라이언트 초기화
            commands = new CommandService(new CommandServiceConfig() { LogLevel = LogSeverity.Verbose /*봇의 로그 레벨 설정*/ });

            //로그 수신 시 로그 출력 함수에서 출력되도록 설정
            client.Log += OnClientLogReceived;
            commands.Log += OnClientLogReceived;

            string path = @"C:\Coding\Discord\DiscordBot1\token.txt";
            string textval = System.IO.File.ReadAllText(path);
            Console.WriteLine(path);

            await client.LoginAsync(TokenType.Bot, textval); //봇의 토큰을 사용해 서버에 로그인
            await client.StartAsync();                         //봇이 이벤트를 수신하기 시작

            client.MessageReceived += OnClientMessage;         //봇이 메시지를 수신할 때 처리하도록 설정

            await commands.AddModulesAsync(assembly: Assembly.GetEntryAssembly(), services: null);  //봇에 명령어 모듈 등록

            await Task.Delay(-1);   //봇이 종료되지 않도록 블로킹
        }

        private async Task OnClientMessage(SocketMessage arg)
        {
            //수신한 메시지가 사용자가 보낸 게 아닐 때 취소
            var message = arg as SocketUserMessage;
            if (message == null) return;

            int pos = 0;

            //메시지 앞에 !이 달려있지 않고, 자신이 호출된게 아니거나 다른 봇이 호출했다면 취소
            if (!(message.HasCharPrefix(';', ref pos) ||
             message.HasMentionPrefix(client.CurrentUser, ref pos)) ||
              message.Author.IsBot)
                return;

            var context = new SocketCommandContext(client, message);                    //수신된 메시지에 대한 컨텍스트 생성   

            var result = await commands.ExecuteAsync(
                context: context,
                argPos: pos,
                services: null);    
        }

        private Task OnClientLogReceived(LogMessage msg)
        {
            Console.WriteLine(msg.ToString());  //로그 출력
            return Task.CompletedTask;
        }
    }
}
