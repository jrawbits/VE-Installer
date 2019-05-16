# Building and Installing VisionEval

The `VE-Installer` is a build system that makes a VisionEval source tree "installable",
and that facilitates development and testing of VisionEval.

This installer addresses two VisionEval use cases:

1. Enable developers to run and test VisionEval in an environment comparable to what
end users would have.
1. Enable end users to install a runnable VisionEval with little effort on any
computer that supports R.

## Overview

To use VE-Installer, just clone it, setup the configuration file, install a development
environment (Linux R-base-dev, Windows R plus RTools), then build suitable `make` targets,
such as the runtime environment and an installer.  Full instructions and reference
materials are included below and in various referenced files.

You can use VE-Installer with any version of VisionEval (with appropriate changes to
configuration files describing that version). For older versions, you will need to
construct a suitable `VE-components.yml` file. Newer versions already have a suitable
`VE-components.yml`.  The process for doing so is described in detail in the most recent
updates of the [VisionEval-dev repository][VE-dev], and in the `config/ReadMe.md` here in
VE-Installer.

[VE-dev]: https://github.com/visioneval/VisionEval-dev "VisionEval Development"

Full instructions for installing and using `VE-Installer` are presented below. The
configuration file which describes what to build is described in its own ReadMe.md file in
the `config` subdirectory (along with a primer on the required `VE-components.yml` file).

[VE-dev]: https://github.com/visioneval/VisionEval-dev "VisionEval Development"
[VEInstaller]: https://github.com/visioneval/VE-Installer "VisionEval Installer"

## What You Get

The following back-end outputs are available:

* Self-contained VisionEval "**local**" installation that will run on your development machine
* (optional) Windows "**offline**" installer (or the equivalent for your development system architecture)
* (optional) Multi-Platform "**offline**" installer that will build VisionEval from source packages
* [Under Construction] **Docker images** for any system running Docker

# Getting Started

To use the VE-Installer, just clone it, install a development environment, setup the
configuration file, and run suitable `make` targets to build (for example) a runtime
environment and an installer.  Full instructions and references materials are included
below and in various referenced files.

* Install [RTools][getRTools]
    * You need an implementation of GNU Make and Info-Zip (available in RTools
      as `make.exe` and `zip.exe` respectively)
    * Put RTools at the beginning of your PATH, either by setting user environment
      variables or by adjusting PATH in your `.bashrc` file.
* Install [Git for Windows][Git4W]
    * You need an implementation of GNU bash and GNU tools to run some of the scripts
    * Having command-line git is handy for accessing repositories
    * Recommendations for setting up Git for Windows below
* Clone [VE-Installer][VEInstaller] and [VisionEval-dev][VE-dev]
    * As of this writing, you want the "development" branch
    * Configuration will be simplest if VE-Installer and VisionEval-dev are
      subdirectories of the same parent directory
* Configure Git for Windows `bash` shell
    * Add RTools to the Windows PATH
    * Set up `bash` so you can easily get to the VE-Installer/build folder
    * Set up any SSH keys or other credentials you may need for Github access
