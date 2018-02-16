using System.Runtime.InteropServices;

namespace PSConsoleTheme
{
    [StructLayout(LayoutKind.Sequential)]
    public struct COLORREF
    {
        private uint dwColor;

        internal COLORREF(uint r, uint g, uint b)
        {
            dwColor = r + (g << 8) + (b << 16);
        }

        public override string ToString()
        {
            return dwColor.ToString();
        }
    }
}
