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