include ve-output.make
# Defines VE_OUTPUT, VE_ROOT and VE_INSTALLER, VE_PLATFORM, VE_R_PLATFORM

.PHONY: configure repository binary installers docker publish\
        clean runtime-clean www-clean all www\
	docker-clean docker-output-clean

all: configure repository binary installers

clean: ve-output.make
	rm -f all-dependencies.RData dependencies.RData
	rm -rf $(VE_OUTPUT)
	rm -f ve-output.make
	rm -f *.built
	rm -f *.out

runtime-clean: ve-output.make
	rm -rf $(VE_OUTPUT)/runtime/*
	rm runtime.built

www-clean: ve-output.make
	rm -rf $(VE_INSTALLER)/www/_site

repository: repository.built

repository.built: dependencies.RData scripts/build-repository.R scripts/build-external-src.R scripts/build-packages-src.R
	Rscript scripts/build-repository.R
	Rscript scripts/build-external-src.R
	Rscript scripts/build-packages-src.R
	touch repository.built

configure: dependencies.RData ve-output.make

ve-output.make: ../dependencies/VE-dependencies.csv ../dependencies/VE-config.R scripts/state-dependencies.R
	Rscript scripts/state-dependencies.R

dependencies.RData: ve-output.make

binary: binary.built

binary.built: repository.built scripts/install-velib.R scripts/build-external-bin.R scripts/build-packages-bin.R
	Rscript scripts/install-velib.R
	Rscript scripts/build-external-bin.R
	Rscript scripts/build-packages-bin.R
	touch binary.built

tests: binary.built
	Rscript scripts/run-tests.R

runtime: runtime.built
	
runtime.built: dependencies.RData scripts/setup-sources.R $(VE_INSTALLER)/boilerplate/boilerplate.lst
	Rscript scripts/setup-sources.R
	touch runtime.built

installers: installers.built runtime.built

installers.built: dependencies.RData $(VE_OUTPUT)/VE-Installer.zip $(VE_OUTPUT)/VE-Installer-$(VE_PLATFORM)-R$(VE_R_VERSION).zip
	touch installers.built

# Building the website requires Ruby/Jekyll - see www/ReadMe.md
www: www.built

www.built: $(VE_INSTALLER/www/index.md $(VE_INSTALLER)/www/_includes/custom-nav-links.html
	cd $(VE_INSTALLER)/www; bundle exec jekyll build
	touch www.built

publish-www: publish-www.built 

# Must set WWW_SSH_PORT and VE_WEBSITE in website.credentials (or in environment)
publish-www.built: www.built
	bash scripts/publish-www.sh
	touch publish-www.built

publish-repos: publish-repos.built

# Must set WWW_SSH_PORT and VE_WEBSITE in website.credentials (or in environment)
publish-repos.built: repository.built installers.built
	bash scripts/publish-installers.sh
	touch publish-repos.built

$(VE_OUTPUT)/VE-Installer-$(VE_PLATFORM)-R$(VE_R_VERSION).zip: $(VE_OUTPUT)/VE-Installer.zip

$(VE_OUTPUT)/VE-Installer.zip: dependencies.RData scripts/build-installers.sh binary.built runtime.built $(VE_INSTALLER)/boilerplate/boilerplate.lst
	bash scripts/build-installers.sh

# Docker work all happens here (not in a separate shell script)
VE_DOCKER=$(VE_INSTALLER)/docker
DOCKERFILE=$(VE_DOCKER)/Dockerfile

$(VE_OUTPUT)/pkg-repository/dependencies.lst $(VE_OUTPUT)/pkg-repository/visioneval.lst: repository.built

docker-output-clean:
	sudo rm -rf ${VE_OUTPUT}/Data # Files within are owned by 'root'
docker-clean: docker-output-clean
	rm -rf $(VE_OUTPUT)/home
	
docker: repository.built $(DOCKERFILE) $(VE_DOCKER)/.dockerignore dependencies.RData \
$(VE_OUTPUT)/pkg-repository/dependencies.lst $(VE_OUTPUT)/pkg-repository/visioneval.lst
	mkdir -p $(VE_OUTPUT)/home/visioneval/models
	mkdir -p $(VE_OUTPUT)/Data
	cp -R $(VE_ROOT)/sources/models/VERSPM $(VE_ROOT)/sources/models/VERPAT \
		$(VE_OUTPUT)/home/visioneval/models/
	cp $(VE_DOCKER)/.dockerignore $(VE_OUTPUT)
	cp -a $(VE_DOCKER)/home/* $(VE_OUTPUT)/home/
	cd $(VE_OUTPUT); docker build -f ${DOCKERFILE} -t visioneval .
