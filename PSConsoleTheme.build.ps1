param (
    [ValidateSet('Release','Debug')]
    [string]$Configuration = (property 'Configuration' 'Release'),
    [string]$NuGetApiKey = (property 'NuGetApiKey' '')
)

use * MSBuild

function New-DebugTarget ([int]$length = 8) {
    do {
        $ranDir = -join ((48..57) + (97..122) | Get-Random -Count $length | ForEach-Object { [char]$_ })
        $newDir = Join-Path $BuildRoot "module/$Configuration/$ranDir/PSConsoleTheme"
    } while (Test-Path $newDir)
    $newDir
}

$targetDir = Join-Path $BuildRoot "module/$Configuration/PSConsoleTheme"
if ($Configuration -eq 'Debug') {
    if ($Global:PSConsoleThemeDebugSessionPath -and (Test-Path $Global:PSConsoleThemeDebugSessionPath)) {
        $targetDir = $Global:PSConsoleThemeDebugSessionPath
    } else {
        $Global:PSConsoleThemeDebugSessionPath = $targetDir = New-DebugTarget
    }
}

$binaryModuleParams = @{
    Inputs = { Get-ChildItem PSConsoleTheme/Lib/*.cs, PSConsoleTheme/Lib/Properties/*.cs, PSConsoleTheme/Lib/PSConsoleTheme.csproj, PSConsoleTheme/Lib/PSConsoleTheme.sln }
    Outputs = "PSConsoleTheme/Lib/bin/$Configuration/PSConsoleTheme.dll"
}

# Synopsis: Build the binary library used by the module
task BuildBinaryModule @binaryModuleParams {
    exec { MSBuild 'PSConsoleTheme/Lib/PSConsoleTheme.csproj' /t:Rebuild /p:Configuration=$Configuration /p:Platform=AnyCPU }

    $manifestFile = 'PSConsoleTheme/PSConsoleTheme.psd1'
    $version = (Get-ChildItem "PSConsoleTheme/Lib/bin/$Configuration/PSConsoleTheme.dll").VersionInfo.FileVersion
    $manifestContent = Get-Content -Path $manifestFile -Raw

    $manifestContent = [regex]::Replace($manifestContent, "ModuleVersion = '.*'", "ModuleVersion = '$version'")
    Write-Host "Updating version information in manifest: $manifestFile"
    $manifestContent | Set-Content -Path $manifestFile -Encoding UTF8 -NoNewline
}

$mamlHelpParams = @{
    Inputs = (Get-ChildItem docs/*.md -Exclude about_*.md)
    Outputs = (Join-Path $targetDir 'en-US/PSConsoleTheme-help.xml')
}

task BuildMamlHelp @mamlHelpParams {
    PlatyPS\New-ExternalHelp -Path docs -OutputPath $targetDir\en-US\PSConsoleTheme-help.xml -Force
}

# Synopsis: Remove all build related artifacts
task Clean {
    Get-ChildItem PSConsoleTheme/Lib -Include bin, obj -Recurse | Remove-Item -Recurse -Force -ErrorAction Ignore
    Remove-Item module -Recurse -Force -ErrorAction Ignore
}

task Install LayoutModule, {
    switch ($Configuration) {
        Debug {
            Remove-Module PSConsoleTheme -Force -ErrorAction Ignore
            Import-Module (Join-Path ${Global:PSConsoleThemeDebugSessionPath} 'PSConsoleTheme.psd1') -Force
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
            if ((Split-Path $_ -Leaf) -eq 'psconsoletheme.dll') {
                Join-Path $targetDir (Split-Path $_ -Leaf)
            } else {
                Join-Path $targetDir ($_ -replace [regex]::Escape($BuildRoot + '\PSConsoleTheme\'), '')
            }
        }
    }
}

# Synopsis: Copy all of the files that belong in the module to one place for installation
task LayoutModule -Partial @layoutModuleParams BuildBinaryModule, BuildMamlHelp, {
    process {
        if (-Not (Test-Path (Split-Path $2) -PathType Container)) {
            New-Item (Split-Path $2) -ItemType Directory -Force | Out-Null
        }

        if ((Split-Path $_ -Leaf) -eq 'psconsoletheme.dll') {
            Write-Verbose "Copying $($_ -replace [regex]::Escape($BuildRoot + '\'), '') -> $($2 -replace [regex]::Escape($BuildRoot + '\'), '')"
            try {
                Copy-Item $_ $2 -Force -ErrorAction Stop   
            }
            catch {
                if ($Configuration -eq 'Debug') {
                    $Global:PSConsoleThemeDebugSessionPath = New-DebugTarget
                    throw "Build changes require a new target directory. Please rerun `Invoke-Build`."
                }
            }
        } else {
            Write-Verbose "Copying $($_ -replace [regex]::Escape($BuildRoot + '\'), '') -> $($2 -replace [regex]::Escape($BuildRoot + '\'), '')"
            Copy-Item $_ $2 -Force
        }
    }
}

task Publish -If ($Configuration -eq 'Release') {
    $publishParams = @{
        Path = $targetDir
        NuGetApiKey = $NuGetApiKey
        Repository = 'PSGallery'
        ProjectUri = 'https://github.com/mmims/PSConsoleTheme'
        LicenseUri = 'https://github.com/mmims/PSConsoleTheme/blob/master/LICENSE'
        Tags = @('Windows', 'Color', 'Console')
    }

    Publish-Module @publishParams
}

# Synopsis: Create an archive of the module for release
task ZipRelease -If ($Configuration -eq 'Release') LayoutModule, {
    Compress-Archive $targetDir -DestinationPath ((Split-Path $targetDir) + '/PSConsoleTheme.zip') -Force
}

task . LayoutModule