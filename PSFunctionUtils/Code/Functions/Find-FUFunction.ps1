Function Find-FUFunction {
    <#
    .SYNOPSIS
        Find All Functions declaration inside a ps1/psm1 file and their inner commands.
    .DESCRIPTION
        Find All Functions declaration inside a ps1/psm1 file.
        Return an object describing a powershell file of type CUScriptFile.
        The function property contains all the function declaration found in the file.
        The funcrion property of type CUFunction is composed of a set of 2 proeprties. The name of the function and the commands found inside the function.
    .EXAMPLE
        PS C:\> $a = Find-FUFunction -path c:\PSclassutils\PSClassutils.psm1
        PS C:\> $a
        Name              FullName                                                         Functions
        ----              --------                                                         ---------
        PSClassUtils.psm1 C:\PSclassutils\PSClassutils.psm1                                {ConvertTo-titleCase, Find-CUClass, Get-CUAst, New-CUGraphExport...}

        If we examine closer the functions property
        PS C:\> $a.Functions
        Name                            Commands
        ----                            --------
        ConvertTo-titleCase             {Get-Culture}
        Find-CUClass                    {Write-Verbose, Get-ChildItem, Get-CUCLass, Where-Object...}
        Get-CUAst                       {Write-Verbose}
        New-CUGraphExport               {Join-Path, Export-PSGraph}
        New-CUGraphParameters           {Out-CUPSGraph}
        Out-CUPSGraph                   {Get-Module, get-module, Import-Module, Group...}
        Get-CUClass                     {Get-Item, Resolve-Path, Get-CUAst, Get-CULoadedClass}
        Get-CUClassConstructor          {Get-Item, Resolve-Path, Get-CuClass}
        Get-CUClassMethod               {Where-Object, Get-Item, Resolve-Path, Get-CuClass}
        Get-CUClassProperty             {Get-CuClass}
        Get-CUCommands                  {Get-Command}
        Get-CUEnum                      {throw, Get-cuast, ?}
        Get-CULoadedClass               {Where-Object, ForEach-Object, Select-Object, Get-CUAst}
        Get-CURaw                       {Get-Item, resolve-path}
        Install-CUDiagramPrerequisites  {Get-Module, get-module, write-verbose, Install-Module...}
        Test-IsCustomType               {Where}
        Write-CUClassDiagram            {Test-Path, New-Object, get-item, Get-ChildItem}
        Write-CUInterfaceImplementation {}
        Write-CUPesterTest              {gci, Get-CUClass, Get-Item, Group-Object...}
    .EXAMPLE
        PS C:\> $a = Find-FUFunction -path c:\PSclassutils\PSClassutils.psm1 -ExcludePSCmdlets
        PS C:\> $a
        Name              FullName                                                         Functions
        ----              --------                                                         ---------
        PSClassUtils.psm1 C:\PSclassutils\PSClassutils.psm1                                {ConvertTo-titleCase, Find-CUClass, Get-CUAst, New-CUGraphExport...}

        If we examine closer the functions property
        PS C:\> $a.Functions
        Name                            Commands
        ----                            --------
        ConvertTo-titleCase             {}
        Find-CUClass                    {Get-CUCLass}
        Get-CUAst                       {}
        New-CUGraphExport               {Export-PSGraph}
        New-CUGraphParameters           {Out-CUPSGraph}
        Out-CUPSGraph                   {Group, Graph, subgraph, ConvertTo-TitleCase...}
        Get-CUClass                     {Get-CUAst, Get-CULoadedClass}
        Get-CUClassConstructor          {Get-CuClass}
        Get-CUClassMethod               {Get-CuClass}
        Get-CUClassProperty             {Get-CuClass}
        Get-CUCommands                  {}
        Get-CUEnum                      {throw, Get-cuast, ?}
        Get-CULoadedClass               {Get-CUAst}
        Get-CURaw                       {}
        Install-CUDiagramPrerequisites  {Install-Module, Install-GraphViz}
        Test-IsCustomType               {Where}
        Write-CUClassDiagram            {}
        Write-CUInterfaceImplementation {}
        Write-CUPesterTest              {gci, Get-CUClass}
    .INPUTS
        FullName Path. Accepts pipeline inputs
    .OUTPUTS
        A CUScriptfile custom object
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (
        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,Position=1,ValueFromPipelineByPropertyName=$True)]
        [string[]]$Path,
        [Switch]$ExcludePSCmdlets
    )
    
    begin {
        If ( $PSBoundParameters['ExcludePSCmdlets'] ) {
            $ToExclude = (Get-Command -Module "Microsoft.PowerShell.Archive","Microsoft.PowerShell.Utility","Microsoft.PowerShell.ODataUtils","Microsoft.PowerShell.Operation.Validation","Microsoft.PowerShell.Management","Microsoft.PowerShell.Core","Microsoft.PowerShell.LocalAccounts","Microsoft.WSMan.Management","Microsoft.PowerShell.Security","Microsoft.PowerShell.Diagnostics","Microsoft.PowerShell.Host").Name
            $ToExclude += (Get-Alias | Select-Object -Property Name).name
        }
    }
    
    process {
        ForEach( $p in $Path) {
            $item = get-item (resolve-path -path $p).path
            If ( $item -is [system.io.FileInfo] -and $item.Extension -in @('.ps1','.psm1') ) {
                Write-Verbose ("[FUFunction]Analyzing {0} ..." -f $item.FullName)
                $t = [FUScriptFile]::new($item.FullName)
                If ( $PSBoundParameters['ExcludePSCmdlets'] ) {
                    $t.GetFunctions($ToExclude)
                } else {
                    $t.GetFunctions()
                }
                $t
            }
        }
    }
    
    end {
    }
}