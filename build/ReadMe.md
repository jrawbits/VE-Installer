# Build System

This `build` directory is home to the VisionEval build system, a mechanism to
systematically rebuild a runtime environment and installers for VisionEval, and
optionally a docker image (on systems equipped to run Docker).

This root directory contains this ReadMe.md file, as well as the Makefile and a
sample Rprofile file (to be edited and copied in this directory to `.Rprofile`).

The Makefile is the preferred driver for the build process since it is smart about
not rebuilding things unnecessarily.  You can also use `bash scripts/Build.sh` as a
driver (or run the scripts from this folder as `Rscript scripts/script.R` or `bash
scripts/script.sh`.

The `.Rprofile` (or alternatively, .Renviron, with different syntax) should include
instructions to identify a writeable library directory where R can find or install
the needed development packages (such as miniCRAN) which do not need to be available
for the VisionEval runtime.

The folder can also contain an optional file `website.credentials` that is accessed
by the optional `scripts/publish-installers.sh` script.  The credentials file should
set the shell variables WWW_SSH_PORT and VE_WEBSITE.  Alternatively, you can set
those in your .bashrc or as Windows environment variables.  You don't need any of
that if you're not using the `publish-installers.sh` script.

Various other files will be placed in this directory as part of the build process.
These include R- and make-accessible descriptions of the build environment (`*.Rdata`
and `ve-output.make`), and various tracking files (`*.built`) to indicate which build
steps have successfully completed).  The .gitignore will also ignore any `*.out` file
which may be used to capture the output from `make` or `Build.sh`.
