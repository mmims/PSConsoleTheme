param (
    [string]$Configuration = (property Configuration Release)
)

use 14.0 MSBuild

$targetDir = "module/$Configuration/PSConsoleTheme"

$binaryModuleParams = @{
    Inputs = { Get-ChildItem PSConsoleTheme/Lib/*.cs, PSConsoleTheme/Lib/Properties/*.cs, PSConsoleTheme/Lib/PSConsoleTheme.csproj, PSConsoleTheme/Lib/PSConsoleTheme.sln }
    Outputs = "PSConsoleTheme/Lib/bin/$Configuration/PSConsoleTheme.dll"
}

# Synopsis: Build the binary library used by the module
task BuildBinaryModule @binaryModuleParams {
    exec { MSBuild 'PSConsoleTheme/Lib/PSConsoleTheme.csproj' /t:Rebuild /p:Configuration=$Configuration /p:Platform=AnyCPU }
}

$layoutModuleParams = @{
    Inputs = {
        Get-ChildItem `
            PSConsoleTheme/*.ps*,
            PSConsoleTheme/Private/*.ps1,
            PSConsoleTheme/Public/*.ps1,
            PSConsoleTheme/Themes/*.json,
            PSConsoleTheme/Lib/bin/$Configuration/PSConsoleTheme.dll,
            PSConsoleTheme/base16-themes-json/*.json
    }
    Outputs = {
        process {
            if ((Split-Path $_ -Leaf) -ieq 'psconsoletheme.dll') {
                Join-Path $targetDir (Split-Path $_ -Leaf)
            } else {
                Join-Path $targetDir ($_ -replace [regex]::Escape($BuildRoot + '\PSConsoleTheme\'), '')
            }
        }
    }
}

# Synopsis: Copy all of the files that belong in the module to one place for installation
task LayoutModule -Partial @layoutModuleParams BuildBinaryModule, {
    process {
        if (-Not (Test-Path (Split-Path $2) -PathType Container)) {
            New-Item (Split-Path $2) -ItemType Directory -Force | Out-Null
        }

        Write-Host "Copying $($_ -replace [regex]::Escape($BuildRoot + '\'), '') -> $2"
        Copy-Item $_ $2 -Force
    }
}

task . LayoutModule