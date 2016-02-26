#
# Define paths to data files and output directories for figures.
#
DIR_OOMMF_GENERATED_DATA = micromagnetic_simulation_data/generated_data/oommf
DIR_OOMMF_REFERENCE_DATA = micromagnetic_simulation_data/reference_data/oommf
OOMMF_OUTPUT_FILENAMES = dynamic_txyz.txt mxs.npy mys.npy mzs.npy

DIR_PLOTS_FROM_OOMMF_REFERENCE_DATA = figures/generated_from_reference_data/oommf/
DIR_PLOTS_FROM_OOMMF_RECOMPUTED_DATA = figures/generated_from_recomputed_data/oommf/

DIR_NMAG_GENERATED_DATA = micromagnetic_simulation_data/generated_data/nmag
NMAG_OUTPUT_FILENAMES = dynamic_txyz.txt mxs.npy mys.npy mzs.npy

#
# Generate the list of output files for OOMMF by by prepending DIR_OOMMF_GENERATED_DATA
# to each filename in OOMMF_OUTPUT_FILENAMES (and similary for Nmag).
#
OOMMF_OUTPUT_FILES = $(foreach filename,$(OOMMF_OUTPUT_FILENAMES),$(DIR_OOMMF_GENERATED_DATA)/$(filename) )
NMAG_OUTPUT_FILES = $(foreach filename,$(NMAG_OUTPUT_FILENAMES),$(DIR_NMAG_GENERATED_DATA)/$(filename) )

#
# Set environment variable needed for the target 'generate-oommf-data'.
# This makes a guess where 'oommf.tcl' is located, based on the assumption
# that OOMMF was installed using conda. If this guess is wrong you need to
# set this environment variable manually.
#
OOMMFTCL ?= $(shell echo $(shell dirname $(shell which oommf))/../opt/oommf.tcl) \

TEST_RUNNER ?= nosetests
TEST_OPTIONS ?= --nocapture --verbose

all: unit-tests reproduce-figures-from-reference-data generate-oommf-data reproduce-figures-from-scratch

unit-tests:
	$(TEST_RUNNER) $(TEST_OPTIONS) tests/unit_tests/

compare-data: generate-oommf-data
	$(TEST_RUNNER) $(TEST_OPTIONS) tests/compare_data/

reproduce-figures-from-reference-data: generate-oommf-data
	@python src/reproduce_figures.py \
	    --data-dir=$(DIR_OOMMF_REFERENCE_DATA) \
	    --output-dir=$(DIR_PLOTS_FROM_OOMMF_REFERENCE_DATA)

reproduce-figures-from-scratch: generate-oommf-data
	@python src/reproduce_figures.py \
	    --data-dir=$(DIR_OOMMF_GENERATED_DATA) \
	    --output-dir=$(DIR_PLOTS_FROM_OOMMF_RECOMPUTED_DATA)

generate-oommf-data: $(OOMMF_OUTPUT_FILES)
$(OOMMF_OUTPUT_FILES):
	@cd src/micromagnetic_simulation_scripts/oommf/ && OOMMFTCL=$(OOMMFTCL) ./generate_data.sh

generate-nmag-data: $(NMAG_OUTPUT_FILES)
$(NMAG_OUTPUT_FILES):
	@cd src/micromagnetic_simulation_scripts/nmag/ && ./generate_data.sh

.PHONY: all unit-tests generate-oommf-data generate-nmag-data \
	reproduce-figures-from-reference-data reproduce-figures-from-scratch
