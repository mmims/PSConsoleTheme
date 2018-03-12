param (
    [ValidateSet('Release','Debug')]
    [string]$Configuration = (property 'Configuration' 'Release'),
    [string]$NuGetApiKey = (property 'NuGetApiKey' '')
)

$targetDir = Join-Path $BuildRoot "module/$Configuration/PSConsoleTheme"
if ($Configuration -eq 'Debug') {
    $Global:PSConsoleThemeDebugSessionPath = $targetDir
}

$mamlHelpParams = @{
    Inputs = (Get-ChildItem docs/*.md -Exclude about_*.md)
    Outputs = (Join-Path $targetDir 'en-US/PSConsoleTheme-help.xml')
}

# Synopsis: Build external help file from markdown documentation
task BuildMamlHelp @mamlHelpParams -If ($Configuration -eq 'Release') {
    PlatyPS\New-ExternalHelp -Path docs -OutputPath $targetDir\en-US\PSConsoleTheme-help.xml -Force
}

# Synopsis: Remove all build related artifacts
task Clean {
    Remove-Item module -Recurse -Force -ErrorAction Ignore
}

# Synopsis: Import the module for use in the current session
task Install LayoutModule, {
    switch ($Configuration) {
        Debug {
            Remove-Module PSConsoleTheme -Force -ErrorAction Ignore
            Import-Module (Join-Path $targetDir 'PSConsoleTheme.psd1') -Force
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
            PSConsoleTheme/*.ps*,
            PSConsoleTheme/Private/*.ps1,
            PSConsoleTheme/Public/*.ps1,
            PSConsoleTheme/Themes/*.json
    }
    Outputs = {
        process {
            Join-Path $targetDir ($_ -replace [regex]::Escape($BuildRoot + '\PSConsoleTheme\'), '')
        }
    }
}

# Synopsis: Copy all of the files that belong in the module to one place for installation
task LayoutModule -Partial @layoutModuleParams BuildMamlHelp, {
    process {
        if (-Not (Test-Path (Split-Path $2) -PathType Container)) {
            New-Item (Split-Path $2) -ItemType Directory -Force | Out-Null
        }
            Write-Verbose "Copying $($_ -replace [regex]::Escape($BuildRoot + '\'), '') -> $($2 -replace [regex]::Escape($BuildRoot + '\'), '')"
            Copy-Item $_ $2 -Force
        }
    }

# Synopsis: Publish the module to PSGallery
task Publish -If ($Configuration -eq 'Release') {
    if ($NuGetApiKey -eq '') {
        throw "Cannot publish. NuGet API key not set."
    }

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