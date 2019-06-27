Import-Module Pester
$path= (pwd).Path
invoke-pester $(join-Path -Path $path -ChildPath "PSFunctionExplorer\tests")