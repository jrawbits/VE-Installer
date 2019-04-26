# Building and Installing VisionEval

The `VE-Installer` is a build system that makes a VisionEval source tree "installable",
and to facilitate development and testing of VisionEval.

To use it, just clone it, setup the configuration file, install a development environment,
and build suitable `make` targets, including a runtime environment and an installer.  Full
instructions and references materials are included below and in various referenced files.

You can use this build process with any version of VisionEval (with appropriate changes to
configuration files describing that version), though for older versions, you will need to
construct a suitable "VE-components.yml" file.  The process for doing so is described in
detail in the most recent updates of the [VisionEval-dev repository][VE-dev].

[VE-dev]: https://github.com/visioneval/VisionEval-dev "VisionEval Development"

Full instructions for installing and using VE-Installer are presented below. The
configuration file is described in its own ReadMe.md file in the "config" subdirectory.

This installer addresses two VisionEval use cases:

1. Enable developers to run and test VisionEval in an environment comparable to what
end users would have.
1. Enable end users to install a runnable VisionEval with little effort on any
computer that supports R.

To use the VE-Installer, just clone it, install a development environment, setup the
configuration file, and run suitable `make` targets to build (for example) a runtime
environment and an installer.  Full instructions and references materials are included
below and in various referenced files.

[VE-dev]: https://github.com/visioneval/VisionEval-dev "VisionEval Development"
[VEInstaller]: https://github.com/visioneval/VE-Installer "VisionEval Installer"

# What You Get

The following back-end outputs are available:

* Self-contained VisionEval "**local**" installation that will run on your development machine
* (optional) Windows "**offline**" installer (or the equivalent for your development system architecture)
* (optional) Multi-Platform "**offline**" installer that will build VisionEval from source packages
* [Under Construction] **Docker images** for any system running Docker

# Getting Started

* Install [RTools][getRTools]
        * You need an implementation of GNU Make and Info-Zip (available in RTools
          as `make.exe` and `zip.exe` respectively)
* Install [Git for Windows][Git4W]
        * You need an implementation of GNU bash to run some of the scripts
        * Having command-line git is handy for accessing repositories
        * Recommendations for setting up Git for Windows below
* Clone [VE-Installer][VEInstaller] and [VisionEval-dev][VE-dev]
        * As of this writing, you want the "development" branch
        * Configuration will be simplest if VE-Installer and VisionEval-dev are
          subdirectories of the same directory
* Configure Git for Windows `bash` shell (instructions later on)
        * Add RTools to the Windows PATH
        * Set up `bash` so you can easily get to the VE-Installer/build folder
        * Set up any SSH keys or other credentials you may need for Github
