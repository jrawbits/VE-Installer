The "build" folder contains R scripts and resources necessary to build a runnable
VisionEval, using resources in the other folders.

# Pre-Requisites

Prerequisites include R and a suitable development environment.

You should install RTools if you're planning to build Windows binaries.  You will also
need a few R packages, but the build scripts will install those if they don't have them
(though you must provide a writable library directory to store them in - see below).  If
you're planning to build from source on Windows you should expect to download a bunch of
supporting libraries.

## Linux build dependencies

On Ubuntu 16.04, installing the following packages will be needed (plus X11 and a few
other odds and ends - watch for errors in the installation).

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

The build process is evolving torward a complete Makefile with useful targets.  For now,
all the scripts required to construct a runtime installation of VisionEval (that you can
use locally) or the offline and online .zip file installers are found in the **build**
directory.

## Setup a writable library for development tools

One of the important features of this installer is that the development environment and
runtime environment are pretty cleanly separated.  The development environment will
eventually be fully managed in "packrat", and the build steps implemented as a Makefile
that can be run from within Rstudio's build process (though more flexibly from a Bash
command line, where you can pick subsets of the dependencies, rather than being forced to
"build all").

To support that, you may need to set up an .Rprofile that pushes a writable R library (for
your development tools) onto R's .libPaths().  See Rprofile-sample for an example of what
to do - you need to provide a path to a writable directory that will be your library for
development tools.

## Deciding which VisionEval to build

In the "dependencies" directory, you will need to create VE-config.R.  The samples you
will find there have comments explaining what you must set up and what is optional.

You'll also need to adjust VE-dependencies.csv to coincide with the needs of the VE you
are planning to build.  VE-dependencides is a table of VisionEval dependencies and
elements that will be built during the process There are examples, and a ReadMe that
explains the format.  The order is important only insofar as the things that you should
list dependencies first (particularly among the VisionEval packages themselves, which
depend on each other).  Follow the .travis.yml file in the VE repository, or look at the
install.R script.  All important VE releases will eventually have working dependency files
available here.

## Running the build process

The script-based build process is hosted in the "build" subdirectory.  It is evolving
toward a full Makefile.

The build can be run in Linux or Git for Windows Bash (or more generally, in the MSys for
Windows Bash):

```bash
pwd # should be the root of your VisionEval-install clone
pushd dependencies
edit VE-config.R     # set ve.root to the VisionEval clone to install
edit VE-dependencies # list dependencies (see ReadMe.md in that folder)
popd
pushd build
nohup bash Build.sh >build.out 2>&1 & tail -f build.out
```

I recommend the "nohup" line (rather than just "bash Build.sh") because it will
let you close the bash window, and the redirection will save errors and warnings so you
can mull over what went wrong.  You don't need the "tail -f build.out" addendum; it's
handy to have the output show up in near-realtime if you're impatient.

You can run the build steps individual, as long as the earlier steps have already been
successfully completed.  Just execute the "Rscript xxx.R" command from a bash command line
with the working directory set to "build".  So if you need to tweak the packages, you
can just run the steps starting at "Rscript build-packages.R".

# Key outputs of the build process

The build process constructs your VisionEval runtime, installers and supporting files in a
directory called "installer_YYMMDD", where YYMMDD is the date you ran the installation
program.  You can define **ve.output** to something different in your R profile (e.g. changing
the name to match the version of VisionEval you're installing).

Note that the default naming scheme may change.  Inside the ve.output folder, you will
find the following:

Item | Contents
--------- | --------
built-packages | Contains "src" and (if you're on Windows) "bin" folders for VE and Github packages
miniCRAN | Contains an R repository with all built and required packages (for online installer)
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

Eventually, there may be an InnoSetup installer for Windows as well as a docker image.

# Publishing the installers

The .zip files that you'll find in your "installer" root directory (where all the
built stuff is) can be published to the web.  I've included a bash script that I use
to push the updated installers and miniCRAN to my website, visioneval.jeremyraw.com.
