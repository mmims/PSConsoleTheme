# PSConsoleTheme Changes

## Version 0.3.0

Features

* Added `ShowColors` parameter to `Get-ConsoleTheme` to display the current color palette.

Performance

* Lazy load themes to decrease module import time.

Bug Fixes

* Reset PSReadline tokens before loading a theme.
* Ensure PSReadline token backgrounds are set properly.
* Use Win32 API to accurately set the active console background and foreground.
* Improve error handling.

## Version 0.2.0

Features

* Support loading themes from multiple paths.
* User settings and themes are now stored in the `.psconsoletheme` folder.

Bug Fixes

* Reset colors of active session when -Reset is called.
* Fully support all token types.

## Version 0.1.2

Bug Fixes

* Add exported functions to manifest so they are cached before the module is imported.

## Version 0.1.1

Bug Fixes

* Add Tags, LicenseUri, and ProjectUri to manifest so that PSGallery page shows proper content.

## Version 0.1.0

Initial release.