class CUFunction {
    $Name
    [System.Collections.ArrayList]$Commands = @()
    hidden $RawFunctionAST

    CuFunction ([System.Management.Automation.Language.FunctionDefinitionAST]$Raw) {
        $this.RawFunctionAST = $Raw
        $this.name = [CUUtility]::ToTitleCase($this.RawFunctionAST.name)
        $this.GetCommands()
    }

    CuFunction ([System.Management.Automation.Language.FunctionDefinitionAST]$Raw,$ExclusionList) {
        $this.RawFunctionAST = $Raw
        $this.name = [CUUtility]::ToTitleCase($this.RawFunctionAST.name)
        $this.GetCommands($ExclusionList)
    }

    GetCommands () {

        $t = $this.RawFunctionAST.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
        If ( $t.Count -gt 0 ) {
            ## si elle existe deja, on ajotue juste à ces commands
            ($t.GetCommandName() | Select-Object -Unique).Foreach({
                $Command = [CUUtility]::ToTitleCase($_)
                $this.Commands.Add($Command)
            })
        }
    }

    ## Overload
    GetCommands ($ExclusionList) {

        $t = $this.RawFunctionAST.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
        If ( $t.Count -gt 0 ) {
            ($t.GetCommandName() | Select-Object -Unique).Foreach({
                $Command = [CUUtility]::ToTitleCase($_)
                If ( $ExclusionList -notcontains $Command) {
                    $this.Commands.Add($Command)
                }
            })
        }
    }
}

Class CUScriptFile {
    $Name
    $FullName
    [CUFunction[]]$Functions
    hidden $RawASTContent
    hidden $RawASTDocument
    hidden $RawFunctionAST
    
    CUScriptFile ($path){
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
            
            $this.Functions += [CUFunction]::New($function)
        }
    }

    ## GetFunctions Overload, with ExclustionList
    GetFunctions($ExclusionList){
        Foreach ( $Function in $this.RawFunctionAST ) {
            $this.Functions += [CUFunction]::New($function,$ExclusionList)
        }
    }

}

Class CUUtility {
    Static [String]ToTitleCase ([string]$String){
        return (Get-Culture).TextInfo.ToTitleCase($String.ToLower())
    }
}

## https://powershellexplained.com/2017-02-20-Powershell-creating-parameter-validators-and-transforms/
## in the function params : [PathTransformAttribute()] not [PathTransform()] ==> thanks @vexx32 aka @joel!
## not using it ...
class PathTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute
{
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData)
    {
            Write-Verbose "[PathTransformAttribute]: $inputData"
            If ( $inputData -is [string] ) {
                    $fullPath = Resolve-Path -Path $inputData -ErrorAction SilentlyContinue
                    $inputData = $fullPath
                    return $inputData.Path
            }
            
            If ( $inputData -is [System.IO.FileInfo] -or $inputData -is [System.IO.DirectoryInfo] ) {
                $inputData = Resolve-Path -Path $inputData -ErrorAction SilentlyContinue
                return $inputData.Path
            }

            
            throw [System.IO.FileNotFoundException]::new()
    }
}