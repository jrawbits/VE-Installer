# Building and Installing VisionEval

The `VE-Installer` side project" makes a VisionEval source tree "installable".  To
use it, just clone it, setup the configuration file, install a development environment,
and build suitable `make` targets.

As of Version 2 of VE-Installer, the dependency information is maintained in the 
VisionEval source tree itself (and will eventually be used to execute consistent
continuous integration tests).  See [VisionEval-dev][VE-dev] for information on 
the dependencies.

[VE-dev]: https://github.com/visioneval/VisionEval-dev "VisionEval Development"

Full instructions for installing and using VE-Installer below presented below. The
configuration file is described in its own ReadMe.md file in the "config" subdirectory.

You can use this build process with any version of VisionEval (with appropriate changes to
configuration files describing that version), though you will need to construct a suitable
"VE-components.yml" file.

This installer addresses two VisionEval use cases:

1. Enable developers to run and test VisionEval in an environment comparable to what
end users would have.
1. Enable end users to install a runnable VisionEval with little effort on any
computer that supports R.

To use the VE-Installer, just clone it, install a development environment, setup the
configuration file, and run suitable `make` targets, including a runtime environment and
an installer.  Full instructions and references materials are included below and in
various referenced files.

You can use this build process with any version of VisionEval, though for older versions,
you will need to construct a suitable "VE-components.yml" file.  The process for setting
up that file is described in detail in the most recent code branches of the
[VisionEval-dev repository][VE-dev].

[VE-dev]: https://github.com/visioneval/VisionEval-dev "VisionEval Development"
[VEInstaller]: https://github.com/visioneval/VE-Installer "VisionEval Installer"

Full instructions for installing and using VE-Installer below presented below.

# What You Get

The following back-end outputs are available:

* Self-contained VisionEval "**local**" installation that will run on your development machine
* (optional) Windows "**offline**" installer (or the equivalent for your development system architecture)
* (optional) Multi-Platform "**offline**" installer that will build VisionEval from source packages
* [Under Construction] **Docker images** for any system running Docker

# Getting Started

* Install [RTools][getRTools]
* Install [Git for Windows][Git4W]
* Clone [VE-Installer][VEInstaller] and checkout the "new-deps" branch
* Clone [VisionEval-dev][VE-dev] and checkout the "new-deps-0403" branch or equivalent
* Configure Git for Windows `bash` shell
        * Add RTools to the Git for Windows PATH
        * Set up `bash` so you can easily get to the VE-Installer/build folder
* Edit the VE-Installer/config/VE-config.yml file so it points at your VisionEval-dev
        * ve.output : full path in which to create the "R 3.x.x" output files
        * ve.root : full path in which to look for VisionEval itself
