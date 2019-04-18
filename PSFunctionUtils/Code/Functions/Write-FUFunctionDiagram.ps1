Function Write-CUFunctionGraph {
    <#
    .SYNOPSIS
        Generate dependecy graphviz datas for a function or a set of functions found in a ps1/psm1 file.
    .DESCRIPTION
        Generate dependecy graphviz datas for a function or a set of functions found in a ps1/psm1 file.
    .EXAMPLE
        PS C:\> Write-CUFunctionGraph -Path ..\PSClassUtils\PSClassUtils\PSClassUtils.psm1 -ExcludePSCmdlets
        digraph depencies {
            rankdir="LR";
            compound="true";
            "Convertto-Titlecase" [color="green";]
            "Find-Cuclass" [color="red";]
            "Find-Cuclass"->"Get-Cuclass"
            "Get-Cuast" [color="green";]
            "New-Cugraphexport" [color="red";]
            "New-Cugraphexport"->"Export-Psgraph"
            "New-Cugraphparameters" [color="red";]
            "New-Cugraphparameters"->"Out-Cupsgraph"
            "Out-Cupsgraph" [color="red";]
            "Out-Cupsgraph"->"Graph"
            "Out-Cupsgraph"->"Subgraph"
            "Out-Cupsgraph"->"Convertto-Titlecase"
            "Out-Cupsgraph"->"Record"
            "Out-Cupsgraph"->"Row"
            "Out-Cupsgraph"->"Edge"
            "Get-Cuclass" [color="red";]
            "Get-Cuclass"->"Get-Cuast"
            "Get-Cuclass"->"Get-Culoadedclass"
            "Get-Cuclassconstructor" [color="red";]
            "Get-Cuclassconstructor"->"Get-Cuclass"
            "Get-Cuclassmethod" [color="red";]
            "Get-Cuclassmethod"->"Get-Cuclass"
            "Get-Cuclassproperty" [color="red";]
            "Get-Cuclassproperty"->"Get-Cuclass"
            "Get-Cucommands" [color="green";]
            "Get-Cuenum" [color="red";]
            "Get-Cuenum"->"Throw"
            "Get-Cuenum"->"Get-Cuast"
            "Get-Culoadedclass" [color="red";]
            "Get-Culoadedclass"->"Get-Cuast"
            "Get-Curaw" [color="green";]
            "Install-Cudiagramprerequisites" [color="red";]
            "Install-Cudiagramprerequisites"->"Install-Module"
            "Install-Cudiagramprerequisites"->"Install-Graphviz"
            "Test-Iscustomtype" [color="green";]
            "Write-Cuclassdiagram" [color="green";]
            "Write-Cuinterfaceimplementation" [color="green";]
            "Write-Cupestertest" [color="red";]
            "Write-Cupestertest"->"Get-Cuclass"
        }

    .INPUTS
        FullName Path. Accepts pipeline inputs
    .OUTPUTS
        Outputs Graphviz datas
    .NOTES
        First Draft. For the moment the function only output graphviz datas. Soon you ll be able to generate a nice graph as a png, pdf ...
    #>
    [CmdletBinding()]
    param (
        [Alias("FullName")]
        [Parameter(ValueFromPipeline=$True,Position=1,ValueFromPipelineByPropertyName=$True)]
        [string[]]$Path,
        [Switch]$ExcludePSCmdlets
    )
    
    begin {
        $results = @()
    }
    
    process {
        ForEach( $p in $Path) {
            $item = get-item (resolve-path -path $p).path
            If ( $item -is [system.io.FileInfo] -and $item.Extension -in @('.ps1','.psm1') ) {
                If ( $PSBoundParameters['ExcludePSCmdlets'] ) {
                    $results += Find-CUFunction -Path $item -ExcludePSCmdlets
                } else {
                    $results += Find-CUFunction -Path $item
                }
            }
        }
    }
    
    end {    
        graph depencies @{rankdir='LR'}{
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
    }
}