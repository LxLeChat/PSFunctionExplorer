using namespace System.Management.Automation.Language

class FUFunction {
    $Name
    [System.Collections.ArrayList]$Commands = @()
    $Path
    hidden $RawFunctionAST

    FUFunction ([System.Management.Automation.Language.FunctionDefinitionAST]$Raw,$Path,[Bool]$TitleCase) {
        $this.RawFunctionAST = $Raw
        $this.Path = $path
        $this.GetCommands($TitleCase)

        If ( $TitleCase ) {
            $this.name = [FUUtility]::ToTitleCase($this.RawFunctionAST.name)    
        } Else {
            $this.name = $this.RawFunctionAST.name
        }
    }

    FUFunction ([System.Management.Automation.Language.FunctionDefinitionAST]$Raw,$ExclusionList,$Path,[Bool]$TitleCase) {
        $this.RawFunctionAST = $Raw
        $this.Path = $path
        $this.GetCommands($ExclusionList,$TitleCase)

        If ( $TitleCase ) {
            $this.name = [FUUtility]::ToTitleCase($this.RawFunctionAST.name)    
        } Else {
            $this.name = $this.RawFunctionAST.name
        }
    }

    hidden GetCommands ([Bool]$TitleCase) {

        $t = $this.RawFunctionAST.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
        If ( $t.Count -gt 0 ) {
            ## si elle existe deja, on ajotue juste à ces commands
            ($t.GetCommandName() | Select-Object -Unique).Foreach({
                
                If ( $TitleCase ) {
                    $Command = [FUUtility]::ToTitleCase($_)
                } Else {
                    $Command = $_
                }
                
                $this.Commands.Add($Command)
            })
        }
    }

    ## Overload
    hidden GetCommands ($ExclusionList,[Bool]$TitleCase) {

        $t = $this.RawFunctionAST.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
        If ( $t.Count -gt 0 ) {
            ($t.GetCommandName() | Select-Object -Unique).Foreach({
                $Command = [FUUtility]::ToTitleCase($_)
                If ( $ExclusionList -notcontains $Command) {
                    If ( $TitleCase ) {
                        $Command = [FUUtility]::ToTitleCase($_)
                    } Else {
                        $Command = $_
                    }
                    $this.Commands.Add($Command)
                }
            })
        }
    }
}

Class FUUtility {

    ## Static Method to TitleCase
    Static [String]ToTitleCase ([string]$String){
        return (Get-Culture).TextInfo.ToTitleCase($String.ToLower())
    }

    ## Static Method to return Function in AST Form, exclude classes
    [Object[]] static GetRawASTFunction($Path) {

        $RawFunctions   = $null
        $ParsedFile     = [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$Null)
        $RawAstDocument = $ParsedFile.FindAll({$args[0] -is [System.Management.Automation.Language.Ast]}, $true)

        If ( $RawASTDocument.Count -gt 0 ) {
            ## source: https://stackoverflow.com/questions/45929043/get-all-functions-in-a-powershell-script/45929412
            $RawFunctions = $RawASTDocument.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $($args[0].parent) -isnot [System.Management.Automation.Language.FunctionMemberAst] })
        }

        return $RawFunctions
    }

    ## GetFunction, return [FuFunction]
    [FUFunction] Static GetFunction($RawASTFunction,$path,$TitleCase){
        return [FUFunction]::New($RawASTFunction,$path,$TitleCase)
    }

    ## GetFunctions Overload, with ExclustionList, return [FuFunction]
    [FUFunction] Static GetFunction($RawASTFunction,$Exculde,$path,$TitleCase){
        return [FUFunction]::New($RawASTFunction,$Exculde,$path,$TitleCase)
    }

    ## SaveTofile in current path
    [System.IO.FileSystemInfo] static SaveToFile ([FuFunction]$Function) {
        return New-Item -Name $([FUUtility]::FileName($Function.name)) -value $Function.RawFunctionAST.Extent.Text -ItemType File
    }

    ## SaveTofile Overload, with Specific path for export
    [System.IO.FileSystemInfo] static SaveToFile ([FuFunction]$Function,$Path) {
        return New-Item -Path $Path -Name $([FUUtility]::FileName($Function.name)) -value $Function.RawFunctionAST.Extent.Text -ItemType File
    }

    ## Construct filename for export
    [string] hidden static FileName ($a) {
        return "$a.ps1"
    }

}

