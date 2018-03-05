---
external help file: PSConsoleTheme-help.xml
Module Name: PSConsoleTheme
online version:
schema: 2.0.0
---

# Set-ConsoleTheme

## SYNOPSIS
Sets the current console theme.

## SYNTAX

### ByName (Default)
```
Set-ConsoleTheme [[-Name] <String>] [<CommonParameters>]
```

### Clear
```
Set-ConsoleTheme [-Clear] [<CommonParameters>]
```

## DESCRIPTION
The Set-ConsoleTheme cmdlet sets the console colors to a predefined theme in the PSConsoleTheme repository. If a theme contains the optional tokens attribute, the PSReadline token colors are also set. To reset the console colors and PSReadline token colors to the system defaults, specify the Clear parameter.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Clear
Indicates that this cmdlet set all console colors and PSReadline tokens to the system defaults.

```yaml
Type: SwitchParameter
Parameter Sets: Clear
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the console theme to set.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS

[Get-ConsoleTheme]()