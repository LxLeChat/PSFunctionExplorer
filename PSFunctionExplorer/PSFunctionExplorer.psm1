class FUFunction {
    $Name
    [System.Collections.ArrayList]$Commands = @()
    hidden $RawFunctionAST

    FUFunction ([System.Management.Automation.Language.FunctionDefinitionAST]$Raw) {
        $this.RawFunctionAST = $Raw
        $this.name = [FUUtility]::ToTitleCase($this.RawFunctionAST.name)
        $this.GetCommands()
    }

    FUFunction ([System.Management.Automation.Language.FunctionDefinitionAST]$Raw,$ExclusionList) {
        $this.RawFunctionAST = $Raw
        $this.name = [FUUtility]::ToTitleCase($this.RawFunctionAST.name)
        $this.GetCommands($ExclusionList)
    }

    GetCommands () {

        $t = $this.RawFunctionAST.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
        If ( $t.Count -gt 0 ) {
            ## si elle existe deja, on ajotue juste à ces commands
            ($t.GetCommandName() | Select-Object -Unique).Foreach({
                $Command = [FUUtility]::ToTitleCase($_)
                $this.Commands.Add($Command)
            })
        }
    }

    ## Overload
    GetCommands ($ExclusionList) {

        $t = $this.RawFunctionAST.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
        If ( $t.Count -gt 0 ) {
            ($t.GetCommandName() | Select-Object -Unique).Foreach({
                $Command = [FUUtility]::ToTitleCase($_)
                If ( $ExclusionList -notcontains $Command) {
                    $this.Commands.Add($Command)
                }
            })
        }
    }
}

Class FUScriptFile {
    $Name
    $FullName
    [FUFunction[]]$Functions
    hidden $RawASTContent
    hidden $RawASTDocument
    hidden $RawFunctionAST
    
    FUScriptFile ($path){
        $this.FullName = $path
        $this.Name = ([System.IO.FileInfo]$path).Name
        $this.RawASTContent = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$Null)
        $this.GetRawFunctions()
    }

    hidden GetRawFunctions() {
        $this.RawASTDocument = $this.RawASTContent.FindAll({$args[0] -is [System.Management.Automation.Language.Ast]}, $true)
        If ( $this.RawASTDocument.Count -gt 0 ) {
            ## We want to exclude Classes, so we check if the parent of the current function is not a functionmemberast type
            ## source: https://stackoverflow.com/questions/45929043/get-all-functions-in-a-powershell-script/45929412
            $this.RawFunctionAST = $this.RawASTDocument.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $($args[0].parent) -isnot [System.Management.Automation.Language.FunctionMemberAst] })
        }
    }

    GetFunctions(){
        Foreach ( $Function in $this.RawFunctionAST ) {
            $this.Functions += [FUFunction]::New($function)
        }
    }

    ## GetFunctions Overload, with ExclustionList
    GetFunctions($ExclusionList){
        Foreach ( $Function in $this.RawFunctionAST ) {
            $this.Functions += [FUFunction]::New($function,$ExclusionList)
        }
    }

}

Class FUUtility {
    Static [String]ToTitleCase ([string]$String){
        return (Get-Culture).TextInfo.ToTitleCase($String.ToLower())
    }
}

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

Function Write-FUFunctionGraph {
    <#
    .SYNOPSIS
        Generate dependecy graph for a function or a set of functions found in a ps1/psm1 file.
    .DESCRIPTION
        Generate dependecy graph for a function or a set of functions found in a ps1/psm1 file.
    .EXAMPLE
        tbd
    .INPUTS
        FullName Path. Accepts pipeline inputs.
    .OUTPUTS
        Outputs Graph, thanks to psgraph module.
    .NOTES
        First Draft. For the moment the function only output graphviz datas. Soon you ll be able to generate a nice graph as a png, pdf ...
    #>
    [CmdletBinding()]
    param (
        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,Position=1,ValueFromPipelineByPropertyName=$True)]
        [string[]]$Path,
        [Switch]$ExcludePSCmdlets,
        [System.IO.FileInfo]$ExportPath,
        [ValidateSet('pdf',"png")]
        [String]$OutPutFormat,
        [ValidateSet('dot','circo','hierarchical')]
        [String]$LayoutEngine,
        [Switch]$ShowGraph,
        [Switch]$PassThru
    )
    
    begin {
        $results = @()
    }
    
    process {
        ForEach( $p in $Path) {
            $item = get-item (resolve-path -path $p).path
            If ( $item -is [system.io.FileInfo] -and $item.Extension -in @('.ps1','.psm1') ) {
                If ( $PSBoundParameters['ExcludePSCmdlets'] ) {
                    $results += Find-FUFunction -Path $item -ExcludePSCmdlets
                } Else {
                    $results += Find-FUFunction -Path $item
                }
            }
        }
    }
    
    end {

        $ExportAttrib = @{
            DestinationPath = If ( $null -eq $PSBoundParameters['ExportPath']) {$pwd.Path+'\'+[system.io.path]::GetRandomFileName().split('.')[0]+'.png'} Else {$PSBoundParameters['ExportPath']}
            OutPutFormat    = If ( $null -eq $PSBoundParameters['OutPutFormat']) {'png'} Else { $PSBoundParameters['OutPutFormat'] }
            LayoutEngine    = If ( $null -eq $PSBoundParameters['LayoutEngine']) {'dot'} Else { $PSBoundParameters['LayoutEngine'] }
            ShowGraph    = If ( $null -eq $PSBoundParameters['ShowGraph']) {$False} Else { $True }
        }

        $graph = graph depencies @{rankdir='LR'}{
            Foreach ( $t in $($results | Select-Object -ExpandProperty Functions) ) {
                If ( $t.commands.count -gt 0 ) {
                        node -Name $t.name -Attributes @{Color='red'}
                } Else {
                    node -Name $t.name -Attributes @{Color='green'}
                }
            
                If ( $null -ne $t.commands) {
                    Foreach($cmdlet in $t.commands ) {
                        edge -from $t.name -to $cmdlet
                    }
                }
            }
        } 
        If ( $PassThru ) { 
            $graph
        }
        
        $graph | export-PSGraph @ExportAttrib
    }
}