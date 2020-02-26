# Developing VisionEval using VE-Installer

If you are interested in developing or debugging [VisionEval](https://visioneval.org "VisionEval"), you can easily get started in one of two ways:

1. Clone the github development branch from https://github.com/VisionEval/VisionEval-dev and follow the build instructions in the ReadMe.md file for VE-Installer.
    * You need to use this method if you want to work on the VisionEval development branch
    * Do this if you are making changes you think you might submit back to the VisionEval project).
2. Install the binary installer (zip file) from [the VisionEval Download Page](https://visioneval.org/category/download.html "VisionEval Download"), then clone the git repository for the "master" branch (either from [https://github.com/VisionEval/VisionEval](https://github.com/VisionEval/VisionEval) or from [https://github.com/VisionEval/VisionEval-dev](https://github.com/VisionEval/VisionEval-dev)).
    * Use this method to debug or tinker with one of the models or modules
    
You will find working with [RStudio](https://www.rstudio.com/products/rstudio/download/ "Download RStudio") to be very convenient.

After you have completed one of the installation steps above (either building VisionEval from scratch using the VE-Installer, or installing the runtime plus the corresponding source repository), you should run the `VisionEval.bat` file to link up the R Version and R library.  A side-effect of doing that is that a `.Renviron` file with a suitable definition of `R_LIBS_USER` will be created in the runtime directory.

The `.Renviron` file will contain the path to the VisionEval R library (where all the dependencies are located). If you did the full build with VE-Installer, it will also include a path to the development library (where R packages needed to build, but not to run, VisionEval are installed). You can add additional library locations to `R_LIBS_USER` inside that file (just separate the paths using semicolons). If those directories exist when you start R or RStudio from a directory containing `.Renviron`, they will be loaded automatically into the `.libPaths` list used by R to find its packages.

Within the VisionEval source tree, the framework as well as each package and model has a `.Rproj` file for RStudio that you can use to start R.  Just copy the `.Renviron` file from the runtime into the directory from which you expect to start RStudio.  Then, when you start RStudio, you can load visioneval by entering:

```
library(visioneval)
```

When you are working on a package using either approach, you probably will find it most convenient to set up RStudio so you can interactively rebuild the package you're working on. To set up RStudio, you need to attend to these configuration items:

1. Verify that `.Renviron` has been copied to the directory containing the package's `.Rproj` file
1. Start RStudio in the root directory of the package (e.g. `sources/modules/VELandUse`) by double-clicking the `.Rproj` file
    * If Rstudio is already running, just close the current project (if any) and open a new project, selecting the package's .Rproj file
1. Install RTools (RStudio will make you do this when you first try a package build)
2. In the RStudio 'Build' menu, go to the Build menu and choose 'Package' as the type of build
3. When you then do "install and restart", the built package will be placed into the VisionEval library (so if you run VisionEval from its runtime location, your new version will have replaced the original).
4. After you have installed the changes, you also use the RStudio debug features to set breakpoints, step through code, and inspect temporary variables.

If you are working in the full installation environment (i.e. installed using VE-Installer and `make`, rather than from the distributed `.zip` installer), don't forget to `make clean` and rebuild (`make`) VisionEval after your changes are stable (and before, for example, you go to work on a different module package).  Also don't forget to commit your changes to your Github repository clone or fork.
    
