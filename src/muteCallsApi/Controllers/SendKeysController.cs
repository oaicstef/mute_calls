using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace MuteTeamsApi.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class SendKeysController : ControllerBase
    {
        private readonly ILogger<SendKeysController> _logger;
        private static bool muteStatus = false;

        public SendKeysController(ILogger<SendKeysController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "SendKeysToMuteUnMuteTeams")]
        public string Get(VideoCallToolEnum callTool)
        {
            Process? curProcess = null;
            foreach (var process in Process.GetProcesses())
            {
                if (process.ProcessName.Contains(callTool.ToString()))
                {
                    curProcess = process;
                    break;
                }
            }

            if (curProcess == null)
                return $"{callTool} is not running";
            string output = string.Empty;
            string input = string.Empty;
            string error = string.Empty;
            using (var processSendKeys = new Process())
            {
                var keysComb = string.Empty;
                switch (callTool)
                {
                    default:
                    case VideoCallToolEnum.Teams:
                        keysComb = "^+(m)";
                        break;
                    case VideoCallToolEnum.Zoom:
                        keysComb = "^+(m)";
                        break;
                    case VideoCallToolEnum.GoogleMeet:
                        keysComb = "^(d)";
                        break;
                }
                var startInfo = new ProcessStartInfo("SendKeys.exe");
                startInfo.UseShellExecute = false;
                startInfo.RedirectStandardOutput = true;
                startInfo.RedirectStandardError = true;
                startInfo.RedirectStandardInput = true;
                startInfo.Arguments = $"-pid:{curProcess.Id} \"{keysComb}\"";
                processSendKeys.StartInfo = startInfo;
                var result = processSendKeys.Start();
                processSendKeys.Close();
            }
            muteStatus = !muteStatus;
            return $"Keys sent - Status is {muteStatus}";
        }
    }
}