# Developing VisionEval using VE-Installer

If you are interested in developing or debugging [VisionEval](https://visioneval.org "VisionEval"), you can easily get started in one of two ways:

1. **With VE-Installer**
    * _When to use this method:_
      * To work on the VisionEval development branch and its unreleased features (as opposed to the `master` branch which corresponds to the current binary release).
      * You _must_ use this method if you are developing something (like a new module) that you think you might submit back to the VisionEval project.
    * _How to use this method:_
    1. Clone the github development branch from [https://github.com/VisionEval/VisionEval-dev](https://github.com/VisionEval/VisionEval-dev), like this:
      ```
      git clone --branch development https://github.com/VisionEval/VisionEval-dev.git MyVisionEval-dev
      ```
      
      * Change the final argument to give the repository a useful name.
      * This instruction will still clone all the other branches as well.  Use the `--single-branch` option to limit the clone just to the `development` branch
    2. Follow the installation and build instructions in the ReadMe.md file for [VE-Installer](https://github.com/VisionEval/VE-Installer).
    
2. **From the Binary Installer**
    * _When to use this method:_
      * To make local modifications to the current runtime release of VisionEval (e.g. to rebuild one of the packages with local data)
      * To introduce debugging statements or set breakpoints in the R code as a way of finding problems when you try to set up your own data for one of the models.=
    * _How to use this method:_
      1. Install the binary installer (zip file) from [the VisionEval Download Page](https://visioneval.org/category/download.html "VisionEval Download") following the instructions you'll find there.
      2. Clone the git repository for the "master" branch (either from [https://github.com/VisionEval/VisionEval](https://github.com/VisionEval/VisionEval) or from [https://github.com/VisionEval/VisionEval-dev](https://github.com/VisionEval/VisionEval-dev)), like this:
      ```
      git clone --branch master https://github.com/VisionEval/VisionEval.git MyVisionEval
      ```
        * Change the final argument to give the repository a useful name.
        * This instruction will still clone all the other branches as well.  Use the `--single-branch` option to limit the clone just to the `master` branch

## Working with RStudio

You will find working with [RStudio](https://www.rstudio.com/products/rstudio/download/ "Download RStudio") to be very convenient on either development path.

After you have completed one of the installation steps above (either building VisionEval from scratch using the VE-Installer, or installing the runtime plus the corresponding source repository), you should run the `VisionEval.bat` file to link up the R Version and R library.  A side-effect of doing that is that a `.Renviron` file with a suitable definition of `R_LIBS_USER` will be created in the VisionEval runtime directory.

The `.Renviron` file will contain the path to the VisionEval R library (where all the dependencies are located). If you did the full build with VE-Installer, it will also include a path to the development library (where R packages needed to build, but not to run, VisionEval are installed). You can add additional library locations to `R_LIBS_USER` inside the `.Renviron` file (just separate the paths using semicolons). If those directories exist when you start R or RStudio from a directory containing `.Renviron`, they will be loaded automatically into the `.libPaths` list used by R to find its packages.

Within the VisionEval source tree, the framework plus each package and model has a `.Rproj` file for RStudio that you can use to start R.  Just copy the `.Renviron` file from the runtime into the directory from which you expect to start RStudio.  Alternatively, you can put `.Renviron` into your `HOME` directory (on windows that would be something like `"C:\Users\Your.Name"`).  Then, when you start RStudio, you can load visioneval by entering:

```
library(visioneval)
```

If you are working on a package using either approach (for development or debugging), you should set up RStudio so you can interactively rebuild the package you're working on. To set up RStudio, you need to attend to these configuration items:

1. Verify that `.Renviron` has been copied to the directory containing the package's `.Rproj` file (or your `HOME` directory)
1. Start RStudio in the root directory of the package (e.g. `sources/modules/VELandUse`) by double-clicking the `.Rproj` file
    * If Rstudio is already running, just close the current project (if any) and open a new project, selecting the package's .Rproj file
1. Install [RTools](https://cran.r-project.org/bin/windows/Rtools/Rtools35.exe) (You can do this before you start RStudio, but RStudio will help you do it when you first start to set up a package build).
1. In RStudio, go to the Build menu, choose "Configure Built Tools..." and on the "Build Tools" tab, choose Project Build Tools 'Package' as the type of build at the top. The other parameters can stay at their defaults.
1. When you then go to the "Build" menu and choose "install and restart", the built package will be placed into the VisionEval library (so if you run VisionEval from its runtime location, your new version will have replaced the original). The other build options will also work.
1. After you have installed the changed package (using "Install and restart"), you can then use the RStudio debug features to set breakpoints, step through code, and inspect temporary variables.

**Remember:** If you are working in the full installation environment (i.e. you installed through the first method using `VE-Installer` and the `make` command, rather than from the distributed `.zip` installer), don't forget to `make clean` and rebuild `make` after your changes are stable (and before, for example, you go to work on a different module package).  Also don't forget to commit your changes to your Github repository clone or fork.
    
