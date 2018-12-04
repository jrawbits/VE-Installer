# Boilerplat Folder

The `boilerplate` consists of scripts that are copied into the runtime
root folder.  The scripts will install the runtime library for the current
platform and set up an .RData file the loads the VisionEval framework.

The `setup-sources.R` in `build/scripts` simply copies these into the runtime
root where they can be used to activate the developer's built runtime
environment, or zipped up into both the online and offline installers.

Note that the `models` sub-directory is a hack:  the VERSPM and VERPAT
scripts are stable, and we just have versions of them here that use
the as-yet-unaccepted hack to have model initialization look at a full
path for the location of the model script so script and data can be
separated.  Once that change propagates into the main VisionEval,
these files can probably be eliminated in favor of bringing the
model scripts over from ve.root.
