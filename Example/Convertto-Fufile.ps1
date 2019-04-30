Function ConvertTo-FUFile {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$True)]
        [Object[]]$FUFunction,
        $Path
    )
    
    begin {
        If ( $PSBoundParameters['Path']) {
            $item = get-item (resolve-path -path $path).path
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