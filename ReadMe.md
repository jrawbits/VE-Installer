# Building and Installing VisionEval

The "build" folder contains R scripts and resources necessary to build a runnable
VisionEval, using resources in the other folders.

You can use this build process with any version of VisionEval (with appropriate changes to
configuration files describing that version).

This installer addresses two VisionEval use cases:
	1. Enable developers to run and test VisionEval in an environment comparable to what end users would have
	1. Enable end users to install VisionEval with little effort on any computer that supports R

The following outputs are available:
	* Self-contained VisionEval "**local**" installation that will run on your development machine
	* Windows "**offline**" installer
	* Multi-Platform "**online**" installer that will get everything it needs from the web
	* [Under Construction] **Docker image** for any system running Docker
	* A **local R repository** with all the required VisionEval packages (including VisionEval itself)

# Development Environment Pre-Requisites

Prerequisites include the [current release version of R][currentR] for your development platform,
and a suitable development environment.

[currentR]: https://cran.r-project.org "Download and Install R"

The scripting is driven by scripts for GNU bash, but the substantive work is done in R
scripts that can be run interactively in R.  Just `setwd()` to the "build" subfolder and
source the scripts, or go to the build directory and run Rscript in Powershell or Windows
CMD).

You can also initiate an [RStudio][getRstudio] project at the root of the installer directories (where
this ReadMe.md file lives) and run the scripts from within RStudio.  The
self-contained VisionEval installation that results from this installer includes
"VisionEval.Rproj" which you can double-click to interact with the end-user VisionEval
environment.

[getRstudio]: https://www.rstudio.com/products/rstudio/download/ "Download RStudio"

You can get GNU bash and a complete environment for managing VisionEval source code by
installing [Git for Windows][Git4W].  On a Linux machine, GNU bash is the standard command
line.

[Git4W]: https://gitforwindows.org "Git for Windows"

You will also need a few R packages, but the build scripts will install those if they
don't have them (though you must provide a writable library directory to store them in -
see below).

## Pre-Requisite: RTools for Windows

To build the installers on a Windows system, you need to install [RTools][getRTools].
Installing RTools (or, for that matter, R itself if installed just for the "current user")
does not require administrator rights, but you will need to point the installer at a
writable directory (i.e. one that you as a user have write permission for). It also
helps to put the RTools bin directory at the head of your path (otherwise the repository
build process may fail if the Git for Windows version of "tar" is called during the R
package build process, rather than the RTools version).

[getRTools]: https://cran.r-project.org/bin/windows/Rtools/Rtools35.exe "RTools for R 3.5"

## Linux build pre-requisites

In order to install from source on Linux, some additional system-level dependencies
exist (required libraries that some of the binary dependency packages use).  This
ReadMe.md does not review how to install R itself on Linux - you just need to make
sure you have the "dev"(elopment) version so you get the compilers and libraries
needed to compile the dependencies from source.

On Ubuntu 16.04, installing the following packages will be needed (plus X11 and a few
other odds and ends - watch for errors when you try to run the "offline" installation).

To build "cairo" (used for nice image rendering):

```bash
sudo apt-get install libcairo2-dev
# Reportedly, you also need libxt-dev, which I already had
```

To build "V8" (used for who knows what):

```bash
sudo apt-get libv8-dev
```

# Steps to Build

The build process is script-based and takes place in R.  For now, all the scripts required
to construct a runtime installation of VisionEval (that you can use locally) or the
offline and online .zip file installers are found in the **build** directory.

## Setup a writable library for development tools

One of the important features of this installer is that the development environment and
runtime environment are pretty cleanly separated.  You'll need some packages to run the
installer, though the scripts will attempt to install them from CRAN if you happen not
to have them already.

To support that, you may need to set up an .Rprofile/.Renviron/environment variables that
makes a writable R library (for your development tools) available.  See Rprofile-sample
for an example of what might do the trick. R has extensive documentation on this requiremenet.

## Deciding which VisionEval to build

