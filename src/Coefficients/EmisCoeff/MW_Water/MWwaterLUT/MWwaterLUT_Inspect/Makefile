#==============================================================================
#
# Makefile for MWwaterLUT_Inspect program
#
#==============================================================================

# Define macros
include $(CRTM_SOURCE_ROOT)/make.macros

# This makefile
MAKE_FILE = Makefile

# Executable files
EXE_FILE = MWwaterLUT_Inspect

# Source files to link
SRC_FILES = Type_Kinds.f90 \
            File_Utility.f90 \
            Message_Handler.f90 \
            Compare_Float_Numbers.f90 \
            Binary_File_Utility.f90 \
            Endian_Utility.f90 \
            MWwaterLUT_Define.f90

# Obj files used in link phase
OBJ_FILES = ${SRC_FILES:.f90=.o} \
            $(EXE_FILE).o

# Define common make targets (all, build, clean, install)
include $(CRTM_SOURCE_ROOT)/make.common_targets

# Source link creation and removal
create_links::
	@$(LINK_SCRIPT) $(CRTM_SOURCE_ROOT) $(SRC_FILES)

remove_links::
	@$(UNLINK_SCRIPT) $(SRC_FILES)

# Source dependency lists
include make.dependencies

# Define default rules
include $(CRTM_SOURCE_ROOT)/make.rules

