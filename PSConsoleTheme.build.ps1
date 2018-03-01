param (
    [string]$Configuration = (property Configuration Release)
)

use * MSBuild

$targetDir = "module/$Configuration/PSConsoleTheme"

$binaryModuleParams = @{
    Inputs = { Get-ChildItem PSConsoleTheme/Lib/*.cs, PSConsoleTheme/Lib/Properties/*.cs, PSConsoleTheme/Lib/PSConsoleTheme.csproj, PSConsoleTheme/Lib/PSConsoleTheme.sln }
    Outputs = "PSConsoleTheme/Lib/bin/$Configuration/PSConsoleTheme.dll"
}

# Synopsis: Build the binary library used by the module
task BuildBinaryModule @binaryModuleParams {
    exec { MSBuild 'PSConsoleTheme/Lib/PSConsoleTheme.csproj' /t:Rebuild /p:Configuration=$Configuration /p:Platform=AnyCPU }
}

# Synopsis: Remove all build related artifacts
task Clean {
    Get-ChildItem PSConsoleTheme/Lib -Include bin, obj -Recurse | Remove-Item -Recurse -Force -ErrorAction Ignore
    Remove-Item module -Recurse -Force -ErrorAction Ignore
}

$layoutModuleParams = @{
    Inputs = {
        Get-ChildItem `
            PSConsoleTheme/Lib/bin/$Configuration/PSConsoleTheme.dll,
            PSConsoleTheme/*.ps*,
            PSConsoleTheme/Private/*.ps1,
            PSConsoleTheme/Public/*.ps1,
            PSConsoleTheme/Themes/*.json
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

        if ((Split-Path $_ -Leaf) -ieq 'psconsoletheme.dll') {
            $manifestFile = 'PSConsoleTheme/PSConsoleTheme.psd1'
            $version = (Get-ChildItem $_).VersionInfo.FileVersion
            $manifestContent = Get-Content -Path $manifestFile -Raw

            $manifestContent = [regex]::Replace($manifestContent, "ModuleVersion = '.*'", "ModuleVersion = '$version'")
            Write-Host "Updating version information in manifest: $manifestFile"
            $manifestContent | Set-Content -Path $manifestFile -Encoding UTF8 -NoNewline
        }

        Write-Host "Copying $($_ -replace [regex]::Escape($BuildRoot + '\'), '') -> $2"
        Copy-Item $_ $2 -Force
    }
}

# Synopsis: Create an archive of the module for release
task ZipRelease LayoutModule, {
    Compress-Archive $targetDir -DestinationPath ((Split-Path $targetDir) + '/PSConsoleTheme.zip') -Force
}

task . LayoutModule