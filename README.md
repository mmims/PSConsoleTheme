# PSConsoleTheme

PowerShell module to manage Windows console colors and PSReadline token colors.

![psconsoletheme](https://user-images.githubusercontent.com/534908/39327051-d7a2e86e-4964-11e8-8644-4f751ca5530f.gif)

## Install

The recommended method for installing PSConsoleTheme is to use PowerShellGet. After the module is installed, there are some additional configuration steps recommended.

### Installing from PowerShell Gallery

PowerShellGet is included in Windows 10 and [WMF 5.0+](https://www.microsoft.com/en-us/download/details.aspx?id=54616). If you are using PowerShell V4 or V3, you will need to install [PowerShellGet](https://www.microsoft.com/en-us/download/details.aspx?id=51451).

Once PowerShellGet has been installed, simply run:

```Powershell
Install-Module PSConsoleTheme
```

### Install PSReadline (Optional)

I would recommend using the PSReadline module for the best PowerShell console experience. This module is included by default on Windows 10 systems. If you are running an older Windows OS, follow the [installation](https://github.com/lzybkr/PSReadLine#installation) instructions from the PSReadline github repository.

### Post-Install Configuration

The last step is to edit your profile to import the PSConsoleTheme module. This step is optional, but highly recommended if you are also using the PSReadline module. If you are using the PSReadline module and ***do not*** add an import statement to your profile, the PSReadline token colors of your selected theme will ***not*** be configured when you start a new console session.

PowerShell provides multiple profiles that can be customized. Most users will want to edit the current user PowerShell profile. This profile can be found in the `$HOME\[My ]Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1` file.

You can open the profile in a PowerShell console using the following command:

```Powershell
notepad $PROFILE
```

Then add the following to the profile:

```powershell
Import-Module PSConsoleTheme
```

## Upgrading

To upgrade to the latest available version of PSConsoleTheme, simply run:

```powershell
Update-Module PSConsoleTheme
```

## Usage

To start using, just import the module (if it has not already been imported):

```powershell
Import-Module PSConsoleTheme
```

Check out the list of available themes:

```powershell
Get-ConsoleTheme -ListAvailable
```

Set your console colors to your chosen theme:

```powershell
Set-ConsoleTheme 'Classic Dark'
```

That's it! PSConsoleTheme will set the console color palette for all Windows console host applications (this includes cmd consoles) of the current user. PSConsoleTheme will also set the token foreground colors for PSReadline tokens if you're using a PowerShell console with PSReadline.
