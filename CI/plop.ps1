Import-Module Pester
$path= $(pwd).Path
$PesterResults = invoke-pester $(join-Path -Path $path -ChildPath "PSFunctionExplorer\tests") -PassThru

If ($PesterResults.PassedCount -eq $PesterResults.TotalCount ) {
    write-host "LOLLILOL"
    ## Do Something
    "test: {0}" -f $(test)
    "simplevariable: {1}" -f $(simplevariable)
}