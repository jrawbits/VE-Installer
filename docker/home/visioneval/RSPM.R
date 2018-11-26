#!/usr/bin/env r
# VisionEval script to run RSPM

# TODO: take exactly one argument, which is the
# name of a subdirectory of the VERSPM model folder
# Note that Run_Model.R must include the ModelScriptFile
# runtime initialization parameter for this to work

if (is.null(argv))
 | length(argv)>1) {
  cat("Usage: installr.r pkg1 [pkg2 pkg3 ...]\n")
  q()
}

full_path <- file.path(getwd(),"models/VERSPM",which.rspm)
script_path <- file.path(getwd(),"models/VERSPM/Run_Model.R")
old.path <- setwd(full_path)
source(script_path)
	