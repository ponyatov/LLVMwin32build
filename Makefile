# build: mingw32-make PFX=D:\LLVM dirs gz src cmake

LLVM_VER = 3.6.2
#3.7.1 .0 unable to build on mingw (some errors)

MINGW = C:/MinGW

PFX = D:/LLVM
LLVM_CMAKE_CFG = \
	-DCMAKE_INSTALL_PREFIX=$(PFX) \
	-DBUG_REPORT_URL=https://github.com/ponyatov/LLVMwin32build \
	-DLLVM_PARALLEL_COMPILE_JOBS=4 -DLLVM_PARALLEL_LINK_JOBS=4 \
	-DLLVM_EXTERNAL_MSBUILD_BUILD=OFF -DCMAKE_GNUtoMS=OFF \
	-DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_DEFAULT_TARGET_TRIPLE=i386-pc-mingw32
#	-DLLVM_EXTERNAL_DRAGONEGG_SOURCE_DIR=$(SRC)/$(EGG) \
#	-DBUILD_SHARED_LIBS=ON \
#	-DCMAKE_BUILD_TYPE=Debug \
#	-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
#-DLLVM_TARGETS_TO_BUILD=host -DLLVM_TARGETS_TO_BUILD=X86;ARM \
#-DLLVM_TARGETS_TO_BUILD=X86 -DLLVM_DEFAULT_TARGET_TRIPLE=i386-pc-mingw32

XPATH = "$(MINGW)/bin;$(MINGW)/CMake/bin"
#$(MINGW)/msys/1.0/bin;

CMAKE_VER = 3.4.1
CMAKE = cmake-$(CMAKE_VER)

LLVM = llvm-$(LLVM_VER)
LLVM_GZ = $(LLVM).src.tar.xz
EGG = dragonegg-$(LLVM_VER)
EGG_GZ = $(EGG).src.tar.xz
#CLANG = cfe-$(LLVM_VER)
#CLANG_GZ = $(CLANG).src.tar.xz
#LLRT = compiler-rt-$(LLVM_VER)
#LLRT_GZ = $(LLRT).src.tar.xz

GZ = $(CURDIR)/gz
SRC = $(CURDIR)/src
TMP = D:/tmp/$(LLVM)

DIRS = $(GZ) $(SRC) $(PFX) $(TMP)

.PHONY: dirs
dirs:
	mkdir -p $(DIRS)

.PHONY: gz
WGET = wget --no-check-certificate -c -P $(GZ)
gz: $(GZ)/$(CMAKE)-win32-x86.exe $(GZ)/$(LLVM_GZ) $(GZ)/$(EGG_GZ)

$(GZ)/$(CMAKE)-win32-x86.exe:
	$(WGET) https://cmake.org/files/v3.4/$(CMAKE)-win32-x86.exe
$(GZ)/$(LLVM_GZ):
	$(WGET) http://llvm.org/releases/$(LLVM_VER)/$(LLVM_GZ)
$(GZ)/$(EGG_GZ):	
	$(WGET) http://llvm.org/releases/$(LLVM_VER)/$(EGG_GZ)
#$(GZ)/$(CLANG_GZ):
#	$(WGET) http://llvm.org/releases/$(LLVM_VER)/$(CLANG_GZ)
#$(GZ)/$(LLRT_GZ):
#	$(WGET) http://llvm.org/releases/$(LLVM_VER)/$(LLRT_GZ)

.PHONY: src
src: $(SRC)/$(LLVM)/README $(SRC)/$(EGG)/README

$(SRC)/$(LLVM)/README: $(GZ)/$(LLVM_GZ)
	cd $(SRC) && rm -rf $(LLVM).src $(LLVM) &&\
  	xzcat $< | tar x && mv $(LLVM).src $(LLVM) && touch $@
$(SRC)/$(EGG)/README: $(GZ)/$(EGG_GZ)
	cd $(SRC) && rm -rf $(EGG).src $(EGG) &&\
  	xzcat $< | tar x && mv $(EGG).src $(EGG) && touch $@

.PHONY: cmake
cmake: src
	rm -rf $(TMP)/* && $(MAKE) PATH=$(XPATH) cmake-cfg
#   	cmake-build
.PHONY: cmake-cfg
cmake-cfg:
	cd $(TMP) && cmake -G "MinGW Makefiles" $(LLVM_CMAKE_CFG) $(SRC)/$(LLVM)
.PHONY: cmake-build
cmake-build:	
	cd $(TMP) && cmake --build . 

.PHONY: install
install:
	cd $(TMP) && cmake --build . --target install
