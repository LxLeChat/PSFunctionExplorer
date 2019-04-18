# PS-Module-Functions-Dependency
Snippet to help find functions interaction within a PS Module

# How it works
First i exclude all "standard" cmdlets. (variable b)
dont forget to change the path of the folder containing your functions.
then i use ast to create an arraylist containing all the cmdlets i find in every file available under the specific path.
This better works in a well organized module. (One file, one function..., i'm currently in the process of doing something more awesome!)
at the end of the first loop you have ArrayOfFunctions, that contains all functions, and what functions are called inside their code.

You can stop their if you want, or you can pass ArrayOfFunctions to PSGraph to generate a Graph :)

Red nodes => dependent functions

Green nodes => standalon function

use: -OutPutForm pdf, with show-psgraph, if you want to search the graph!

# Why i did it
I've tasked to study a huuuuuuge module, with no comment, no documentation etc...

# Example
Done on @lazyadmin ADSIPS Module https://github.com/lazywinadmin/AdsiPS
![OutPut](/ADSIPS.png)
