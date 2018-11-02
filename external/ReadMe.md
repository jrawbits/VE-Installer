This folder contains items that need to be installed but are not built
as part of VisionEval itself.  There are some scripts that will bring
in and build external components:

* namedCapture (Github package installed as a submodule
* rsync (developer tool; only needed for website synchronization)

We could put installers for consistent versions of R and Rtools for
Windows here if we decide not to track the current R release for some
reason.

If the namedCapture submodule is empty, do this:
cd install/external/namedCapture
git submodule update --init --recursive

When installing from source on an Ubuntu 16.04 machine (running X,
and with a complete development environment, including r-base (3.5.1)
and r-base-dev (3.5.1), a couple of packages would not build from source
without additional configuration.

To build "cairo" (used for nice image rendering):
sudo apt-get install libcairo2-dev
(Reportedly, you also need libxt-dev, which I already had)

To build "V8" (used for who knows what):
sudo apt-get libv8-dev

