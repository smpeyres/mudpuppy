###############################################################################
################### MOOSE Application Standard Makefile #######################
###############################################################################
#
# Optional Environment variables
# MOOSE_DIR        - Root directory of the MOOSE project
#
###############################################################################
# Use the MOOSE submodule if it exists and MOOSE_DIR is not set
MOOSE_SUBMODULE    := $(CURDIR)/moose
ifneq ($(wildcard $(MOOSE_SUBMODULE)/framework/Makefile),)
  MOOSE_DIR        ?= $(MOOSE_SUBMODULE)
else
  MOOSE_DIR        ?= $(shell dirname `pwd`)/moose
endif

# framework
FRAMEWORK_DIR      := $(MOOSE_DIR)/framework
include $(FRAMEWORK_DIR)/build.mk
include $(FRAMEWORK_DIR)/moose.mk

################################## MODULES ####################################
# To use certain physics included with MOOSE, set variables below to
# yes as needed.  Or set ALL_MODULES to yes to turn on everything (overrides
# other set variables).

ALL_MODULES                 := no

CHEMICAL_REACTIONS          := no
CONTACT                     := no
ELECTROMAGNETICS            := yes
EXTERNAL_PETSC_SOLVER       := no
FLUID_PROPERTIES            := no
FSI                         := no
FUNCTIONAL_EXPANSION_TOOLS  := no
GEOCHEMISTRY                := no
HEAT_TRANSFER               := no
LEVEL_SET                   := no
MISC                        := no
NAVIER_STOKES               := yes
OPTIMIZATION                := no
PERIDYNAMICS                := no
PHASE_FIELD                 := no
POROUS_FLOW                 := no
RAY_TRACING                 := no
REACTOR                     := no
RDG                         := no
SOLID_MECHANICS             := no
STOCHASTIC_TOOLS            := no
THERMAL_HYDRAULICS          := no
XFEM                        := no

include $(MOOSE_DIR)/modules/modules.mk
###############################################################################
# squirrel
SQUIRREL_SUBMODULE    := $(CURDIR)/zapdos/squirrel
ifneq ($(wildcard $(SQUIRREL_SUBMODULE)/Makefile),)
  SQUIRREL_DIR        ?= $(SQUIRREL_SUBMODULE)
else
  SQUIRREL_DIR        ?= $(shell dirname `pwd`)/squirrel
endif
APPLICATION_DIR    := $(SQUIRREL_DIR)
APPLICATION_NAME   := squirrel
include            $(FRAMEWORK_DIR)/app.mk
# crane
CRANE_SUBMODULE    := $(CURDIR)/zapdos/crane
ifneq ($(wildcard $(CRANE_SUBMODULE)/Makefile),)
  CRANE_DIR        ?= $(CRANE_SUBMODULE)
else
  CRANE_DIR        ?= $(shell dirname `pwd`)/crane
endif
APPLICATION_DIR    := $(CRANE_DIR)
APPLICATION_NAME   := crane
include            $(FRAMEWORK_DIR)/app.mk

# Use the ZAPDOS submodule if it exists and ZAPDOS_DIR is not set
ZAPDOS_SUBMODULE    := $(CURDIR)/zapdos
ifneq ($(wildcard $(ZAPDOS_SUBMODULE)/Makefile),)
  ZAPDOS_DIR        ?= $(ZAPDOS_SUBMODULE)
else
  ZAPDOS_DIR        ?= $(shell dirname `pwd`)/zapdos
endif
# zapdos
APPLICATION_DIR    := $(ZAPDOS_DIR)
APPLICATION_NAME   := zapdos
include            $(FRAMEWORK_DIR)/app.mk

# dep apps
APPLICATION_DIR    := $(CURDIR)
APPLICATION_NAME   := mudpuppy
BUILD_EXEC         := yes
GEN_REVISION       := no
DEP_APPS           := $(shell $(FRAMEWORK_DIR)/scripts/find_dep_apps.py $(APPLICATION_NAME))
include            $(FRAMEWORK_DIR)/app.mk

###############################################################################
# Additional special case targets should be added here
