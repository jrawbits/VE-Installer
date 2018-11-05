# This R source file sets the key locations required to build an installer.
# The key item is the root 

# Required: root directory of the VisionEval version described in VE-dependencies.csv
ve.root <- "c:\\Users\\jeremy.DESKTOP-OLMEAON\\Documents\\Git-Repos\\visioneval

# Optional: location in which "built-packages", "miniCRAN" and "runtime" will be built
# Defaults to putting those packages in an "installer_YYMMDD_HHMM" folder in ve.install
# Explicit representation of default:
# ve.output <- file.path(ve.install,paste("installer",format(Sys.time(),"%y%m%d"),sep="_"))

# Notes on VE-dependencies for RSG develop branch:
# It's not clear that VEGUI is actually a package (or if it's still source; presume the latter)
#
# Don't need webdriver and shinytest (which have heavy dependencies)
#
# shinytest
#     assertthat,
#     digest,
#     crayon,
#     debugme,
#     parsedate,
#     pingr,
#     callr (>= 2.0.3),
#     R6,
#     rematch,
#     httr,
#     shiny (>= 1.0.4),
#     testthat (>= 1.0.0),
#     utils,
#     webdriver (>= 1.0.5),
#     htmlwidgets,
#     jsonlite,
#     withr,
#     httpuv
# 
# webdriver (plus needs phantom.js)
#     callr (>= 2.0.0),
#     base64enc,
#     curl (>= 2.0),
#     debugme,
#     httr,
#     jsonlite,
#     R6,
#     showimage,
#     utils,
#     withr
