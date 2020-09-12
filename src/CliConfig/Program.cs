using System;
using System.IO;
using System.Reflection;
using System.Threading.Tasks;

namespace CliConfig
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var currentDirectory = Directory.GetCurrentDirectory();
            Console.WriteLine($"Starting execution at: '{currentDirectory}'");

            var command = $"echo 'lel'; ls '{currentDirectory}'";
            Console.WriteLine($"Executing: $ '{command}'");


            var response = await Shell.Zsh(command);
            Console.WriteLine("Execution finished");
            Console.WriteLine($"Output was: ---\n{response.output}\n---");
        }
    }
}
