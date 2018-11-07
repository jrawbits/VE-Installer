Documentation of Build Process

1. Parse dependencies and begin building the miniCRAN
	* `state-dependencies.R`
	* `build-miniCRAN.R`  (both source and binary from CRAN and BioC only; will skip existing, add new, but not delete)
	  (Use build-miniCRAN to update _dependencies_; it does not look at externals or packages - use `update-miniCRAN`
2. Build source packages:
	* `build-external-src.R` (put these directly into the miniCRAN src/contrib tree, then rewrite PACKAGES)
	* `build-packages-src.R` (put these directly into the miniCRAN src/contrib tree, then rewrite PACKAGES)
	* `update-miniCRAN.R` (examines the built-external and built-packages directories; uses miniCRAN::updatePkgs if already present)
3. Build missing binaries (if local architecture is Windows)
	* Check available.packages for "source" and "win.binary" and rebuild any that are in the former but not the latter
	* `build-windows.R` (build from miniCRAN source if on Windows, and put built packages in miniCRAN win.binary, then rewrite PACKAGES)
	3. (FOR LATER) Build Windows binaries using external service
		* `build-external-winbuilder.R` (win-builder.r-project.org - place results in built-external/bin)
		* `build-packages-winbuilder.R` (win-builder.r-project.org - place results in build-packages/bin)
		* `update-miniCRAN.R` (rewrites the packages file)
4. Install VisionEval into velib-local (if local architecture is source) or velib-windows (if local architecture is Windows)
	* `install-velib.R` (from miniCRAN, CRAN and BioC only)
	* `install-external.R` (from built-external/bin or built-external/src, depending on local architecture)
	* `install-packages.R` (from built-external/bin or built-external/src, depending on local architecture)
	4. Create Windows Library as velib-windows (if windows is not local architecture)
		* `install-velib-windows.R` (installs all the .zip files in Windows architecture directly from the miniCRAN)
6. Create installers
	* `build-installer.sh` (Options, possibly more than one: `local`, `online`, `windows`)
		* `local`: places velib-local into runtime as velib
		* `online`: does not have velib-* (install on runtime machine from online miniCRAN; boilerplate goes to online)
		* `windows`: zips suitable files into windows-installer (including velib-windows as velib)
	   