Function Expand-FUFile {
    <#
    .SYNOPSIS
        Export a FUFunction to a ps1 file. It's like a reverse build process.
    .DESCRIPTION
        Export a FUFunction to a ps1 file. It's like a reverse build process.
    .EXAMPLE
        PS C:\> Find-FUFunction -Path .\PSFunctionExplorer.psm1 | Expand-FUFile
            Répertoire : C:\


        Mode                LastWriteTime         Length Name
        ----                -------------         ------ ----
        -a----       30/04/2019     23:24            658 Expand-FUFile.ps1
        -a----       30/04/2019     23:24           3322 Find-Fufunction.ps1
        -a----       30/04/2019     23:24           2925 Write-Fufunctiongraph.ps1

        Find all functions definitions inside PSFunctionExplorer.psm1 and save each function inside it's own ps1 file.
    .EXAMPLE
        PS C:\> Find-FUFunction -Path .\PSFunctionExplorer.psm1 | Expand-FUFile -Path C:\Temp
            Répertoire : C:\Temp


        Mode                LastWriteTime         Length Name
        ----                -------------         ------ ----
        -a----       30/04/2019     23:24            658 Expand-FUFile.ps1
        -a----       30/04/2019     23:24           3322 Find-Fufunction.ps1
        -a----       30/04/2019     23:24           2925 Write-Fufunctiongraph.ps1

        Find all functions definitions inside PSFunctionExplorer.psm1 and save each function inside it's own ps1 file, inside the C:\Temp directory.
    .INPUTS
        [FuFunction]
    .OUTPUTS
        [System.IO.FileSystemInfo]
    .NOTES
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [Object[]]$FUFunction,

        [String]$Path
    )

    begin {
        If ( $PSBoundParameters['Path']) {
            $item = Get-Item (Resolve-Path -Path $path).Path
        }
    }

    process {
        ForEach( $Function in $FUFunction) {

            If ( $PSBoundParameters['Path']) {
                [FUUtility]::SaveToFile($Function,$Item.FullName)
            } Else {
                [FUUtility]::SaveToFile($Function)
            }

        }
    }

    end {
    }
}

Function Find-FUFunction {
    <#
    .SYNOPSIS
        Find All Functions declaration inside a ps1/psm1 file and their inner commands.
    .DESCRIPTION
        Find All Functions declaration inside a ps1/psm1 file.
        Return an object describing a powershell function. Output a custom type: FUFunction.
    .EXAMPLE
        PS C:\> Find-FUFunction .\PSFunctionExplorer.psm1

        Name                  Commands                                             Path
        ----                  --------                                             ----
        Find-Fufunction       {Get-Command, Get-Alias, Select-Object, Get-Item...} C:\PSFunctionExplorer.psm1
        Write-Fufunctiongraph {Get-Item, Resolve-Path, Find-Fufunction, Graph...}  C:\PSFunctionExplorer.psm1

        return all function present in the PSFunctionExplorer.psm1 and every commands present in it.
    .EXAMPLE
        PS C:\> Find-FUFunction .\PSFunctionExplorer.psm1 -ExcludePSCmdlets
        Name                  Commands                                Path
        ----                  --------                                ----
        Find-Fufunction       {}                                      C:\Users\Lx\GitPerso\PSFunctionUtils\PSFunctionExplorer\PSFunctionExplorer.psm1
        Write-Fufunctiongraph {Find-Fufunction, Graph, Node, Edge...} C:\Users\Lx\GitPerso\PSFunctionUtils\PSFunctionExplorer\PSFunctionExplorer.psm1

        Return all function present in the PSFunctionExplorer.psm1 and every commands present in it, but exclude default ps cmdlets.
    .INPUTS
        Path. Accepts pipeline inputs
    .OUTPUTS
        A FUFunction custom object
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    param (
        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,Position=1,ValueFromPipelineByPropertyName=$True)]
        [string[]]$Path,
        [Switch]$ExcludePSCmdlets,
        [Switch]$NoTitleCase
    )
    
    begin {

        If ( ! $PSBoundParameters['NoTitleCase'] ) {
            $NoTitleCase = $True
        } else {
            $NoTitleCase = $False
        } 

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
                $t = [FUUtility]::GetRawASTFunction($item.FullName)
                Foreach ( $RawASTFunction in $t ) {
                    If ( $PSBoundParameters['ExcludePSCmdlets'] ) {
                        [FUUtility]::GetFunction($RawASTFunction,$ToExclude,$item.FullName,$NoTitleCase)
                    } Else {
                        [FUUtility]::GetFunction($RawASTFunction,$item.FullName,$NoTitleCase)
                    }
                }
            }
        }
    }
    
    end {
    }
}

Function Write-FUGraph {
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
        [Parameter(ValueFromPipeline=$True)]
        [FUFunction[]]$InputObject,
        [System.IO.FileInfo]$ExportPath,
        [Parameter(ParameterSetName='Graph')]
        [ValidateSet('pdf',"png")]
        [String]$OutPutFormat,
        [Parameter(ParameterSetName='Graph')]
        [ValidateSet('dot','circo','hierarchical')]
        [String]$LayoutEngine,
        [Parameter(ParameterSetName='Graph')]
        [Switch]$ShowGraph,
        [Parameter(ParameterSetName='Dot')]
        [Switch]$AsDot
    )
    
    begin {
        $Results = @()
    }
    
    process {

        Foreach ( $Function in $InputObject ) {
            $Results += $Function
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
            Foreach ( $t in $Results ) {
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

        Switch ( $PSCmdlet.ParameterSetName ) {
            
            "Graph" {
                $graph | export-PSGraph @ExportAttrib
            }

            "Dot" {
                If ( $PSBoundParameters['ExportPath'] ) {
                    Out-File -InputObject $graph -FilePath $PSBoundParameters['ExportPath']
                } Else {
                    $graph
                }
            }
        }
        
    }
}