# External files

This folder contains items that need to be installed but are not built
as part of VisionEval itself.  There are some scripts that will bring
in and build external components:

* rsync (developer tool; only needed for website synchronization)

We could put installers for consistent versions of R and Rtools for
Windows here if we decide not to track the current R release for some
reason.

if the `dependencies\VE-dependencies.csv` includes any "install"
dependencies, then those can be located here (the dependencies
file lets them be placed anywhere in the VE installer hierarchy,
just by adjusting the dependency Path element).  The package
name should be a subfolder.

You may want to add any external packages for your version of
VisionEval to .gitignore, in order not to accidentally commit
them to a repository.

## System Level Dependencies

The build system does not address system-level dependencies (i.e.
those outside of R).  That won't affect Windows builds, but it may
affect Linux builds since the system will need certain files.  You
can examine the docker images to ensure that your development system
has everything it needs (or just use a package installer for your
operating system to add packages if any of the build fails).

When installing from source on an Ubuntu 16.04 machine (running X,
and with a complete development environment, including r-base (3.5.1)
and r-base-dev (3.5.1), a couple of packages would not build from source
without additional configuration.

To build "cairo" (used for nice image rendering):
sudo apt-get install libcairo2-dev
(Reportedly, you also need libxt-dev, which I already had)

To build "V8" (used for who knows what):
sudo apt-get libv8-dev