In the "dependencies" directory, you will need to create VE-config.R.  The samples you
will find there have comments explaining what you must set up and what is optional.  The
key is to point at the VisionEval source tree that you have cloned or downloaded from
Github or some other repository location.

You'll also need to adjust VE-dependencies.csv to coincide with the needs of the VE you
are planning to build.  VE-dependencides is a table of VisionEval dependencies and
elements that will be built during the process. There are examples, and a ReadMe that
explains the format.  The order is important only int that you should list dependencies
first (particularly among the VisionEval packages themselves, which depend on each other).
Follow the .travis.yml file in the VE repository, or look at the install.R script.  All
important VE releases will eventually have working dependency files available here.

I'm also working on an R script that will comb the VE source tree and automatically find
the R dependencies.  It's harder to automated recognition of VisionEval code for the models,
but for now, it just takes the `sources/models` directory in toto and presumes something
good will come of that.  Stay tuned...

## Running the build process

The script-based build process is hosted in the "build" subdirectory.

The master build script can be run in Linux or Git for Windows Bash (or more generally, in
the MSys for Windows Bash). Here's a complete summary of the required steps for initiating
a build

```bash
pwd # should be the root of your VisionEval-install clone
pushd dependencies
edit VE-config.R     # set ve.root to the VisionEval clone to install
edit VE-dependencies # list dependencies (see ReadMe.md in that folder, plus examples)
popd
pushd build
nohup bash Build.sh >build.out 2>&1 & tail -f build.out
```

I recommend the `nohup` line (rather than just `bash Build.sh`) because it will
let you close the bash window, and the redirection will save errors and warnings so you
can mull over what went wrong.  You don't need the "tail -f build.out" addendum; it's
handy to have the output show up in near-realtime if you're impatient.

You can run the build steps individual, as long as the earlier steps have already been
successfully completed.  Just execute the `Rscript xxx.R` command from a bash command line
with the working directory set to "build".  Do the scripts in the order listed in Build.sh.

Once you have completed the steps leading up to `Rscript build-packages.R` you don't need
to do those again unless the project dependencies chanage.  So you can fiddle with
VisionEval modules or models and then just pick up the build process from
`build-packages.R`.  You should empty out the built installer's `runtime` folder prior to
rerunning the scripts (as written, the scripts will not overwrite anything that's already
there).  You don't have to delete the `VE-Installer*.zip` files because they are always
built from scratch.

# Key outputs of the build process

The build process constructs your VisionEval runtime, installers and supporting files in a
directory called `installer_YYMMDD`, where YYMMDD is the date you ran the installation
program.  You can define `ve.output` to something different in your R profile (e.g. changing
the name to match the version of VisionEval you're installing).

Note that the default naming scheme may change.  Inside the `ve.output` folder, you will
find the following:

Item | Contents
--------- | --------
pkg-repository | R repository with all built and required packages (for online installer)
ve-lib | Library of installed packages for Windows (used to build "offline" installer)
runtime | the VisionEval folder with the installed / installable elements (see below)
VE-installer.zip | the online installer (needs access to a miniCRAN)
VE-installer-windows-R3.5.1.zip | the offline Windows installer

# Running VisionEval locally

The "runtime" directory in your install directory is a ready-to-run installation of
VisionEval.  Just change to the runtime directory and start R.  If it doesn't come
right up with "Welcome to VisionEval!", you can "kick" it by doing this:

    setwd("runtime")
    source("Install-VisionEval.R")
    load("RunVisionEval.RData")

Later, you can start VisionEval just by changing to the runtime directory and
starting R (or setting up an R shortcut with the "Start In" folder set to your runtime).

Alternatively, on Windows, you can run the Install-VisionEval.bat file, then double-click
RunVisionEval.RData.

Eventually, there may be an InnoSetup installer for Windows as well as a Docker image.

# Publishing the installers

The .zip files that you'll find in your "installer" root directory (where all the built
stuff is) can be published to the web.  I've included a bash script in the build directory
that I use to push the updated installers and miniCRAN to my website,
visioneval.jeremyraw.com.
