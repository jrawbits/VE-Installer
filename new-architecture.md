## New VisionEval architecture

### Immediate changes (for June release).

Set up VE-Installer to create an "intermediate source" installer

* VE-Installer will handle the "full stack" installation (and also be the rock-bottom point of
reference for "standard" code)
* End users will have the option of downloading a zipfile of "RStudio-ready" packages that installs
directly into the runtime environment created by unzipping an installer (in a new "src" directory
at the same tree-level as "models", "ve-lib", "tools", and the new "docs" folder (see below).
* They can use those source trees for debugging (stepping through code with full debug support) and
for lightweight tweaks and development (e.g. re-estimating one of the models from a different set of
initial data, fixing bugs) or even for developing a new module or package.
* Create a "docs" folder, with a "framework" and "modules" sub-directory; the former will contain
PDFs of the "api" documentation, the latter PDFs of each module's module_docs. VE-Installer will
build this folder once the framework and modules have been built by PDF-ing the .md files in each
module's module docs, and the api folder for the framework.  We can also include arbitrary additional
documents like the Getting Started Guid and the Concept Primer by specifying them in the build/VE-components.yml and including their
source in the code tree.

## Long-term Build Changes

Once people are used to that change (which is transparent for the current codebase), we can
re-architect VisionEval and the VE-Installer full build to work much better and more reliably (and
give developers better information about code/data/specification problems long before we get to
runtime). In the world of software develpment, an error caught during the build process is worth a
dozen hours of debugging the same problem in a broken runtime.

### Description of new module code architecture

So here's the full build re-architecting, which is only slightly intrusive on each module, requires
a bit of hacking on the framework (new functions), and a certain amount of corresponding work on
VE-Installer.

The key step is to wrap each of three key steps in module creation into functions:
* Model Estimation
* Specification Creation
* Module Documentation
* The runtime package functions that support doing a model will still get created at the top level
of the module R script outside a function

That way, an intermediate end user can continue to re-create distributed packages using the standard
RStudio package (re-)build process. But by default, the RStudio package build will expect that all
the estimation data and module specifications have already been created and are up to date in the
source "data" directory (and if the user needs to rebuild them, they just run framework functions on
their "intermediate source" version of the module, then do an RStudio package build).

There are many advantages to that:

  * It allows much more nuanced debugging of each of the steps either in VE-Installer or interactively
(without all the R CMD check irrelevancies - though we'll still do the check on the final package
before it's rendered into the end-user installer), and we can leverage a lot of the framework checks
so they can be applied during development, not just at runtime.
  * It means that when people rebuild a package from the "intermediate source", they won't do model
estimation and re-creation of the "data" folder or the specifications or the documentation unless
they deliberately and explicitly call those functions prior to doing the RStudio package build. That
will make the build process almost instantaneous if you're just working on code fixes or debugging.
And if you want to make new data (because of changed inputs or specifications), you just run the
framework "data build" function on your module before doing the RStudio package build.
  * We can build a lot of test/consistency logic into the new framework Specification Loader function
so people can debug their specifications internally at least without having to get as far as a full
model run / datastore creation (in fact, that logic is probably mostly there, we just push it to the
front so it happens at development time, not just at runtime).
  * We can rebuild documentation outside of a full package build (speeding up that whole process and
respecting everyone's standard workflow, which is to make the code work then to write the
documentation). As a sub-task of this, I'm going to change the location/character of "module_docs"
so that we just call them what they are: R vignettes, rather than creating our own custom location
for them. I'm also going to change VE-Installer so that it assembles the finished versions as PDFs
into a "modules" subfolder of a runtime "docs" folder (and of course do that for the framework too,
which has a different more manual mechanism for building its documentation).
  * We can deliver a function to end users (working with the "intermediate source" distribution) to
re-estimate models using their own local datasets. Then the user just runs the Model Estimation
framework function with their module's intermediate source location as a parameter, the function
does whatever it does now (pulling from insta/ext_data or data_raw or wherever) and drops the
results into the "intermediate source" data directory. Then the user just does the standard Rstudio
package build to reinstall their modified version into ve-lib.
  * People don't need to mess with the full VE-Installer environment unless they want to build a
"bootstrap" version of VisionEval (recreating ve-lib, or making a new installer, or readying their
new module or changes for CRAN-like submission to the Github).
  * Speaking of Github, we can recreate the repository so none of the giant binary datafiles are
included. That way cloning will be very fast (just including the "source", though some of that
may be binary input files for model estimation or standard reference - but those won't change
much and we won't end up with 50 copies of them).
  * We will still insist that packages be submitted to Github in "bootstrap-able" form, which will
include a few other things not needed for "intermediate source":
    * VE-Config-MyBranch.yml file to drive VE-Installer
    * build/VE-components.yml file that lays out the dependencies, though I'm planning to parse the
module package's R DESCRIPTION file for that ultimately)
  * models/MyTestModel hierarchy (if what is being submitted is a module) so we are guaranteed
to have a working sample model (they will have the option of identifying an existing test model
that will still work with their changes, e.g. if they just fixed a bug in a module or otherwise
didn't change the input/output specs).
  * Create a framework helper function that will move (and identify missing) necessary files
from an "intermediate source" folder that has been hacked back into a specified git-controlled
folder on the developer's local machine (baseically identifying and copying back into git all the
items in the previous bullet). That way people can hack the intermediate source, and when they've
got something working, they can run a framework function to identify and move all the requirements
back into their Github clone/fork, where they can then run the full VE-Installer.
  * Make VE-Installer generate a summary check log for each package (probably including output
of tests etc) so if people submit a pull request, we can require that they demonstrate (via also
submitting the log as part of the pull request) that they succeeeded in getting their changes to run
through VE-Installer (and all the package/module/test model steps).
  * Move the "docs/modules/module_docs" stuff into the R vignettes mechanism, so you get a buildable
vignette document, rather than a document buried deeply in a non-standard place in ve-lib. That will supplement the interim hack of placing the module_docs in the runtime "docs" directory.