* Open Git for Windows Bash window
        * Change to the VE-Installer root folder
        * Run `make VE_R_VERSION=3.x.x` where you substitute your R version for the 3.x.x
                * `make` by itself is equivalent to `make VE_R_VERSION=3.5.3`
                * `make installers` VE_R_VERSION=3.x.x` will also build the .zip files
        * If you do not specify VE_R_VERSION, `make` will default to the R version that
          was current when VE-Installer was last updated.
* Once complete, you can run VisionEval.bat in ve.output/3.x.x/runtime
        * Or you can build the installers and use the resulting windows .zip to reinstall
          VisionEval in an arbitrary location as if you had downloaded it.

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
standard command line interpreter.

[Git4W]: https://gitforwindows.org "Git for Windows"

You will also need a few R packages, but the build scripts will install those if they
don't have them (though you must have access to the internet and you must provide a
writable library directory to store them in - see below).  End users will not need these
tools.

## Builder Pre-Requisite: RTools for Windows

To build the packages and installers on a Windows system, you need to install
[RTools][getRTools].  Installing RTools does not require administrator right.  But you
will need to point the installer at a writable directory (i.e. one that you as a user have
write permission for). It also helps to put the RTools bin directory at the head of your
path (otherwise the repository build process may fail if the Git for Windows version of
"tar" is called during the R package build process, rather than the RTools version).

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

# Steps to Build

The build process is script-based and takes place in R.  For now, all the scripts
required to construct a runtime installation of VisionEval (that you can use locally)
or the offline and online .zip file installers are found in the **build** directory
and its **scripts** subdirectory,though elements in other directories are used by
reference.

As of builder-v0.1, there is a Makefile which makes it easier to rebuild sub-elements
of the overall installation.  The Makefile is pretty dumb about out-dated
dependencies - it is good about not rebuilding things unnecessarily, but if you want
something rebuilt, you still have to delete it manually.

Here's how to get going on building a runtime environment or installer:

## Setup a writable library for development tools

One of the important features of this installer is that the development environment and
runtime environment are pretty cleanly separated.  You'll need some packages to run the
installer builder, though the scripts will attempt to install them from CRAN if you happen not
to have them already.

To support that, you may need to set up .Rprofile/.Renviron/environment variables that
makes a writable R library (for your development tools) available.  See Rprofile-sample
for an example of what might do the trick. R has [extensive documentation][RStartup] on
setting up the environment through startup files.

[RStartup]: https://stat.ethz.ch/R-manual/R-devel/library/base/html/Startup.html "R Startup"

## Deciding which VisionEval to build

In the "dependencies" directory, you will need to create VE-config.R.  The samples you
will find there have comments explaining what you must set up and what is optional.  The
key is to point at the VisionEval source tree that you have cloned or downloaded from
Github or some other repository location.  You should also make sure that the VisionEval
source tree has checked out the branch that you would like to build.

The simplest way to get a VisionEval source tree to install is to clone it from Github.
If you have Git for Windows (or just `git` on Linux), you can do this:

```
git clone --depth=1 -b master https://github.com/VisionEval/VisionEval.git VE-master
```

Using `depth=1` saves you copying gigabytes of binary files that were produced in earlier
test runs and committed unnecessarily to the repository.  Using the `-b` option (replace
`master` with your chosen branch such as `develop`) selects a specific branch, which may
often be necessary if the default is some obsolete version languishing in `master` or if
it contains a documentation tree.  Naming the folder to clone into (`VE-master` in the
example above) makes it simple to clone different branches to different places.

Note that cloning with `--depth=1` only gets one branch, so you can't change branches
within a repository clone created that way.  There are switches to change that behavior
that you can look up for yourself.

## Building, Rebuilding and Updating dependencies

You'll also need to adjust VE-dependencies.csv to coincide with the needs of the VE you
are planning to build.  VE-dependencides is a table of VisionEval dependencies and
elements that will be built into the runtime and installers. There are examples, and a
ReadMe, that explain the format in the `dependencies` folder.  The order is important only
in that you should list dependencies of the same type in the order you would like to build
them.  That's especially true for the VisionEval packages themselves, which depend on each
other and have to be built in a specific order. All important VE releases will eventually
have working dependency files available here.  If you want to handle a new VisionEval, you
can pivot off the existing examples, and use the .travis.yml or Install.R scripts (though
these usually have dependencies listed that you may not actually need).

Because the build process is rather smart about not rebuilding things that already exist
in its output folders, it is easy to restart `build.sh` (or `make`) if something goes
wrong (of course, you do have to fix whatever failed).  But that's a pretty easy way to
get the packages to tell you what they need (just don't list any dependencies, wait for
failure, add the ones that are missing, restart build.sh/make from the top).  That won't work
for the model scripts or VEGUI, which are not currently packages - a simple "grep" through
their .R files looking for "library" or "require" statements will reveal them (your text
editor has command to comb across files and directories looking for terms like that,
right?).

If you want to remove a package from a build, you should explicitly delete the build target
(e.g. built package, local repository, installer) and rerun the corresponding build script.
It is always a good idea to re-run `state-dependencies.R` before you do anything else so
you are sure to pick up any changes to the build configuration files.  The Makefile allows
all of that to be easily done.

## Running the build process

The script-based build process is hosted in the "build" subdirectory.  You can run a
`bash` script, use `make`, or run individual steps with `Rscript` (or `bash`)

**Important** You must set up `dependencies/VE-config.R` and
`dependencies/VE-dependencies.csv` before you start building, or the builder will get
huffy...

### Building with make

`make` is under active development to drive the build process.  RTools comes with GNU
make, and you will also have it in any Linux environment. As of builder-v0.1, you change
to the `build` directory and use the following make targets once you have configured the
VE version and the dependencies.

* `make`
  Just do it!  Defaults to `make repository; make binary; make runtime; make installers;`
  see below
* `make repository`
  Builds the "miniCRAN" package repository with all the VisionEval dependencies (and
  their dependencies, and their dependencies, and so on all the way down). At the end
  of this step, you will have source and Windows binary packages for all the
  dependencies, plus built source packages (only) for VisionEval and Github packages.
* `make binary`
  Builds VisionEval binaries and install them for the machine architecture
  of your development environment.  If you want Windows binaries, run this on a
  Windows machine.  You can use it to create a runtime for Linux or Macintosh if
  that's where you're developing.  After running this step, you'll have a local
  runtime environment that you can install just like an end user.  See below.
* make runtime
  Copy non-package source files and test data to the runtime folder (basis for
  the installers, and also for a local runtime test environment for the developer)
* `make installers`
  Packages up installers:  the offline installer always, and the binary
  offline installer if you previously ran `make binary`.
* `make publish`
  You'll need to configure a website and security credentials in your bash
  environment, but once you've done that, this will push the package repository, the
  skeletal website and the built installers out to the web.
* `make docker`
  This target builds a docker image; see the **docker** subdirectory and its
  ReadMe.md for details.

### Building with bash Build.sh

The master build script can be run in Linux or Git for Windows Bash (or more generally, in
the MSys for Windows Bash). Here's a complete summary of the required steps for initiating
a build (in bash):

```bash
pwd # should be the root of your VisionEval-install clone
pushd dependencies
edit VE-config.R     # set ve.root to the VisionEval clone to install
edit VE-dependencies # list dependencies (see ReadMe.md in that folder, plus examples)
popd
pushd build
bash scripts/Build.sh
```

### Sitting back and watching the build

Rather than just running `make` or `bash Build.sh` I recommend that you give yourself
and your computer some freedom.  Do one of these instead:

```bash
nohup make >make.out 2>&1 & tail -f make.out
```

```bash
nohup bash scripts/Build.sh >build.out 2>&1 & tail -f build.out
```

I recommend the `nohup` line because it will let you close the bash window, and the
redirection will save errors and warnings so you can later mull over what went wrong.  You
don't need the "tail -f build.out" addendum (after the lone ampersand); it's just a way to
look at the build output while the background process is running. You can Ctrl-C the tail
process and the build will keep going.  To see later where it is, you can just rerun the
`tail -f make.out` or `tail -f build.out` command to start watching again.

### Building interactively from within R

You can run the build steps individually as R scripts, either using Rscript or by sourcing
them into an R session (either RGUI or RStudio).  Just execute the `Rscript xxx.R` command
from a bash command line with the working directory set to "build".  Do the scripts in the
order listed in Build.sh.  Note that the step that builds the installer zip files is a
Bash script, not an R script.  If you don't have Bash, you can easily put an installer
together manually:

* the online installer just wraps up the contents of the `runtime` folder from the
  installer build output (with `runtime` as the working directory).
* The offline installer just adds the `ve-lib` folder from the installer build
  output as if it were a sub-directory of `runtime`.

Once you have completed the steps leading up to `Rscript build-packages-src.R` (which
build the local repository and the install dependencies) you don't need to do those again
unless the project dependencies change.  So you can fiddle with VisionEval modules or
models and then just pick up the build process from `build-packages-src.R`.  You should
empty out the built installer's `runtime` folder prior to rerunning the scripts (as
written, the scripts will not overwrite anything that's already there).  Delete the
installer .zip files if you are using `make` and would like to rebuild them that way.

If you are plannign to distribute one of the .zip installers, you should build from
scratch (set a new ve.output directory, or delete everything in the current one).
Otherwise you risk including obsolete dependencies. That's probably harmless; it just
makes the installer bigger than necessary.

# Key outputs of the build process

The build process constructs your VisionEval runtime, installers and supporting files in a
directory called (by default) `installer_YYMMDD`, where YYMMDD is the date you ran the
installation program.  You can define `ve.output` to something different in your
`VE-config.R` file (e.g. changing the name to match the version of VisionEval you're
installing).

Inside the `ve.output` folder, you will find the following:

Item | Contents
--------- | --------
home | Only present if you ran `make docker` - this is the basis for the docker image
pkg-repository | R repository with all built and required packages (for online installer)
runtime | the VisionEval folder with the installed / installable elements (see below)
ve-lib | Library of installed packages for Windows (used to build "offline" installer)
VE-installer.zip | the online installer (needs access to a miniCRAN)
VE-installer-windows-R3.5.1.zip | the offline Windows installer

If you build on a Linux system, you'll get `VE-installer-unix-R3.5.1.zip` as the offline
binary installer instead.  If you `make binary` on Linux or Mac, you'll get a "unix"
installer suitable for your local architecture.

# Running VisionEval locally

The "runtime" directory in your install output directory is a ready-to-run installation of
VisionEval.  Just change to the runtime directory and start R.  If it doesn't come right
up with "Welcome to VisionEval!", you can "kick" it by doing this:

    setwd("runtime")
    source("Install-VisionEval.R")
    load("RunVisionEval.RData")

The installation is very fast on Windows, but on other systems you get a "source"
installation that is used to build a native `ve-lib`. That entails compiling some large
dependencies and VisionEval itself, which can take a while (typically well under an
hour).

Later, you can start VisionEval just by changing to the runtime directory and
starting R (or setting up an R shortcut with the "Start In" folder set to your runtime).

The self-contained VisionEval installation that results from this builder (and is included
in the installers) includes "VisionEval.Rproj" which a runtime user can double-click to
interact with the end-user VisionEval environment using RStudio.

Alternatively, on Windows, you can run the Install-VisionEval.bat file, then double-click
RunVisionEval.RData.  But those shortcuts won't work unless you were able to install R
as an "administrator" of your system.

# Docker Images

See the Docker Readme.md in the **docker** directory for an explanation of how to
build the Docker images for VisionEval, and also what they provide.  You can use
`make docker` to build the images, provided you're on a system that supports
bash-scripted command line docker instructions (typically a Linux system, rather
than Windows, though there's no reason the latter shouldn't work as long as the
command line tools are available).

# Publishing the installers

The .zip files that you'll find in your "installer" root directory (where all the built
stuff is) can be published to the web.  I've included a bash script in the build directory
that I use to push the updated installers and package repository to my website,
[https://visioneval.jeremyraw.com](https://visioneval.jeremyraw.com)

There's also the **www** folder which contains a skeletal .html-based website used
to power my website, but you can safely ignore it.
