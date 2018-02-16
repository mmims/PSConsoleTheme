using System;

namespace PSConsoleTheme
{
    public sealed class ConsoleBufferException : Exception
    {
        public int ErrorCode { get; private set; }

        public ConsoleBufferException(int errorCode)
            : base(String.Format("Console buffer failed with error code {0}!", errorCode))
        {
            ErrorCode = errorCode;
        }
    }
}
