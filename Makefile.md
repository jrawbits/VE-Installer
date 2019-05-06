This file provides extensive explanation and commentary on the Makefile used to build
VisionEval with the VE-Installer.

The first part sets up necessary environment variables:

<dl>
    <dt>VE_CONFIG</dt>
    <dd>Location of the configuration file for this run. Defaults to
       `config/VE-config.yml` which does not exist until you create it.
       You can override it by setting it as an environment variable, or
       specifying it on the make command line.</dd>
    <dt>VE_RUNTESTS</dt>
    <dd>Generally, just leave this as "Default".  If TRUE, tests will
       be run when the VE modules are built. If FALSE tests will be
       skipped.  The default is pulled from VE-Config.yml, but may be
       overridden by setting an environment variable, or by specifying it
       on the make command line.</dd>
    <dt>VE_R_VERSION</dt>
    <dd>The R Version for which to build VisionEval. On Linux, this
       variable is forced to match whatever R is installed.  On
       Windows, it uses a helper batch file to find (and optionally
       install) the requested version of R.  This must be one of the
       versions identifed in r-versions.yml in the root of the
       VE-Installer (though that file is easy to extend).</dd>
    <dt>VE_LOGS, VE_RUNTIME_CONFIG, VE_MAKEVARS</dt>
    <dd>These are files constructed during the build to keep track of
       information passed from one step to another.  VE_LOGS is used
       to record log and status information on the build.
       VE_RUNTIME_CONFIG is used to keep R variables describing what
       is being built, dependencies, build locations, etc.
       VE_MAKEVARS contains additional variables used in this make
       process that are generated from VE-Config.yml.</dd>
    <dt>VE_BOILERPLATE</dt>
    <dd>Contains the path to the boilerplate configuration file;
       used to keep from recopying the boilerplate if it is already up
       to date</dd>
</dl>


~~~
# You can override VE_CONFIG, VE_RUNTESTS and VE_R_VERSION on the command line
VE_CONFIG?=config/VE-config.yml
VE_RUNTESTS?=Default
ifeq ($(OS),Windows_NT)
  VE_R_VERSION?=3.5.3
  RSCRIPT:="$(shell scripts/find-R.bat $(VE_R_VERSION))"
  WINDOWS=TRUE
else
  # If you change the PATH to point at a different Rscript, you can
  # support multiple R versions on Linux, but it's done outside the Makefile
  RSCRIPT:="$(shell which Rscript)"
  override VE_R_VERSION:=$(shell $(RSCRIPT) --no-init-file scripts/find-R.R)
  WINDOWS=FALSE
endif
export VE_R_VERSION VE_CONFIG VE_RUNTESTS RSCRIPT

VE_LOGS:=logs/$(VE_R_VERSION)
VE_RUNTIME_CONFIG:=$(VE_LOGS)/dependencies.RData
VE_MAKEVARS:=$(VE_LOGS)/ve-output.make
export VE_LOGS VE_RUNTIME_CONFIG VE_MAKEVARS

VE_BOILERPLATE:=$(wildcard boilerplate/boilerplate*.lst)
~~~

The "include" directive forces the file identified by VE_MAKEVARS to
be rebuilt if it is out of date compared to VE-Config.yml. The
makefile is then reloaded.  VE_MAKEVARS includes definitions of lots
of important locations that are set up in the configuration so the
makefile can inspect and build them suitably.

~~~
include $(VE_MAKEVARS)
# $(VE_MAKEVARS) gets rebuilt (see below) if it is out of date, using state-dependencies.R
# Make then auto-restarts to read:
#   VE_OUTPUT, VE_CACHE, VE_LIB, VE_INSTALLER, VE_PLATFORM, VE_TEST
#   and others
~~~

.PHONY make targets are things you can ask to build that do not
generate a file.  They will always get "built", but make won't bother
to see if there's an up-to-date target.

~~~
.PHONY: configure repository modules binary runtime installers all\
	clean lib-clean runtime-clean build-clean test-clean modules-clean\
	dev-clean really-clean\
	docker-clean docker-output-clean docker
~~~

all is a target that builds the basic runtime by building each of the
steps (or verifying that they are up to date).  See the subsequent
targets for configure, repository, binary, modules and runtime

~~~
all: configure repository binary modules runtime
~~~

Use `make show-defaults` to dump some of make's key variables. Use to
debug environment variables and command line definitions.

~~~
show-defaults:
	echo Make defaults:
	echo VE_R_VERSION $(VE_R_VERSION)
	echo WINDOWS $(WINDOWS)
	echo VE_CONFIG $(VE_CONFIG)
	echo RSCRIPT $(RSCRIPT)
	echo VE_OUTPUT $(VE_OUTPUT)
~~~

The following 'clean' targets will blow away various artifacts of
previous builds and force make to start again.

~~~
# Should have the "clean" target depend on $(VE_MAKEVARS) if it uses
# any of the folders like VE_OUTPUT that are read in from there.
clean: $(VE_MAKEVARS) build-clean
	rm -rf $(VE_OUTPUT)/$(VE_R_VERSION)

