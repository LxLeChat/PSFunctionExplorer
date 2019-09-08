Function Write-FUGraph {
    <#
    .SYNOPSIS
        Generate dependecy graph for a function or a set of functions found in a ps1/psm1 file.
    .DESCRIPTION
        Generate dependecy graph for a function or a set of functions found in a ps1/psm1 file.
    .EXAMPLE
        PS C:\> $x = Find-FUFunction .\PSFunctionExplorer.psm1
        PS C:\> Write-FUGraph -InputObject $x -ExportPath c:\temp\fufuncion.png -outputformat png -ShowGraph

        Répertoire : C:\temp

        Mode                LastWriteTime         Length Name
        ----                -------------         ------ ----
        -a----       08/09/2019     15:08          71598 fufunction.png

        Will Find all function(s) declarations in the psfunctionexplorer.psm1 file, and create a graph name fufunction.png. Then display it.
    .EXAMPLE
        PS C:\> Find-FUFunction .\PSFunctionExplorer.psm1 | Write-FUGraph -ExportPath c:\temp\fufuncion.png -outputformat png -ShowGraph

        Will Find all function(s) declarations in the psfunctionexplorer.psm1 file, and create a graph name fufunction.png. Then display it.
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