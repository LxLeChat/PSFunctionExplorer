Function ConvertTo-FUFile {
    <#
    .SYNOPSIS
        Convert a FUFunction to a ps1 file. It's like a reverse build process.
    .DESCRIPTION
        Convert a FUFunction to a ps1 file. It's like a reverse build process.
    .EXAMPLE
        PS C:\> Find-FUFunction -Path .\PSFunctionExplorer.psm1 | ConvertTo-FUFile
            Répertoire : C:\


        Mode                LastWriteTime         Length Name
        ----                -------------         ------ ----
        -a----       30/04/2019     23:24            658 Convertto-Fufile.ps1
        -a----       30/04/2019     23:24           3322 Find-Fufunction.ps1
        -a----       30/04/2019     23:24           2925 Write-Fufunctiongraph.ps1

        Find all functions definitions inside PSFunctionExplorer.psm1 and save each function inside it's own ps1 file.
    .EXAMPLE
        PS C:\> Find-FUFunction -Path .\PSFunctionExplorer.psm1 | ConvertTo-FUFile -Path C:\Temp
            Répertoire : C:\Temp


        Mode                LastWriteTime         Length Name
        ----                -------------         ------ ----
        -a----       30/04/2019     23:24            658 Convertto-Fufile.ps1
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
        [Parameter(ValueFromPipeline=$True)]
        [Object[]]$FUFunction,
        [String]$Path
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