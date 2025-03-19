# Compiler settings
CXX ?= g++
AR ?= ar
ARFLAGS = rcs

MODULE_NAME := word_count

# Detect platform
ifdef EMSCRIPTEN
    PLATFORM := web
else
    PLATFORM := native
endif

# Directories
SRC_DIR := src
MODULE_DIR := $(MODULE_NAME)
BUILD_DIR := build/$(PLATFORM)
LIB_DIR := lib/$(PLATFORM)
BIN_DIR := bin/$(PLATFORM)

BIN_DEBUG := $(BIN_DIR)/debug
BIN_RELEASE := $(BIN_DIR)/release
LIB_DEBUG := $(LIB_DIR)/debug
LIB_RELEASE := $(LIB_DIR)/release
BUILD_DEBUG := $(BUILD_DIR)/debug
BUILD_RELEASE := $(BUILD_DIR)/release

# Source files
MAIN_SRC := $(SRC_DIR)/Main.cpp
MODULE_SRC := $(MODULE_DIR)/$(MODULE_NAME).cpp
BINDINGS_SRC := $(MODULE_DIR)/bindings.cpp

# Object files
MODULE_OBJ_DEBUG := $(BUILD_DEBUG)/$(MODULE_NAME).o
MODULE_OBJ_RELEASE := $(BUILD_RELEASE)/$(MODULE_NAME).o

# Static libraries
MODULE_LIB_DEBUG := $(LIB_DEBUG)/lib$(MODULE_NAME).a
MODULE_LIB_RELEASE := $(LIB_RELEASE)/lib$(MODULE_NAME).a

# Output files
NATIVE_DEBUG_EXE := $(BIN_DEBUG)/$(MODULE_NAME)
NATIVE_RELEASE_EXE := $(BIN_RELEASE)/$(MODULE_NAME)
WEB_DEBUG_ASM := $(BIN_DEBUG)/$(MODULE_NAME).js
WEB_DEBUG_WASM := $(BIN_DEBUG)/$(MODULE_NAME).wasm
WEB_RELEASE_ASM := $(BIN_RELEASE)/$(MODULE_NAME).js
WEB_RELEASE_WASM := $(BIN_RELEASE)/$(MODULE_NAME).wasm

# Compilation flags
CXXFLAGS := -std=c++17 -Wall -Wextra -I$(SRC_DIR) -I$(MODULE_DIR)
DEBUG_FLAGS := -g -O0 -DDEBUG
RELEASE_FLAGS := -O3 -DNDEBUG

# Emscripten-specific flags for modularized WebAssembly output
EMSCRIPTEN_FLAGS := --bind -s MODULARIZE=1 -s EXPORT_NAME="WordCounterModule" \
                    -s EXPORT_ES6=0 -s ENVIRONMENT=web

# Make directories function
define ensure_dir
	@mkdir -p $(1)
endef

# Targets
.PHONY: all clean debug release web web-debug info help

all: release debug

info:
	@echo "Build configuration:"
	@echo "  Platform: $(PLATFORM)"
	@echo "  Compiler: $(CXX)"
	@echo "  Archiver: $(AR) $(ARFLAGS)"
	@echo "  Debug output: $(if $(filter web,$(PLATFORM)),$(WEB_DEBUG_ASM),$(NATIVE_DEBUG_EXE))"
	@echo "  Release output: $(if $(filter web,$(PLATFORM)),$(WEB_RELEASE_ASM),$(NATIVE_RELEASE_EXE))"

help:
	@echo "Available targets:"
	@echo "  all       - Build both debug and release versions"
	@echo "  debug     - Build debug version"
	@echo "  release   - Build release version"
	@echo "  clean     - Remove all build artifacts"
	@echo "  info      - Display build configuration"
	@echo "  help      - Display this help message"
	@echo ""
	@echo "Usage with Emscripten:"
	@echo "  emmake make        - Build for web (WebAssembly)"
	@echo "  emmake make debug  - Build debug version for web"

### Compile Static Libraries ###
$(MODULE_LIB_RELEASE): $(MODULE_OBJ_RELEASE)
	$(call ensure_dir,$(LIB_RELEASE))
	$(AR) $(ARFLAGS) $@ $^

$(MODULE_LIB_DEBUG): $(MODULE_OBJ_DEBUG)
	$(call ensure_dir,$(LIB_DEBUG))
	$(AR) $(ARFLAGS) $@ $^

# Object files
$(MODULE_OBJ_RELEASE): $(MODULE_SRC) $(BINDINGS_SRC)
	$(call ensure_dir,$(BUILD_RELEASE))
	$(CXX) $(CXXFLAGS) $(RELEASE_FLAGS) -c $< -o $@

$(MODULE_OBJ_DEBUG): $(MODULE_SRC) $(BINDINGS_SRC)
	$(call ensure_dir,$(BUILD_DEBUG))
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS) -c $< -o $@

### Native Executables ###
ifeq ($(PLATFORM),native)
native: $(NATIVE_RELEASE_EXE) $(NATIVE_DEBUG_EXE)

$(NATIVE_RELEASE_EXE): $(MAIN_SRC) $(MODULE_LIB_RELEASE)
	$(call ensure_dir,$(BIN_RELEASE))
	$(CXX) $(CXXFLAGS) $(RELEASE_FLAGS) $< -L$(LIB_RELEASE) -l$(MODULE_NAME) -o $@

$(NATIVE_DEBUG_EXE): $(MAIN_SRC) $(MODULE_LIB_DEBUG)
	$(call ensure_dir,$(BIN_DEBUG))
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS) $< -L$(LIB_DEBUG) -l$(MODULE_NAME) -o $@
endif

### WebAssembly Builds ###
ifeq ($(PLATFORM),web)
web: $(WEB_RELEASE_ASM)

$(WEB_RELEASE_ASM): $(MAIN_SRC) $(MODULE_SRC) $(BINDINGS_SRC)
	$(call ensure_dir,$(BIN_RELEASE))
	$(CXX) $(CXXFLAGS) $(RELEASE_FLAGS) $(EMSCRIPTEN_FLAGS) $^ -o $@

web-debug: $(WEB_DEBUG_ASM)

$(WEB_DEBUG_ASM): $(MAIN_SRC) $(MODULE_SRC) $(BINDINGS_SRC)
	$(call ensure_dir,$(BIN_DEBUG))
	$(CXX) $(CXXFLAGS) $(DEBUG_FLAGS) $(EMSCRIPTEN_FLAGS) $^ -o $@
endif

# Grouped release and debug targets
release: $(if $(filter web,$(PLATFORM)),$(WEB_RELEASE_ASM),$(NATIVE_RELEASE_EXE))
debug: $(if $(filter web,$(PLATFORM)),$(WEB_DEBUG_ASM),$(NATIVE_DEBUG_EXE))

# Clean
clean:
	rm -rf build lib bin

.PRECIOUS: $(BUILD_DEBUG)/%.o $(BUILD_RELEASE)/%.o
