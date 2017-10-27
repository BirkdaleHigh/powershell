# About these files

This repository contains a central copy of code placed with documentation for the network in order to be easily run and keep detail up to date.

It also contains functions that transform data into formats to import for external services the school uses.

Below lists various roles or problems addressed by scripts or collections of script files.

## Printers
Filename | Description
-|-
`Printer.ps1` | Add specified printer connections to windows 10+ as a GPO Login script
`Update-PrinterMap.ps1` | write a new map for `Printer.ps1`. This is to avoid a syntax error breaking the whole domain print mapping.

Place these files in a suitable share, create a `log` folder with modify access for an account the script runs under at login. `Printer.ps1` will place a log per computer name it has executed on to help troubleshoot.
