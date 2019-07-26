Import-Module Pester
$path= $(pwd).Path
$PesterResults = invoke-pester $(join-Path -Path $path -ChildPath "PSFunctionExplorer\tests") -PassThru

If ($PesterResults.PassedCount -eq $PesterResults.TotalCount ) {
    ## Do Something
    $(test)
}