# PSFunctionExplorer
A small set of functions to discover function(s) declaration(s), and their inner commands using AST and draw graph dependecy.
The idea being we can explore a set of ps1/psm1 files without loading them.. i want to add some stuff to explorer functions help, and maybe some kind of reverse build ..

FU* Stands for Function Utility :p

# How it works
I simply use the AST (Abstract Syntax Tree) to discover ```FunctionDefinitionsTypes``` inside the ps1/psm1 file and ```CommandAst``` types inside each function.
I used classes to write my script... Why ? Cause CLASSES are AWSOME !

# Available Functions
### Find-FUFunction
```Find-FUFunction``` will help you find all function(s) declaration(s) within ps1/psm1 file(s). For each discovered function, the function will also find every commands within this function. It will output a custom ```FUFunction``` type.

```
PS >Find-FUFunction -Path ..\..\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Name                            Commands                                                     Path
----                            --------                                                     ----
Convertto-Titlecase             {Get-Culture}                                                C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Find-Cuclass                    {Write-Verbose, Get-Childitem, Get-Cuclass, Where-Object...} C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Get-Cuast                       {Write-Verbose}                                              C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
New-Cugraphexport               {Join-Path, Export-Psgraph}                                  C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
New-Cugraphparameters           {Out-Cupsgraph}                                              C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Out-Cupsgraph                   {Write-Verbose, Get-Module, Get-Module, Import-Module...}    C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Get-Cuclass                     {Get-Item, Resolve-Path, Get-Cuast, Get-Culoadedclass}       C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Get-Cuclassconstructor          {Get-Item, Resolve-Path, Get-Cuclass}                        C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Get-Cuclassmethod               {Where-Object, Get-Item, Resolve-Path, Get-Cuclass}          C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Get-Cuclassproperty             {Get-Cuclass}                                                C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Get-Cucommands                  {Get-Command}                                                C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Get-Cuenum                      {Throw, Get-Cuast, ?}                                        C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Get-Culoadedclass               {Where-Object, Foreach-Object, Select-Object, Get-Cuast}     C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Get-Curaw                       {Get-Item, Resolve-Path}                                     C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Install-Cudiagramprerequisites  {Get-Module, Get-Module, Write-Verbose, Install-Module...}   C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Test-Iscustomtype               {Where}                                                      C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Write-Cuclassdiagram            {Test-Path, New-Object, Get-Item, Get-Childitem...}          C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Write-Cuinterfaceimplementation {}                                                           C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1
Write-Cupestertest              {Gci, Get-Cuclass, Get-Item, Group-Object...}                C:\Users\Lx\PSClassUtils\PSClassUtils\PSClassUtils.psm1

```
You have every function declaration discovered in the psclassutils.psm1 file for the magnificient [PSCLASSUTILS](https://github.com/stephanevg/Psclassutils) module and for each function declaration, all its internal commands.

#### Find-FUFunction Parameters
* ```-Path``` fullpath of a ps1/psm1 file, accept values from the pipeline...
* ```-ExcludePSCmdlets``` switch to exlcude default cmdlts and aliases...

### Expand-FUFile
```Expand-FUFile``` will export all discovered function definitions in it's owner ps1 file.

```
PS C:\> Find-FUFunction -Path .\PSFunctionExplorer.psm1 | Expand-FUFile
    Répertoire : C:\


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----       30/04/2019     23:24            658 Expand-FUFile.ps1
-a----       30/04/2019     23:24           3322 Find-Fufunction.ps1
-a----       30/04/2019     23:24           2925 Write-FUGraph.ps1
```

#### Expand-FUFile Parameters
* ```-FUFunction``` FUFunction Object Type..
* ```-Path``` Export Path, by default, will use the current directory..


### Write-FUGraph
```Write-FUGraph``` will draw a graph of dependencies. Just check the [Examples](./Example) ...
You will need the awsome [PSGraph](https://github.com/KevinMarquette/PSGraph) Module!..
PSFunctionExplore.psm1 file:..

![Graph1](https://github.com/LxLeChat/PSFunctionExplorer/blob/master/Example/module_psfunctionexplorer.png)

* Red node(s): The function has a dependency, to ..well follow the line :)..
* Green node(s): Standalone function !..
* Black node(s): External function, in this example: graph, node, edge and export-psgraph are imported function from PSGRAPH...

#### Write-FUGraph Parameters
* ```-InputObject``` Takes ```FuFunction``` Objects generated with ```Find-FUFunction```
* ```-ExportPath``` FullName of the export file that will be generated. If not specified, a random filename in the current directory will be used
* ```-OutPutFormat``` File output format available @ the moment ```pdf, png```. Default is ```png```
* ```-LayoutEngine``` Layout engine used by graphviz to generate the graph. Available @ the moment ```dot, circo, hierarchical```. Default ```dot```
* ```-ShowGraph``` Display the graph when it's generated
* ```-AsDot``` Display graph data. Can be used on http://www.webgraphviz.com/ or http://viz-js.com/ for example. Works also with Gephi. You need to save the graph data in a dot file. For example i tried it for dbatools ... more thant 700 functions ...! 

# Why i did it
I've tasked to study a huuuuuuge module, with no comment, no documentation etc... It helped me understand how each functions interacts with one another.

# Inspiration
Thanks to @stephanevg who inspired me to create this module and helped me discover AST and let me work on psclassutils !
His Github: https://github.com/Stephanevg/

[PSHtml](https://github.com/stephanevg/PSHtml) Graph:

![Awsome PSHTML](https://github.com/LxLeChat/PSFunctionExplorer/blob/master/Example/module_pshtml2.png)

Thanks to @ChrisLGardner for his advices!
