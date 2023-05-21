#https://stackoverflow.com/questions/34603415/makefile-automatic-target-generation
#https://www.gnu.org/software/make/manual/make.html#Static-Pattern
#https://stackoverflow.com/questions/2826029/passing-additional-variables-from-command-line-to-make
#https://stackoverflow.com/questions/2214575/passing-arguments-to-make-run

R_HOME = /usr

PKG_PATH = ${PWD}
TOP = ${PWD}/..
PKG_DESC = ${PKG_PATH}/DESCRIPTION
PKG_NAME = $(shell sed -ne "s/^Package: //p" ${PKG_DESC} | tr -d '\n')
PKG_VER = $(shell sed -ne "s/^Version: \(.*\)/\1/p" ${PKG_DESC} | tr -d '\n')
PKG_TARGZ = $(PKG_NAME)_$(PKG_VER).tar.gz


PKG_BUILD_OPTS ?= --no-build-vignettes
R_LIB ?= $(shell Rscript -e 'cat(.libPaths()[1L])')

PKG_INST_FILE = $(R_LIB)/${PKG_NAME}/DESCRIPTION

PKG_R_FILES := $(wildcard ${PKG_PATH}/R/*.R)
PKG_RD_FILES := $(wildcard ${PKG_PATH}/man/*.Rd)
PKG_SRC_FILES := $(wildcard ${PKG_PATH}/src/*)
PKG_ALL_FILES := ${PKG_PATH}/DESCRIPTION ${PKG_PATH}/NAMESPACE ${PKG_PATH}/.Rbuildignore \
		 $(PKG_R_FILES) $(PKG_RD_FILES) $(PKG_SRC_FILES) \

UNIT_TEST_SUITE = ${PKG_PATH}/tests/tinytest.R
UNIT_TEST_FILES = $(wildcard ${PKG_PATH}/inst/tinytest/test-*.R)

BENCHMARK_FILE = ${PKG_PATH}/inst/benchmarks/benchmark.subset.R

.PHONY: build install check tests cran docs

all: check #benchmark

#man/*.Rd depend on R/*.R files
print:
	@echo 'path: $(PKG_PATH) \
	inst_file: $(PKG_INST_FILE) \
	tar.gz: $(PKG_TARGZ)'

# Build package
build: $(PKG_TARGZ)
$(PKG_TARGZ): $(PKG_ALL_FILES) $(UNIT_TEST_FILES) $(UNIT_TEST_SUITE)
	@${R_HOME}/bin/R CMD build ${PKG_BUILD_OPTS} ${PKG_PATH} --no-build-vignettes

# Install package
install: build $(PKG_INST_FILE)
$(PKG_INST_FILE): $(PKG_TARGZ)
	@${R_HOME}/bin/R CMD INSTALL ${PKG_TARGZ} --no-byte-compile

# Run R CMD check
check: docs install
	@_R_CHECK_CRAN_INCOMING_=false \
	_MY_TINYTEST_VERBOSE_=1 _MY_TINYTEST_COLOR_=FALSE \
	${R_HOME}/bin/R CMD check ${PKG_TARGZ} --no-vignettes

docs: ${PKG_R_FILES}
	@${R_HOME}/bin/Rscript -e "roxygen2::roxygenize(roclets='rd')"

# Check for CRAN
cran:
	@${R_HOME}/bin/R CMD build ${PKG_PATH} && \
	_MY_TINYTEST_VERBOSE_=1 _MY_TINYTEST_COLOR_=FALSE \
	_R_CHECK_CRAN_INCOMING_=false ${R_HOME}/bin/R CMD check ${PKG_TARGZ} --as-cran

# Run unit test suite
tests: install ${UNIT_TEST_FILES}
	@_MY_TINYTEST_VERBOSE_=2 _MY_TINYTEST_COLOR_=TRUE \
	${R_HOME}/bin/Rscript ${UNIT_TEST_SUITE}
