# You can override the following variables on the command line
VE_R_VERSION?=3.5.1
VE_CONFIG?=../config/VE-config.yml
VE_RUNTESTS?=Default
export VE_R_VERSION VE_CONFIG VE_RUNTESTS


# The following currently only works on Windows
# Need to flex between batch file and path definition for Linux
# Workaround is to define RSCRIPT on the make command line
# RSCRIPT=$(which Rscript) # works on Linux

RSCRIPT:="$(shell ./find-R.bat $(VE_R_VERSION))"
export RSCRIPT

# ve-output.$(VE_R_VERSION).make gets rebuilt (see below) if it is out of date
# Make then auto-restarts
# Defines VE_OUTPUT, VE_CACHE, VE_LIB, VE_INSTALLER, VE_PLATFORM, VE_TEST

include ve-output.$(VE_R_VERSION).make

.PHONY: configure repository modules binary runtime installers all\
	clean lib-clean runtime-clean build-clean cache-clean test-clean modules-clean\
	dev-clean\
	docker-clean docker-output-clean docker

all: configure repository binary modules runtime

# Make installers as a standalone step

clean: ve-output.$(VE_R_VERSION).make build-clean
	rm -rf $(VE_OUTPUT)/$(VE_R_VERSION)

lib-clean: ve-output.$(VE_R_VERSION).make
	rm -f modules.$(VE_R_VERSION).built
	rm -rf $(VE_PKGS)/*
	rm -rf $(VE_LIB)/visioneval $(VE_LIB)/VE*

runtime-clean: ve-output.$(VE_R_VERSION).make
	rm -rf $(VE_RUNTIME)/*
	rm -f runtime.$(VE_R_VERSION).built

build-clean:
	rm -f all-dependencies.$(VE_R_VERSION).RData dependencies.$(VE_R_VERSION).RData
	rm -f ve-output.$(VE_R_VERSION).make
	rm -f *.$(VE_R_VERSION).built
	rm -f *.out

modules-clean:
	rm -f modules.$(VE_R_VERSION).built

dev-clean:
	rm -rf dev-lib/$(VE_R_VERSION)

installers-clean:
# installers have the R version coded in their .zip name
	rm -f $(VE_OUTPUT)/$(VE_R_VERSION)/*.zip
	rm -f installers.$(VE_R_VERSION).built

cache-clean: clean
	rm -rf $(VE_CACHE)/*

test-clean: ve-output.$(VE_R_VERSION).make
	rm -rf $(VE_TEST)/*

configure: dependencies.$(VE_R_VERSION).RData ve-output.$(VE_R_VERSION).make

# Note: state-dependencies.R identifies VE_CONFIG via the exported variable
ve-output.$(VE_R_VERSION).make dependencies.$(VE_R_VERSION).RData: scripts/state-dependencies.R $(VE_CONFIG) R-versions.yml
	mkdir -p dev-lib/$(VE_R_VERSION)
	$(RSCRIPT) scripts/state-dependencies.R

repository: repository.$(VE_R_VERSION).built

repository.$(VE_R_VERSION).built: dependencies.$(VE_R_VERSION).RData scripts/build-repository.R scripts/build-external-src.R
	$(RSCRIPT) scripts/build-repository.R
	$(RSCRIPT) scripts/build-external-src.R
	touch repository.$(VE_R_VERSION).built

binary: binary.$(VE_R_VERSION).built

binary.$(VE_R_VERSION).built: repository.$(VE_R_VERSION).built scripts/install-velib.R scripts/build-external-bin.R
	$(RSCRIPT) scripts/install-velib.R
	$(RSCRIPT) scripts/build-external-bin.R
	touch binary.$(VE_R_VERSION).built

modules: modules.$(VE_R_VERSION).built

modules.$(VE_R_VERSION).built: binary.$(VE_R_VERSION).built dependencies.$(VE_R_VERSION).RData scripts/build-modules.R
	$(RSCRIPT) scripts/build-modules.R
	touch modules.$(VE_R_VERSION).built

runtime: runtime.$(VE_R_VERSION).built
	
runtime.$(VE_R_VERSION).built: modules.$(VE_R_VERSION).built dependencies.$(VE_R_VERSION).RData scripts/setup-sources.R $(VE_INSTALLER)/boilerplate/boilerplate.lst modules.$(VE_R_VERSION).built
	$(RSCRIPT) scripts/setup-sources.R
	touch runtime.$(VE_R_VERSION).built

installers: installers.$(VE_R_VERSION).built

installers.$(VE_R_VERSION).built: dependencies.$(VE_R_VERSION).RData runtime.$(VE_R_VERSION).built
	$(RSCRIPT) scripts/runtime-packages.R
	bash scripts/build-installers.sh
	touch installers.$(VE_R_VERSION).built

# Experimental Docker installation
# Docker work all happens here (not in a separate shell script)

# Warning: Docker is broken due to use of VE_ROOT (not set) and
# VE_OUTPUT, which is more nuanced with the YAML configuration

VE_DOCKER_IN=$(VE_INSTALLER)/docker
VE_DOCKER_OUT=$(VE_OUTPUT)/$(VE_R_VERSION)/Docker
DOCKERFILE=$(VE_DOCKER_IN)/Dockerfile

docker-output-clean:
	sudo rm -rf ${VE_DOCKER_OUT}/Data # Files within are owned by 'root'
docker-clean: docker-output-clean
	rm -rf $(VE_DOCKER_OUT)/home
	
# TODO: Need a script to do the Docker stuff, using its own boilerplate and script setup list (like
# "setup-sources.R" and "runtime-packages.R"

docker: repository.$(VE_R_VERSION).built $(DOCKERFILE) $(VE_DOCKER_IN)/.dockerignore dependencies.$(VE_R_VERSION).RData \
$(VE_OUTPUT)/pkg-repository/dependencies.lst $(VE_OUTPUT)/pkg-repository/visioneval.lst
	mkdir -p $(VE_DOCKER_OUT)/home/visioneval/models
	mkdir -p $(VE_DOCKER_OUT)/Data
	cp -R $(VE_ROOT)/sources/models/VERSPM $(VE_ROOT)/sources/models/VERPAT \
		$(VE_DOCKER_OUT)/home/visioneval/models/
	cp $(VE_DOCKER_IN)/.dockerignore $(VE_DOCKER_OUT)
	cp -a $(VE_DOCKER_IN)/home/* $(VE_DOCKER_OUT)/home/ cd $(VE_DOCKER_OUT); docker build -f
	${DOCKERFILE} -t visioneval .
