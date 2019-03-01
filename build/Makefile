# You can override the following variables on the command line
VE_R_VERSION=3.5.1
VE_CONFIG=../config/VE-config.yml

RSCRIPT:=$(shell find-R.bat $(VE_R_VERSION))

include ve-output.make
# Rebuilt (see below) if it is out of date; make then auto-restarts
# Defines VE_OUTPUT, VE_INSTALLER, VE_PLATFORM based on VE_CONFIG

.PHONY: configure repository packages binary runtime tests installers docker\
		clean runtime-clean build-clean all\
		docker-clean docker-output-clean

all: configure repository packages binary runtime installers

clean: ve-output.make
	rm -f all-dependencies.RData dependencies.RData
	rm -rf $(VE_OUTPUT)
	rm -f ve-output.make
	rm -f *.built
	rm -f *.out

runtime-clean: ve-output.make
	rm -rf $(VE_OUTPUT)/runtime/*
	rm runtime.built

build-clean:
	rm -f all-dependencies.RData dependencies.RData
	rm -f ve-output.make
	rm -f *.built
	rm -f *.out

repository: repository.built

repository.built: dependencies.RData scripts/build-repository.R scripts/build-external-src.R scripts/build-packages-src.R
	$(RSCRIPT) scripts/build-repository.R
	$(RSCRIPT) scripts/build-external-src.R
	touch repository.built

packages: packages.built

packages.built: dependencies.RData scripts/build-packages-src.R
	$(RSCRIPT) scripts/build-packages-src.R
	touch packages.built

configure: dependencies.RData ve-output.make

ve-output.make dependencies.RData: scripts/state-dependencies.R $(VE_CONFIG)
	$(RSCRIPT) scripts/state-dependencies.R
	# Note: identifies VE_CONFIG via the automatically generated environment variable

binary: binary.built

binary.built: repository.built scripts/install-velib.R scripts/build-external-bin.R scripts/build-packages-bin.R
	$(RSCRIPT) scripts/install-velib.R
	$(RSCRIPT) scripts/build-external-bin.R
	$(RSCRIPT) scripts/build-packages-bin.R
	touch binary.built

runtime: runtime.built
	
runtime.built: dependencies.RData scripts/setup-sources.R $(VE_INSTALLER)/boilerplate/boilerplate.lst
	$(RSCRIPT) scripts/setup-sources.R
	touch runtime.built

# Note: need to keep test output distinct from runtime environment
# used for installer base. Spin up a second runtime?
tests: runtime.built
	$(RSCRIPT) scripts/run-tests.R

installers: installers.built runtime.built

installers.built: dependencies.RData $(VE_OUTPUT)/VE-Installer.zip $(VE_OUTPUT)/VE-Installer-$(VE_PLATFORM)-R$(VE_R_VERSION).zip
	touch installers.built

$(VE_OUTPUT)/VE-Installer-$(VE_PLATFORM)-R$(VE_R_VERSION).zip: $(VE_OUTPUT)/VE-Installer.zip

$(VE_OUTPUT)/VE-Installer.zip: dependencies.RData scripts/build-installers.sh binary.built runtime.built $(VE_INSTALLER)/boilerplate/boilerplate.lst
	bash scripts/build-installers.sh

# Experimental Docker installation
# Docker work all happens here (not in a separate shell script)
VE_DOCKER=$(VE_INSTALLER)/docker
DOCKERFILE=$(VE_DOCKER)/Dockerfile

$(VE_OUTPUT)/pkg-repository/dependencies.lst $(VE_OUTPUT)/pkg-repository/visioneval.lst: repository.built

docker-output-clean:
	sudo rm -rf ${VE_OUTPUT}/Data # Files within are owned by 'root'
docker-clean: docker-output-clean
	rm -rf $(VE_OUTPUT)/home
	
# Warning: Docker is broken due to use of VE_ROOT (not set) and
# VE_OUTPUT, which is more nuanced with the YAML configuration

docker: repository.built $(DOCKERFILE) $(VE_DOCKER)/.dockerignore dependencies.RData \
$(VE_OUTPUT)/pkg-repository/dependencies.lst $(VE_OUTPUT)/pkg-repository/visioneval.lst
	mkdir -p $(VE_OUTPUT)/home/visioneval/models
	mkdir -p $(VE_OUTPUT)/Data
	cp -R $(VE_ROOT)/sources/models/VERSPM $(VE_ROOT)/sources/models/VERPAT \
		$(VE_OUTPUT)/home/visioneval/models/
	cp $(VE_DOCKER)/.dockerignore $(VE_OUTPUT)
	cp -a $(VE_DOCKER)/home/* $(VE_OUTPUT)/home/
	cd $(VE_OUTPUT); docker build -f ${DOCKERFILE} -t visioneval .
