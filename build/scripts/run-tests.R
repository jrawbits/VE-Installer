# This script runs all the configured tests; track with the travis.yml environment

# Iterate across the packages, finding their test scripts and executing those one
# after another

# Then run VERPAT on its test data, and VERSPM and its test data
#
load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

# Where to find the package sources (in the VisionEval repository)

ve.packages <- pkgs.visioneval[,"Package"]
package.paths <- file.path(ve.root,pkgs.visioneval[,"Path"],ve.packages)

# Under development - still does nothing

# Run the package tests
# This should all boil down to testing the built package
# Ideally, use devtools:check_built()
# Relies on R CMD check, which will run test scripts

# for (module in package.paths) {
# 		devtools::check_built(module,path=built.path.src)
# 	}
# }

# The models are tested by actually running them.
# The GUI is tested by running a script in its home folder
# The architecture of the tests varies according to the version of VisionEval,
# so testing is a "moving target"

#    - FOLDER=sources/framework/visioneval            SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=
#    - FOLDER=sources/modules/VE2001NHTS              SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=
#    - FOLDER=sources/modules/VEHouseholdTravel       SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=VE2001NHTS
#    - FOLDER=sources/modules/VEHouseholdVehicles     SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=VE2001NHTS,VEHouseholdTravel
#    - FOLDER=sources/modules/VELandUse               SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=VE2001NHTS,VESimHouseholds
#    - FOLDER=sources/modules/VESimHouseholds         SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=
#    - FOLDER=sources/modules/VESyntheticFirms        SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=
#    - FOLDER=sources/modules/VETransportSupply       SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=
#    - FOLDER=sources/modules/VETransportSupplyUse    SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=
#    - FOLDER=sources/modules/VETravelPerformance     SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=VE2001NHTS,VEHouseholdTravel,VEPowertrainsAndFuels
#    - FOLDER=sources/modules/VEPowertrainsAndFuels   SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=VE2001NHTS,VEHouseholdTravel
#    - FOLDER=sources/modules/VEReports               SCRIPT=tests/scripts/test.R    TYPE=module      DEPENDS=VE2001NHTS,VEHouseholdTravel
#    - FOLDER=sources/models/VERPAT                   SCRIPT=run_model.R             TYPE=model       DEPENDS=VE2001NHTS,VESimHouseholds,VESyntheticFirms,VELandUse,VETransportSupply,VEHouseholdTravel,VEHouseholdVehicles,VETransportSupplyUse,VEReports
#    - FOLDER=sources/models/VERSPM/Test1             SCRIPT=run_model.R             TYPE=model       DEPENDS=VE2001NHTS,VESimHouseholds,VELandUse,VETransportSupply,VEHouseholdTravel,VEHouseholdVehicles,VEPowertrainsAndFuels,VETravelPerformance
#    - FOLDER=sources/VEGUI                           SCRIPT=run_vegui_test.R        TYPE=model       DEPENDS=VE2001NHTS,VESimHouseholds,VESyntheticFirms,VELandUse,VETransportSupply,VEHouseholdTravel,VEHouseholdVehicles,VETransportSupplyUse,VEReports