* Edit the VE-Installer/config/VE-config.yml file so it points at your VisionEval-dev
    * ve.root : full path in which to look for VisionEval itself (defaults to
      "../VisionEval.dev" (".." relative to home of VE-Installer)
    * ve.output : Path in which to create gigabytes of output files (in subdirectories
      named after the version of R you used to build them, e.g. 3.5.3). "../VE-Built"
      will create a new directory adjacent to VE-Installer (and make a subfolder called
      "3.5.3" to hold the built files if you choose VE_R_VERSION=3.5.3).
* Run the build from a Git for Windows Bash window
    * Open a bash window
    * Change to the VE-Installer root folder
        * cd /path/to/VE-Installer
    * Run these commands from the Bash command prompt
        * Build the runtime: `bash build-VE.sh 3.5.2` (defaults to 3.5.3)
        * Build an installer: `bash build-VE-sh 3.5.3 installer
    * If you have the VE-Installer native version of R installed (currently 3.5.3),
      you can just run `bash build-VE.sh`, or even just `make` to assemble a
      runtime.
* Once complete, you can run VisionEval.bat in ve.output/3.x.x/runtime in order to start R
  and load VisionEval.
    * ve.output is whatever you set it to in VE-Config.yml (see above)
    * If you built an installer, you'll find it in a zip file in the root
      of the build (ve.output/3.x.x).
* To launch VisionEval, just double-click VisionEval.bat (on Windows)
    * Or enter `bash visionval.sh` on Linux

Additional make targets snd setup (e.g. committing VisionEval changes to Github) are
discussed below.

# Development Environment Pre-Requisites

Prerequisites to build a VisionEval runtime environment or installer include a suitable
version of R (R >= 3.4.4), and a suitable development environment.

On Windows, you will need to install the [RTools][getRTools] suite, as well as [Git for
Windows][Git4W] so you can use `bash` scripts. On Linux, installing the R development
package and "development essentials" will typically do, though some of the R dependency
packages may require you to install additional Linux OS packages.

## Builder Pre-Requisite: A supported version of `R`

We recommend the [current release version of R][currentR] for your development platform.

[currentR]: https://cran.r-project.org "Download and Install R"

You will also need quite a few R packages, and the build scripts will install the suitable
version of those for your version of R (though you must have access to the internet).
Packages needed by VE-Installer are placed in a their own library to avoid contaminating
VisionEval's own dependencies.  Look in the "dev-lib" subdirectory of VE-Installer after
you've run the build, in the 3.x.x subdirectory corresponding to your version of R.

## Builder Pre-Requisite: Bash Shell Environment and GNU tools

The build process is driven by the GNU `make` program avaiable in RTools and in Linux.

You can get GNU bash and a complete environment for managing VisionEval source code (and
this builder) by installing [Git for Windows][Git4W].  On a Linux machine, GNU bash is the
standard command line interpreter. Installing Git for Windows does not require administrator rights.

[Git4W]: https://gitforwindows.org "Git for Windows"

### Windows Environment

To build the packages and installers on a Windows system, you need to install
[RTools][getRTools].  Installing RTools does not require administrator rights.  But you
will need to point the installer at a writable directory (i.e. one that you as a user have
write permission for). It also helps to put the RTools bin directory at the head of your
PATH (otherwise the repository build process may fail if the Git for Windows version of
"tar" is called during the R package build process, rather than the RTools version).

To edit the PATH (as a non-administrator) on Windows 10, hit the "start" box (Windows icon
at the end of the taskbar), just start typing "environment", the display will show the search
results. Pick "Edit environment variables for your account", then select PATH from the list (or
create a PATH variable if it's not there), and enter the full path (drive and directory)
to "RTools/bin" (notice the "/bin"!).

If for some reason you don't want to re-order the PATH, you can also avoid build problems
by adding `export TAR=internal` to your `.bashrc`, or putting `TAR=internal` into your
Windows user environment.  The `tar` program in Git for Windows does not work with R.

[getRTools]: https://cran.r-project.org/bin/windows/Rtools/Rtools35.exe "RTools for R 3.5"

### Linux environment

A standard R installation with `r-base-dev` on Linux (whether from a package repository or
directly from the R project) will include all the development tools needed to install
source packages.

However, some additional system-level dependencies exist (required libraries that some of
the binary dependency packages use).

You can also look at the the `docker/Dockerfile` for system dependencies needed (beyond
those already included in the base Docker image, `rocker/r-ver`). A future version of
VisionEval will include the required non-standard Linux libraries as explicit dependencies.

On Ubuntu 18.04, installing the following packages will probably be needed (plus X11 and a
few other odds and ends - watch for errors when the build scripts try to build the
externals and dependency packages).

To build "cairo" (used for nice image rendering):

```bash
sudo apt-get install libcairo2-dev
# Reportedly, you also need libxt-dev, which I already had
```

To build "V8" (used for who knows what):

```bash
sudo apt-get install libv8-dev
```

## Getting VisionEval code to build

The simplest way to get a VisionEval source tree to install is to clone it from Github.
If you have Git for Windows (or just `git` on Linux), you can do this:

```
git clone --depth=1 -b master https://github.com/VisionEval/VisionEval-dev.git My-VisionEval
```

Using `depth=1` saves you copying gigabytes of binary files that were produced in earlier
test runs and committed unnecessarily to the repository.  Using the `-b` option (replace
`master` with your chosen branch such as `development`) selects a specific branch, which
may often be necessary if the default is some obsolete version languishing in `master` or
if the repository offers a documentation tree as the default branch (as does
VisionEval-dev).  Naming the folder in which to put the clone (`My-VisionEval` in the
example above) makes it simple to clone different branches (or VisionEval repositories) to
different places.

Note that cloning with `--depth=1` only gets one branch, so you can't change branches
within a repository clone created that way. Look at `git clone` documentation on --depth
for further information.

## Building, Rebuilding and Updating dependencies

In this version of VE-Installer, dependencies are managed directly from the VisionEval
github tree via the `build/VE-components.yml` file.  If you need to put VE-components.yml
somewhere else (e.g. if you're building an older version of VisionEval and had to make
VE-components.yml yourself), just create a location called "ve.components" in your
VE-Config.yml (relative to one of the "roots").  See the ReadMe.md for VE-config.yml for
further instructions.

## Running the build process

You can use `make` (with various command line options described below) to build
VisionEval.  A simple bash script is also provideded to run a "one line" build without
having to mess with options.  The script is useful if you want to build multiple runtimes
for different R versions.  You can also use the script to build any of the targets
listed below, but you do need to name the R version explicitly (e.g `bash build-VE.sh
3.5.3 repository` - whereas `bash build-VE.sh` will do the same thing as `make` (i.e. make
everything) using the version of R that VE-Installer currently prefers (not necessarily
one you have installed!).

Learning to use make will give you much greater flexibility in selecting build targets,
rebuidling things, or using different R versions.

Here is an overview of how to use make:

* `make`
  Just do it!  Defaults to `make configure; make repository; make binary; make runtime`
  see below. You get a built VisionEval that you can run on your local machine.
* `make configure`
  This reads your VE-config.yml and turns it into something the other scripts can use.
  Nothing else can happen until this step completes successfully, so if you're having
  trouble, start here until your configuration is working.
* `make repository`
  Builds a local package repository with all the VisionEval dependencies (and
  their dependencies, and their dependencies, and so on all the way down). At the end
  of this step, you will have source and Windows binary packages for all the
  dependencies, plus built source packages (only) for any Github packages. Packages
  can come from CRAN, BioConductor, or Github.
* `make binary`
  Builds VisionEval binaries and installs them for the machine architecture
  of your development environment.  If you want Windows binaries, run this on a
  Windows machine.  Likewise, you can use it to create a runtime for Linux or
  Macintosh if that's where you're developing.  After running this step, you'll
  have a local runtime environment that you can activate just like an end user.
* `make modules`
  Here's where the action is. This will build source and binary versions of the
  VisionEval framework and modules.  If you set the variable VE_RUNTESTS=TRUE,
  the builder will perform R CMD check and run the development tests for each
  module.  To set the variable, you can do one of these three things:
    * in the bash shell, before calling `make` or `build-VE.sh` do `export VE_RUNTESTS=TRUE`
    * Add VE_RUNTESTS to the make command line: `make VE_RUNTESTS=TRUE ...`
    * Add VE_RUNTESTS to the `build-VE.sh` command line: `bash build-VE.sh 3.5.3 VE_RUNTESTS=TRUE ...`
  Note that if you want to rebuild (or retest) any built packages, you should
  manually delete them from the ve.lib location. See below.
* `make runtime`
  Copy non-package source files and test data to the runtime folder (basis for
  the installers, and also for a local runtime test environment for the developer)
* `make installer` or `make installer-bin`
  Packages up a binary installer as a .zip file. You can also make a source
  installer (twice the size) that would work on Macintosh or Linux using `make installer-src`,
  but that is a slow process that generates a gigantic file so you probably don't
  want to do it.
* `make docker`
  This target builds a docker image; see the `docker` subdirectory and its
  ReadMe.md for details. **This target is currently broken, due to the change in
  how the VisionEval dependency configuration is handled.**

### Sitting back and watching the build

Rather than just running `make` we recommend that you give yourself and your computer some
freedom.  Do something like this instead:

```bash
nohup make >make.out 2>&1 & tail -f make.out
```

I recommend the `nohup` line because it will let you close the bash window, and the
redirection will save errors and warnings so you can later mull over what went wrong.  You
don't need the "tail -f make.out" addendum (after the lone ampersand); it's just a way to
look at the build output while the background process is running. You can Ctrl-C the tail
process and the build will keep going.  To see later where it is, you can just rerun the
`tail -f make.out` command to start watching again.

### Rebuilding after you change the VisionEval sources

The `make` process is set up to do as little repetitive work as possible. There are
several `make` targets that will undo some of what you have built so as to check and
rebuild things that would otherwise be untouched.  Here is a list of those targets
that tell `make` to take a closer look at what is built.  It will still try to do as
little as possible:

* `make build-clean`
  This target will remove all the log file output (in the `logs` subdirectory of
  VE-installer). It will also remove the parsed configuration file data.  Use this
  target if you change `VE-config.yml` or if any of the VisionEval package dependencies
  have been changed, or if you want to use a different value for VE_RUNTESTS
* `make lib-clean`
  Perform `build-clean` and `test-clean` then also delete all the built VisionEval packages
  (source and binary).  Use this if have already built the packages but want to change
  the value of VE_RUNTESTS or if you have checked out a different VisionEval branch and
  want to rebuild everything without completely redoing all the dependency downloads.
* `make runtime-clean`
  Removes the model scripts, VEGUI and other source files from the runtime.  They will be
  copied again when the runtime is next built.  Use this if you have deleted or renamed
  files for the runtime.  New or modified files will always be copied when the runtime is
  built.
* `make installer-clean`
  Removes any installer `.zip` files and supporting data in the package source repository
* `make dev-clean`
  Removes the packages that were downloaded into the development library. Those development
  library contains packages used by the installer, but not required by VisionEval itself.
  They will be downloaded again as needed when you subsequently run `make`.
* `make depends-clean`
  Removes the downloaded package dependencies so the local repository can be rebuilt.
* `make test-clean`
  Removes test data, test results and the copies of the module sources used for testiong
* `make clean`
  Remove the standard output files, but leave behind things like dependencies if
  they have been stored in an alternate output root location. See documentation of
  VE-Config.yml.  Same as running `build-clean` and `test-clean` and then removing
  all the other files in the configured output location.
* `make really-clean`
  This target combines `clean`, `depends-clean` and `dev-clean`

### Remember to build fresh to make an installer

If you are planning to distribute one of the .zip installers, you should build from
scratch (run `make really-clean` and then `make installer`).
Otherwise you risk including obsolete dependencies. That's probably harmless; it just
makes the installer bigger than necessary.

### Using the Installer to develop VisionEval packages and models

VE-Installer is designed not to do a lot of time-consuming redundant work.  It uses
file time stampts to manage most of that.  So if you're developing a model and you
change Run_Model.R, you can just run `make` and that file (only) will get recopied
to your runtime.

The same thing happens with modules. So if you're working (for example) on VEScenario
(a module which, as of this writing, needs work), you can just go and edit the
package code, DESCRIPTION or whatever and when you next run `make`, VE-Installer will
recognize that files were changed and will (only) rebuild VEScenario.

The result is an easy workflow:

* Edit something in your VisionEval clone
* Run `make build-clean` to force an update status on all VisionEval files
* Run `make` from a bash window with VE-Installer as working directory
* Lather, rinse, repeat until you've got it to build without errors
    * Extra credit: run `make lib-clean; make VE_RUNTESTS=TRUE`
* Run `VisionEval.bat` from your runtime output folder and try out
  the modules and models
* Repeat from the top until it all does what you want without errors.

# Key outputs of the build process

Inside the `ve.output\3.x.x` folder, you will find the following:

Item | Contents
--------- | --------
external | Location where Github dependency packages are cloned and built from
pkg-dependencies | CRAN and BioConductor package repository (source and Windows binary\*) for dependencies
pkg-repository | Repository of built VisionEval packages (source and Windows binary\*)
runtime | the VisionEval folder with the installed / installable elements (see below)
tests | Copies of the VisionEval TestData and package folders used for running tests and saving test output
ve-lib | Library of installed packages for the local machine architecture
ve-pkg | Repository of source packages (VisionEval plus dependencies) used in source installer (optional)
VE-Runtime-Rx.x.x.zip | Just the runtime folder (for the local architecture and R version x.x.x) zipped up
VE-installer-Windows-Rx.x.x.zip | the offline Windows installer for end users using R version x.x.x
VE-installer-Source-Rs.x.x.zip | the offline source installer for end users using R version x.x.x

Inside the VE-Installer hierarchy, you will find the following new (built) directories (with
sub-directories for each R version you have used to perform the build):

Item | Contents
--------- | --------
dev-lib | Package library for dependencies used by VE-Installer itself (but not necessarily by VisionEval)
logs | Log files and tracking files constructed during the build.

Remember that logs from the `R CMD check` tests go into sub-directories of each module's
copy in the output `tests` folder.

\* If building on a Windows machine.

If you `make installer` on Linux or Mac, you'll get a "unix" installer suitable for your local architecture.
Run `make installer-src` to make the offline source installer.  Run `make installer-clean` to force
the installers to be rebuilt.

# Running VisionEval locally

The "runtime" directory in your install output directory is a ready-to-run installation of
VisionEval.  Just change to the runtime directory and run the VisionEval.bat (or
VisionEval.sh) start scripts.  Do that every time you want to start VisionEval.  Make
a shortcut if you prefer.

The startup is very fast on Windows, but on other systems where you do a "source"
installation, it can take a long time (though typically under an hour) to build a native
`ve-lib` the first time you run it. Startup will subsequently be much faster. 

The self-contained VisionEval installation that results from this builder (and is included
in the installers) includes "VisionEval.Rproj" which a runtime user can double-click to
interact with the end-user VisionEval environment using [RStudio][getRstudio].  You should
run the batch file (or shell script) one time to set everything up before going to work in
RStudio. Once the basic installation is complete, just open the .Rproj file.

[getRstudio]: https://www.rstudio.com/products/rstudio/download/ "Download RStudio"

# Docker Images

**Warning: Docker build currently doesn't work**.

See the Docker Readme.md in the **docker** directory for an explanation of how to
build the Docker images for VisionEval, and also what they provide.  You can use
`make docker` to build the images, provided you're on a system that supports
bash-scripted command line docker instructions (typically a Linux system, rather
than Windows, though there's no reason the latter shouldn't work as long as the
command line tools are available).
