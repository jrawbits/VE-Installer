include ve-output.make

.PHONY: repository binary installers docker publish

all: repository binary installers

clean: ve-output.make
	rm dependencies.RData
	rm -rf $(VE_OUTPUT)
	rm ve-output.make

repository: dependencies.RData build-repository.R build-external-src.R build-packages-src.R
	Rscript build-repository.R
	Rscript build-external-src.R
	Rscript build-packages-src.R

ve-output.make: dependencies.RData

dependencies.RData: ../dependencies/VE-dependencies.csv ../dependencies/VE-config.R state-dependencies.R
	Rscript state-dependencies.R

binary: repository install-velib.R build-external-bin.R build-packages-bin.R
	Rscript install-velib.R
	Rscript build-external-bin.R
	Rscript build-packages-bin.R

installers: $(VE_OUTPUT)/VE-Installer.zip

publish:
	# Must set WWW_SSH_PORT and VE_WEBSITE based on target and credentials
	bash publish-installers.sh

$(VE_OUTPUT)/VE-Installer.zip: dependencies.RData setup-sources.R build-installers.sh
	Rscript setup-sources.R
	bash build-installers.sh

# Docker work all happens here (not in a separate shell script)
VE_DOCKER=$(shell readlink -f ../docker)
DOCKERFILE=$(VE_DOCKER)/Dockerfile

docker: $(VE_DOCKER)/Dockerfile $(VE_DOCKER)/.dockerignore
	cp $(VE_DOCKER)/.dockerignore $(VE_OUTPUT)
	cp -a $(VE_DOCKER)/home/. $(VE_OUTPUT)/home/
	cd $(VE_OUTPUT); docker build -f ${DOCKERFILE} -t visioneval .
