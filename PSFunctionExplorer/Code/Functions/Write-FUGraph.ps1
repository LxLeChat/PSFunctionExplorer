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
        [FuFunction[]]$InputObject,
        [System.IO.FileInfo]$ExportPath,
        [ValidateSet('pdf',"png")]
        [String]$OutPutFormat,
        [ValidateSet('dot','circo','hierarchical')]
        [String]$LayoutEngine,
        [Switch]$ShowGraph,
        [Switch]$PassThru
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
        
        $graph | export-PSGraph @ExportAttrib

        If ( $PassThru ) { 
            $graph
        }
        
    }
}