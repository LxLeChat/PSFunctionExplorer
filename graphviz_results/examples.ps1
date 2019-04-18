
## génere un graph des fonctions de psclassutils
$plop = Find-CUFunction -Path C:\Users\lx\GitPerso\PSClassUtils\PSClassUtils\PSClassUtils.psm1 -ExcludePSCmdlets | select -ExpandProperty functions


graph depencies @{rankdir='LR'}{
    Foreach ( $t in $Plop ) {
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

<# 
Past the digraph to : http://viz-js.com/
 #>