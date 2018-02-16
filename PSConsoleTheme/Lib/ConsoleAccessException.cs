using System;

namespace PSConsoleTheme
{
    public sealed class ConsoleAccessException : Exception
    {
        public ConsoleAccessException()
            : base(String.Format("Console handle not found."))
        {
        }
    }
}
