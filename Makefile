# build: mingw32-make LLVM=D:\LLVM dirs gz src cmake

CMAKE_VER = 3.4.1
CMAKE = cmake-$(CMAKE_VER)

LLVM_VER = 3.7.1
LLVM = llvm-$(LLVM_VER)
CLANG = cfe-$(LLVM_VER)
LLRT = compiler-rt-$(LLVM_VER)
LLVM_GZ = $(LLVM).src.tar.xz
CLANG_GZ = $(CLANG).src.tar.xz
LLRT_GZ = $(LLRT).src.tar.xz

GZ = $(CURDIR)/gz
SRC = $(CURDIR)/src
PFX = D:/LLVM
TMP = D:/tmp/$(LLVM)

DIRS = $(GZ) $(SRC) $(PFX) $(TMP)

.PHONY: dirs
dirs:
	mkdir -p $(DIRS)

.PHONY: gz
WGET = wget --no-check-certificate -c -P $(GZ)
gz: $(GZ)/$(CMAKE)-win32-x86.exe \
	$(GZ)/$(LLVM_GZ) $(GZ)/$(CLANG_GZ) $(GZ)/$(LLRT_GZ)
$(GZ)/$(CMAKE)-win32-x86.exe:
	$(WGET) https://cmake.org/files/v3.4/$(CMAKE)-win32-x86.exe
$(GZ)/$(LLVM_GZ):
	$(WGET) http://llvm.org/releases/$(LLVM_VER)/$(LLVM_GZ)
$(GZ)/$(CLANG_GZ):
	$(WGET) http://llvm.org/releases/$(LLVM_VER)/$(CLANG_GZ)
$(GZ)/$(LLRT_GZ):
	$(WGET) http://llvm.org/releases/$(LLVM_VER)/$(LLRT_GZ)

.PHONY: src
src: $(SRC)/$(LLVM)/README

$(SRC)/$(LLVM)/README: $(GZ)/$(LLVM_GZ)
	cd $(SRC) && rm -rf $(LLVM).src $(LLVM) &&\
  	xzcat $< | tar x && mv $(LLVM).src $(LLVM) && touch $@

.PHONY: cmake
cmake:
	 rm -rf $(TMP)/* && $(MAKE) PATH="C:/MinGW/bin;C:/MinGW/CMake/bin" cmake-gui

.PHONY: cmake-gui
cmake-gui:	
		cd $(TMP) && cmake \
			-G "MinGW Makefiles" \
			-DCMAKE_BUILD_TYPE=Debug \
			-DCMAKE_INSTALL_PREFIX=$(PFX) \
			-DBUILD_SHARED_LIBS=ON \
			-DLLVM_TARGETS_TO_BUILD=X86;ARM \
			$(SRC)/$(LLVM)

