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