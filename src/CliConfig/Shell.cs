using System.Diagnostics;
using System.Threading.Tasks;

namespace CliConfig
{
    public static class Shell
    {
        public static async Task<(string output, string error)> Zsh(this string cmd)
        {
           
                var escapedCommandString = cmd.Replace("\"", "\\\"");

                var process = new Process()
                {
                    StartInfo = new ProcessStartInfo
                    {
                        FileName = "/usr/bin/env",
                        Arguments = $"zsh -c \"{escapedCommandString}\"",
                        RedirectStandardOutput = true,
                        RedirectStandardError = true,
                        UseShellExecute = false,
                        CreateNoWindow = true,
                    }
                };
                process.Start();
                string output =await  process.StandardOutput.ReadToEndAsync();
                string error = await process.StandardError.ReadToEndAsync();
                process.WaitForExit();
                return (output, error);
            
        }
    }
}