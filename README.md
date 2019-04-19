# PSFunctionExplorer
A small set of functions to discover function(s) declaration(s), and their inner commands using AST and draw graph dependecy.

# How it works
I simply use the AST (Abstract Syntax Tree) to discover ```FunctionDefinitionsTypes``` inside the ps1/psm1 file and ```CommandAst``` types inside each function.
I used classes to write my script... Why ? Cause CLASSES are AWSOME !

# Available Functions
### Find-FUFunction
```Find-FUFunction``` will help you find all function(s) declaration(s) within ps1/psm1 file(s). For each discovered function, the function will also find every commands within this function. It will output a custom ```FUScriptFile``` type. Expand the Functions property to find commands...

```PS >Find-FUFunction -Path ..\..\PSClassUtils\PSClassUtils\PSClassUtils.psm1 -ExcludePSCmdlets
Name              FullName                                                               Functions
----              --------                                                               ---------
PSClassUtils.psm1 C:\Users\pchasles\GitPerso\PSClassUtils\PSClassUtils\PSClassUtils.psm1 {Convertto-Titlecase, Find-Cuclass, Get-Cuast, New-Cugraphexport...}
```
Now if we expand the functions property
```
PS >Find-FUFunction -Path ..\..\PSClassUtils\PSClassUtils\PSClassUtils.psm1 -ExcludePSCmdlets | select-Object -Expandproperty Functions
Name                           Commands
----                           --------
Convertto-Titlecase            {}
Find-Cuclass                   {Get-Cuclass}
Get-Cuast                      {}
New-Cugraphexport              {Export-Psgraph}
New-Cugraphparameters          {Out-Cupsgraph}
Out-Cupsgraph                  {Graph, Subgraph, Convertto-Titlecase, Record...}
Get-Cuclass                    {Get-Cuast, Get-Culoadedclass}
Get-Cuclassconstructor         {Get-Cuclass}
Get-Cuclassmethod              {Get-Cuclass}
Get-Cuclassproperty            {Get-Cuclass}
Get-Cucommands                 {}
Get-Cuenum                     {Throw, Get-Cuast}
Get-Culoadedclass              {Get-Cuast}
Get-Cupesterdescribeblock      {Get-Cupesteritblock}
Get-Cupesteritblock            {}
Get-Cupesterscript             {Get-Cupesterdescribeblock}
Get-Curaw                      {}
Install-Cudiagramprerequisites {Install-Module, Install-Graphviz}
Test-Iscustomtype              {}
Write-Cuclassdiagram           {Find-Cuclass, New-Cugraphparameters, New-Cugraphexport}
Write-Cupestertests            {Get-Cuclass}
```
You have every function declaration discovered in the psclassutils.psm1 file, and for each function declaration, all its internal commands.

#### Find-FUFunction Parameters
* ```-Path``` fullpath of a ps1/psm1 file, accept values from the pipeline...
* ```-ExcludePSCmdlets``` switch to exlcude default cmdlts and aliases...

### Write-FUFunctionDiagram
```Write-FUFunctionDiagram``` will draw a graph of dependencies. Just check the [Examples](./Example) ...
You will need the awsome PSGRAPH Module!..
PSFunctionExplore.psm1 file:..

![Graph1](https://github.com/LxLeChat/PSFunctionExplorer/blob/master/Example/module_psfunctionexplorer.png)

* Red node(s): The function has a dependency, to ..well follow the line :)..
* Green node(s): Standalone function !..
* Black node(s): External function, in this example: graph, node, edge and export-psgraph are imported function from PSGRAPH...

#### Write-FUFunctionDiagram Parameters
* ```-Path``` fullpath of a ps1/psm1 file
* ```-ExcludePSCmdlets``` exlcude default cmdlts and aliases
* ```-ExportPath``` FullName of the export file that will be generated. If not specified, a random filename in the current directory will be used
* ```-OutPutFormat``` File output format available @ the moment ```pdf, png```. Default is ```png```
* ```-LayoutEngine``` Layout engine used by graphviz to generate the graph. Available @ the moment ```dot, circo, hierarchical```. Default ```dot```
* ```-ShowGraph``` Display the graph when it's generated
* ```-PassThru``` Display graph data. Can be used on http://www.webgraphviz.com/ or http://viz-js.com/ for example

# Why i did it
I've tasked to study a huuuuuuge module, with no comment, no documentation etc... It helped me understand how each functions interacts with one another.

# Inspiration
Thanks to @stephanevg who inspired me to create this module and helped me discover AST and let me work on psclassutils !
His Github: https://github.com/Stephanevg/

PSHTML Graph:

![Awsome PSHTML](https://github.com/LxLeChat/PSFunctionExplorer/blob/master/Example/module_pshtml2.png)
