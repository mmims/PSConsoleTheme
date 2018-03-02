param (
    [string]$Configuration = (property 'Configuration' 'Release')
)

use * MSBuild

function New-DebugTarget ([int]$length = 8) {
    do {
        $ranDir = -join ((48..57) + (97..122) | Get-Random -Count $length | ForEach-Object { [char]$_ })
        $newDir = Join-Path $BuildRoot "module/$Configuration/$ranDir/PSConsoleTheme"
    } while (Test-Path $newDir)
    $newDir
}

$targetDir = "module/$Configuration/PSConsoleTheme"
if ($Configuration -eq 'Debug') {
    if ($Global:PSConsoleThemeDebugSessionPath -and (Test-Path $Global:PSConsoleThemeDebugSessionPath)) {
        $targetDir = $Global:PSConsoleThemeDebugSessionPath
        $Script:libraryChanged = $false
    } else {
        $Global:PSConsoleThemeDebugSessionPath = $targetDir = New-DebugTarget
        $Script:libraryChanged = $true
    }
}

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

task Install {
    switch ($Configuration) {
        Debug {
            Remove-Module PSConsoleTheme -Force -ErrorAction Ignore
            Import-Module (Join-Path $Global:PSConsoleThemeDebugSessionPath 'PSConsoleTheme.psd1') -Force
        }
        Release {
            $paths = $env:PSModulePath -split ';' | Where-Object { $_ -like "${env:USERPROFILE}*" }
            foreach ($path in $paths) {
                if (!(Test-Path $paths)) {
                    New-Item $path -ItemType Directory -Force | Out-Null
                }

                try {
                    if (Test-Path "$path\PSConsoleTheme") {
                        Remove-Item "$path\PSConsoleTheme" -Recurse -Force -ErrorAction Stop
                    }
                    Copy-Item $targetDir $path -Recurse
                }
                catch {
                    Write-Error "Cannot install to $path. Module might be in use."
                }
            }
        }
    }
}

$layoutModuleParams = @{
    Inputs = {
        Get-ChildItem `
            PSConsoleTheme/Lib/bin/$Configuration/PSConsoleTheme.dll, # needs to be processed before module manifest (.psd1)
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

        if ((Split-Path $_ -Leaf) -eq 'psconsoletheme.dll') {
            if ($Configuration -eq 'Debug' -and ($Script:libraryChanged = !$Script:libraryChanged)) { continue }
            $manifestFile = 'PSConsoleTheme/PSConsoleTheme.psd1'
            $version = (Get-ChildItem $_).VersionInfo.FileVersion
            $manifestContent = Get-Content -Path $manifestFile -Raw

            $manifestContent = [regex]::Replace($manifestContent, "ModuleVersion = '.*'", "ModuleVersion = '$version'")
            Write-Host "Updating version information in manifest: $manifestFile"
            $manifestContent | Set-Content -Path $manifestFile -Encoding UTF8 -NoNewline
        }

        Write-Verbose "Copying $($_ -replace [regex]::Escape($BuildRoot + '\'), '') -> $($2 -replace [regex]::Escape($BuildRoot + '\'), '')"
        Copy-Item $_ $2 -Force
    }
}, AfterLayoutModule

task AfterLayoutModule -If {$Configuration -eq 'Debug' -and $Script:libraryChanged} {
    $Global:PSConsoleThemeDebugSessionPath = New-DebugTarget
    throw "Build changes require a new target directory. Please rerun `Invoke-Build`."
}

# Synopsis: Create an archive of the module for release
task ZipRelease -If ($Configuration -eq 'Release') LayoutModule, {
    Compress-Archive $targetDir -DestinationPath ((Split-Path $targetDir) + '/PSConsoleTheme.zip') -Force
}

task . LayoutModule