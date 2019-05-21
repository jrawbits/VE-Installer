# You can override VE_CONFIG, VE_RUNTESTS and VE_R_VERSION on the command line
# Or change export them from your environment
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

include $(VE_MAKEVARS)
# $(VE_MAKEVARS) gets rebuilt (see below) if it is out of date, using state-dependencies.R
# Make then auto-restarts to read:
#   VE_OUTPUT, VE_CACHE, VE_LIB, VE_INSTALLER, VE_PLATFORM, VE_TEST
#   and others

.PHONY: configure repository modules binary runtime installers all\
	clean lib-clean runtime-clean build-clean test-clean\
	dev-clean really-clean\
	docker-clean docker-output-clean docker

all: configure repository binary modules runtime

show-defaults:
	echo Make defaults:
	echo VE_R_VERSION $(VE_R_VERSION)
	echo WINDOWS $(WINDOWS)
	echo VE_CONFIG $(VE_CONFIG)
	echo RSCRIPT $(RSCRIPT)
	echo VE_OUTPUT $(VE_OUTPUT)
	echo VE_DEPS $(VE_DEPS)
	

# Should have the "clean" target depend on $(VE_MAKEVARS) if it uses
# any of the folders like VE_OUTPUT that are read in from there.
clean: $(VE_MAKEVARS) build-clean test-clean
	rm -rf $(VE_OUTPUT)/$(VE_R_VERSION)

lib-clean: $(VE_MAKEVARS) build-clean test-clean
	rm -rf $(VE_REPOS)/*
	rm -rf $(VE_LIB)/visioneval $(VE_LIB)/VE*

runtime-clean: $(VE_MAKEVARS)
	rm -rf $(VE_RUNTIME)/*

build-clean:
	rm -rf $(VE_LOGS)/*
	rm -f *.out

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

really-clean: clean depends-clean dev-clean

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

# We'll always "build" the modules and the runtime, but only out-of-date stuff
# gets built (file time stamps are checked in the R scripts)
modules: $(VE_LOGS)/binary.built $(VE_RUNTIME_CONFIG) scripts/build-modules.R
	$(RSCRIPT) scripts/build-modules.R

runtime: $(VE_RUNTIME_CONFIG) $(VE_BOILERPLATE) scripts/setup-sources.R
	$(RSCRIPT) scripts/setup-sources.R

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

# Experimental Docker installation
# Docker work all happens here (not in a separate shell script)

# Warning: Docker is broken due to use of VE_ROOT (not set), which
# includes multiple possible locations with the YAML configuration
# We'll need to move the Docker stuff back into (probably R) scripts

ifeq ($(WINDOWS),TRUE)
docker-output-clean docker-clean docker:
	echo Docker building is not available on Windows
else
VE_DOCKER_IN=docker
VE_DOCKER_OUT=$(VE_OUTPUT)/$(VE_R_VERSION)/Docker
DOCKERFILE=$(VE_DOCKER_IN)/Dockerfile

docker-output-clean:
	sudo rm -rf ${VE_DOCKER_OUT}/Data # Files within are owned by 'root'
docker-clean: docker-output-clean
	rm -rf $(VE_DOCKER_OUT)/home
	
docker: $(VE_LOGS)/repository.built $(DOCKERFILE) $(VE_DOCKER_IN)/.dockerignore
	bash scripts/build-docker.sh $(VE_ROOT)
endif