lib-clean: $(VE_MAKEVARS)
	rm -f $(VE_LOGS)/modules.built
	rm -rf $(VE_REPOS)/*
	rm -rf $(VE_LIB)/visioneval $(VE_LIB)/VE*

runtime-clean: $(VE_MAKEVARS)
	rm -rf $(VE_RUNTIME)/*
	rm -f $(VE_LOGS)/runtime.built

build-clean:
        # Use "*dependencies" to catch "all-dependencies.RData"
	rm -rf $(VE_LOGS)/*
	rm -f *.out

modules-clean:
	rm -f $(VE_LOGS)/modules.built

dev-clean:
	rm -rf dev-lib/$(VE_R_VERSION)

installer-clean: $(VE_MAKEVARS)
# installers have the R version coded in their .zip name
	rm -f $(VE_OUTPUT)/$(VE_R_VERSION)/*.zip
	rm -rf $(VE_PKGS)/*
	rm -f $(VE_LOGS)/installer*.built

depends-clean: clean
	rm -rf $(VE_DEPS)/*

test-clean: $(VE_MAKEVARS)
	rm -rf $(VE_TEST)/*

really-clean: $(VE_MAKEVARS) build-clean dev-clean
	rm -rf $(VE_OUTPUT)/$(VE_R_VERSION)
~~~

Finally, we get down to the targets that do real work:

<dl>
   <dt>configure</dt><dd>Parses VE-config.yml into R and make
      variables and structures.</dd>
   <dt>repository</dt><dd>Downloads the dependencies from CRAN,
      BioConductor and Github into a single local repository</dd>
   <dt>binary</dt><dd>Installs dependencies into the local library,
      ve-lib </dd>
   <dt>modules</dt><dd>Builds source and binary packages from the VE
      modules and installs them into the local library, ve-lib</dd>
   <dt>runtime</dt><dd>Copies non-package modules into the runtime -
      the startup scripts will locate ve-lib to complete the
      local installation.</dd>
   <dt>installer or installer-bin</dt><dd>Builds a binary installer
      for the development machine architecture (typically Windows)</dd>
   <dt>installer-src</dt><dd>Buils a source installer that will work
      on any architecture with R and a development environment -
      currently the only way to bundla an install for Mac or Linux.</dd>
   <dt>installers</dt><dd>Builds installer-bin and installer-src</dd>
</dl>

~~~
configure: $(VE_RUNTIME_CONFIG) $(VE_MAKEVARS)

# Note: state-dependencies.R identifies VE_CONFIG via the exported variable
$(VE_MAKEVARS) $(VE_RUNTIME_CONFIG): scripts/state-dependencies.R $(VE_CONFIG) R-versions.yml
	mkdir -p $(VE_LOGS)
	mkdir -p dev-lib/$(VE_R_VERSION)
	$(RSCRIPT) scripts/state-dependencies.R

repository: $(VE_LOGS)/repository.built

$(VE_LOGS)/repository.built: $(VE_RUNTIME_CONFIG) scripts/build-repository.R scripts/build-external-src.R
	$(RSCRIPT) scripts/build-repository.R
	$(RSCRIPT) scripts/build-external-src.R
	touch $(VE_LOGS)/repository.built

binary: $(VE_LOGS)/binary.built

$(VE_LOGS)/binary.built: $(VE_LOGS)/repository.built scripts/install-velib.R scripts/build-external-bin.R
	$(RSCRIPT) scripts/install-velib.R
	$(RSCRIPT) scripts/build-external-bin.R
	touch $(VE_LOGS)/binary.built

modules: $(VE_LOGS)/modules.built

$(VE_LOGS)/modules.built: $(VE_LOGS)/binary.built $(VE_RUNTIME_CONFIG) scripts/build-modules.R
	$(RSCRIPT) scripts/build-modules.R
	touch $(VE_LOGS)/modules.built

runtime: $(VE_LOGS)/runtime.built

$(VE_LOGS)/runtime.built: $(VE_RUNTIME_CONFIG) $(VE_BOILERPLATE) scripts/setup-sources.R
	$(RSCRIPT) scripts/setup-sources.R
	touch $(VE_LOGS)/runtime.built

installer: installer-bin

installers: installer-bin installer-src

installer-bin: $(VE_LOGS)/installer-bin.built

$(VE_LOGS)/installer-bin.built: $(VE_RUNTIME_CONFIG) $(VE_LOGS)/runtime.built
	bash scripts/build-installers.sh BINARY
	touch $(VE_LOGS)/installer-bin.built

installer-src: $(VE_LOGS)/installer-src.built

$(VE_LOGS)/installer-src.built: $(VE_LOGS)/installer-bin.built
	$(RSCRIPT) scripts/runtime-packages.R
	bash scripts/build-installers.sh SOURCE
	touch $(VE_LOGS)/installer-src.built
~~~

Finally, there's some Docker stuff not documented here, since it's
still under construction and what is in the Makefile doesn't current
work.