* Edit the VE-Installer/config/VE-config.yml file so it points at your VisionEval-dev
        * ve.root : full path in which to look for VisionEval itself (defaults to
          "../VisionEval.dev" (".." relative to home of VE-Installer)
        * ve.output : Path in which to create gigabytes of output files (in subdirectories
          named after the version of R you used to build them, e.g. 3.5.3). "../VE-Built"
          will create a new directory adjacent to VE-Installer.
* Open Git for Windows Bash window
        * Do the setup called for above, if you haven't already
        * Change to the VE-Installer root folder
                * cd /path/to/VE-Installer
        * Run these commands from the Bash command prompt
                * Build the runtime: `bash build-VE.sh 3.5.3` (defaults to 3.5.3)
                * Build an installer: `bash build-VE-sh 3.5.3 installer
        * If you have the VE-Installer native version of R installed (currently 3.5.3),
          you can just run `bash build-VE.sh`, or even just `make` to assemble a
          runtime.
* Once complete, you can run VisionEval.bat in ve.output/3.x.x/runtime
        * ve.output is whatever you set it to in VE-Config.yml
        * If you built an installer, you'll find it in a zip file in the root
          of the build (ve.output/3.x.x).
* To launch VisionEval, just double-click VisionEval.bat (on Windows)
        * Or enter `bash visionval.sh` on Linux

Additional make targets snd setup (e.g. committing VisionEval changes to Github) are
discussed below.

# Development Environment Pre-Requisites

Prerequisites to build a VisionEval runtime environment or installer include a suitable
version of R (R >= 3.4.4), and a suitable development environment. We recommend the
[current release version of R][currentR] for your development platform.  On Windows, you
will need to install the [RTools][getRTools] suite, as well as [Git for Windows][Git4W] so
you can use `bash` scripts. On Linux, installing the R development package and
"development essentials" will typically do, though some of the R dependency packages may
require you to install additional Linux OS packages.

[currentR]: https://cran.r-project.org "Download and Install R"

The build process is driven by the GNU `make` program avaiable in RTools and in Linux.

[getRstudio]: https://www.rstudio.com/products/rstudio/download/ "Download RStudio"

You can get GNU bash and a complete environment for managing VisionEval source code (and
this builder) by installing [Git for Windows][Git4W].  On a Linux machine, GNU bash is the
standard command line interpreter. Installing Git for Windows does not require administrator rights.

[Git4W]: https://gitforwindows.org "Git for Windows"

You will also need quite a few R packages, but the build scripts will install those if
they don't have them (though you must have access to the internet). Packages needed by
VE-Installer are placed in a separate library from the packages needed to run VisionEval.
Look in the "dev-lib" subdirectory of VE-Installer after you've run the build, in the
3.x.x subdirectory corresponding to your version of R.

## Builder Pre-Requisite: RTools for Windows

To build the packages and installers on a Windows system, you need to install
[RTools][getRTools].  Installing RTools does not require administrator rights.  But you
will need to point the installer at a writable directory (i.e. one that you as a user have
write permission for). It also helps to put the RTools bin directory at the head of your
path (otherwise the repository build process may fail if the Git for Windows version of
"tar" is called during the R package build process, rather than the RTools version).

To edit the PATH (as a non-administrator) on Windows 10, hit the "start" box (Windows icon
at the end of the taskbar), just start typing "environment", the display will show the search
results. Pick "Edit environment variables for your account", select PATH from the list (or
create a PATH variable if it's not there), and enter the full path (drive and directory)
to "RTools/bin" (notice the "/bin"!).

[getRTools]: https://cran.r-project.org/bin/windows/Rtools/Rtools35.exe "RTools for R 3.5"

## Builder Pre-Requisite: Linux environment

A standard R installation on Linux (whether from a package repository or directly from
the R project) will include all the development tools needed to install source packages.

However, some additional system-level dependencies exist (required libraries that some of
the binary dependency packages use).  This ReadMe.md does not review how to install R
itself on Linux - standard installatons will include the compilers and related tools
needed to build the VisionEval dependencies from source.

You can also look at the the `docker/Dockerfile` for system dependencies needed (beyond
those already included in the base Docker image, `rocker/r-ver`).

On Ubuntu 18.04, installing the following packages will probably be needed (plus X11 and a
few other odds and ends - watch for errors when the build scripts try to build the
externals and packages).

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
`master` with your chosen branch such as `development`) selects a specific branch, which may
often be necessary if the default is some obsolete version languishing in `master` or if
it contains a documentation tree.  Naming the folder to clone into (`My-VisionEval` in the
example above) makes it simple to clone different branches to different places.

Note that cloning with `--depth=1` only gets one branch, so you can't change branches
within a repository clone created that way.  There are switches to change that behavior
that you can look up for yourself.

## Building, Rebuilding and Updating dependencies

In this version of VE-Installer, dependencies are managed directly from VisionEval-dev.
You need to locate the `build/VE-components.yml` file.  If you need to put
VE-components.yml somewhere else (e.g. if you're building an older version of VisionEval
and had to make VE-components.yml yourself), just create a location called "ve.components"
in your VE-Config.yml (relative to one of the "roots").  See the ReadMe.md for
VE-config.yml for further instructions.

## Running the build process

You can use either `make` directly (with various command line options) or the simpler
bash script `build-VE.sh` to build the elements of VisionEval.  The bash script can
build any of the targets listed below, but you do need to name the R version explicitly
(e.g `bash build-VE.sh 3.5.3 repository` - whereas `bash build-VE.sh` will do the
same thing as `make` (i.e. make everything) using the version of R that VE-Installer
currently prefers (not necessarily one you have installed!).

Learning to use make will give you much greater flexibility in selecting build targets,
rebuidling things, or using different R versions comapared to using the script.

Here is how to use make:

* `make`
  Just do it!  Defaults to `make configure; make repository; make binary; make runtime`
  see below
* `make configure`
  This reads your VE-config.yml and turns it into something the other scripts can use.
  Nothing else can happen until this step completes successfully.
* `make repository`
  Builds a local package repository with all the VisionEval dependencies (and
  their dependencies, and their dependencies, and so on all the way down). At the end
  of this step, you will have source and Windows binary packages for all the
  dependencies, plus built source packages (only) for any Github packages. Packages
  can come from CRAN, BioConductor, or Github.
* `make binary`
  Builds VisionEval binaries and install them for the machine architecture
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
* `make runtime`
  Copy non-package source files and test data to the runtime folder (basis for
  the installers, and also for a local runtime test environment for the developer)
* `make installer` or `make installer-bin`
  Packages up a binary installer as a .zip file. You can also make a source
  installer (twice the size) that would work on Macintosh or Linux using `make installer-src`
* `make docker`
  This target builds a docker image; see the **docker** subdirectory and its
  ReadMe.md for details. **This target is currently broken, due to the change in
  how the VisionEval dependency configuration is handled.**

### Sitting back and watching the build

Rather than just running `make` I recommend that you give yourself
and your computer some freedom.  Do something like this instead:

```bash
nohup make >make.out 2>&1 & tail -f make.out
```

I recommend the `nohup` line because it will let you close the bash window, and the
redirection will save errors and warnings so you can later mull over what went wrong.  You
don't need the "tail -f build.out" addendum (after the lone ampersand); it's just a way to
look at the build output while the background process is running. You can Ctrl-C the tail
process and the build will keep going.  To see later where it is, you can just rerun the
`tail -f make.out` or `tail -f build.out` command to start watching again.

### Remember to build fresh to make an installer

If you are plannign to distribute one of the .zip installers, you should build from
scratch (run `make really-clean` and then `make installer`).
Otherwise you risk including obsolete dependencies. That's probably harmless; it just
makes the installer bigger than necessary.

# Key outputs of the build process

Inside the `ve.output\3.x.x` folder, you will find the following:

**Table needs to be updated**
Item | Contents
--------- | --------
home | Only present if you ran `make docker` - this is the basis for the docker image
pkg-repository | R repository with all built and required packages (for online installer)
runtime | the VisionEval folder with the installed / installable elements (see below)
ve-lib | Library of installed packages for Windows (used to build "offline" installer)
VE-installer.zip | the online installer (needs access to a miniCRAN)
VE-installer-windows-R3.5.1.zip | the offline Windows installer

If you build on a Linux system, you'll get `VE-installer-unix-R3.x.x.zip` as the offline
binary installer instead.  If you `make installer` on Linux or Mac, you'll get a "unix"
installer suitable for your local architecture.

# Running VisionEval locally

The "runtime" directory in your install output directory is a ready-to-run installation of
VisionEval.  Just change to the runtime directory and run the VisionEval.bat (or
VisionEval.sh) start scripts.  Do that every time you want to start VisionEval.  Make
a shortcut if you prefer.

The startup is very fast on Windows, but on other systems where you do a "source"
installation, it can take a long time (though typically under an hour) to build a native
`ve-lib`. Startup will subsequently be much faster. 

The self-contained VisionEval installation that results from this builder (and is included
in the installers) includes "VisionEval.Rproj" which a runtime user can double-click to
interact with the end-user VisionEval environment using RStudio.  You should run the batch
file (or shell script) one time to set everything up before going to work in RStudio. Once
the basic installation is complete, just open the .Rproj file.

# Docker Images

See the Docker Readme.md in the **docker** directory for an explanation of how to
build the Docker images for VisionEval, and also what they provide.  You can use
`make docker` to build the images, provided you're on a system that supports
bash-scripted command line docker instructions (typically a Linux system, rather
than Windows, though there's no reason the latter shouldn't work as long as the
command line tools are available).
