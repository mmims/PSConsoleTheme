---
external help file: PSConsoleTheme-help.xml
Module Name: PSConsoleTheme
online version:
schema: 2.0.0
---

# Get-ConsoleTheme

## SYNOPSIS
Gets the current console theme or a list of available themes.

## SYNTAX

### ByName (Default)
```
Get-ConsoleTheme [[-Name] <String>] [-ShowColors] [<CommonParameters>]
```

### Available
```
Get-ConsoleTheme [-ListAvailable] [<CommonParameters>]
```

### Refresh
```
Get-ConsoleTheme [-Refresh] [<CommonParameters>]
```

## DESCRIPTION
The Get-ConsoleTheme cmdlet returns the attributes of console themes available in the PSConsoleTheme repository. Without parameters, Get-ConsoleTheme returns the currently loaded console theme. To get all installed themes, specify the ListAvailable parameter.

Available themes are loaded when the PSConsoleTheme module is imported. If themes are added, removed, or modified during a PowerShell session, the Refresh parameter can be specified to reload available themes. This is especially helpful when developing and testing new themes.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ConsoleTheme
```

Get the attributes of the currently loaded console theme.

### Example 2
```powershell
PS C:\> Get-ConsoleTheme 'Solarized Dark'
```

Get the attributes of the _Solarized Dark_ console theme.

### Example 3
```powershell
PS C:\> Get-ConsoleTheme -ListAvailable
```

List the name and description of all available console themes.

## PARAMETERS

### -ListAvailable
Indicates that this cmdlet gets all installed console themes.

```yaml
Type: SwitchParameter
Parameter Sets: Available
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the console theme this cmdlet gets. If not specified, the cmdlet returns the currently loaded console theme.

```yaml
Type: String
Parameter Sets: ByName
Aliases:
Accepted values: 3024, Apathy, Ashes, Atelier Cave, Atelier Cave Light, Atelier Dune, Atelier Dune Light, Atelier Estuary, Atelier Estuary Light, Atelier Forest, Atelier Forest Light, Atelier Heath, Atelier Heath Light, Atelier Lakeside, Atelier Lakeside Light, Atelier Plateau, Atelier Plateau Light, Atelier Savanna, Atelier Savanna Light, Atelier Seaside, Atelier Seaside Light, Atelier Sulphurpool, Atelier Sulphurpool Light, Bespin, Brewer, Bright, Brush Trees, Brush Trees Dark, Chalk, Chester, Circus, Classic Dark, Classic Light, Codeschool, Cupcake, Cupertino, Darktooth, Default Dark, Default Light, Dracula, Eighties, Embers, Flat, Github, Google Dark, Google Light, Grayscale Dark, Grayscale Light, Green Screen, Gruvbox dark, hard, Gruvbox dark, medium, Gruvbox dark, pale, Gruvbox dark, soft, Gruvbox light, hard, Gruvbox light, medium, Gruvbox light, soft, Harmonic16 Dark, Harmonic16 Light, Hopscotch, Icy Dark, IR Black, Isotope, London Tube, Macintosh, Marrakesh, Materia, Material, Material Darker, Material Lighter, Material Palenight, Mellow Purple, Mexico Light, Mocha, Monokai, Nord, Ocean, OceanicNext, One Light, OneDark, Paraiso, PhD, Pico, Pop, Porple, Railscasts, Rebecca, Redmond, Seti UI, Shapeshifter, Solar Flare, Solarized Dark, Solarized Light, Spacemacs, Summerfruit Dark, Summerfruit Light, Tomorrow, Tomorrow Night, Twilight, Unikitty Dark, Unikitty Light, Woodland, XCode Dusk, Zenburn

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Refresh
Indicates that this cmdlet reload available console themes.

```yaml
Type: SwitchParameter
Parameter Sets: Refresh
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowColors
Indicates that this cmdlet displays a table with the colors of the current console theme. If a theme name is specifed, this parameter is ignored.

```yaml
Type: SwitchParameter
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### PSCustomObject

## NOTES

## RELATED LINKS

[Set-ConsoleTheme](Set-ConsoleTheme.md)