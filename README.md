# PSFunctionExplorer
A small set of functions to discover function(s) declaration(s), and their inner commands using AST and draw graph dependecy.

# How it works
I simply use the AST (Abstract Syntax Tree) to discover ```FunctionDefinitionsTypes``` inside the ps1/psm1 file and ```CommandAst``` types inside each function.
I used classes to write my script... Why ? Cause CLASSES are AWSOME !

# Available Functions
-```Find-FUFunction``` will help you find all function(s) declaration(s) within ps1/psm1 file(s). For each discovered function, the function will also find every commands within this function. It will output a custom ```FUScriptFile``` type. Expand the Functions property to find commands.

```Find-FUFunction -path .\yourpsm1file.psm1 | Select-Object -ExpandProperty Functions```

I prefere to use the ```-ExcludePSCmdlets``` to not discover basic powershell commands.

-```Write-FUFunctionDiagram``` will draw a graph of dependencies. Just check the ![Example](/Example) ...
You will need the awsome PSGRAPH Module!

# Why i did it
I've tasked to study a huuuuuuge module, with no comment, no documentation etc... It helped me understand how each functions interacts with one another.

# Inspiration
Thanks to @stephanevg who inspired me to create this module! https://github.com/Stephanevg/PSClassUtils
