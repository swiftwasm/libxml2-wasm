ROOT_DIR = ${CURDIR}
TRIPLE ?= wasm32-unknown-wasi
DESTDIR = $(abspath build/install)/$(TRIPLE)

ifndef WASI_SDK_PREFIX
$(error WASI_SDK_PREFIX is not set)
endif

ifeq ($(TRIPLE), wasm32-unknown-wasi)
LIBXML2_CMAKE_OPTIONS = -DLIBXML2_WITH_THREADS=OFF \
	-DLIBXML2_WITH_THREAD_ALLOC=OFF \
	-DHAVE_PTHREAD_H=OFF \
	-DCMAKE_TOOLCHAIN_FILE=$(WASI_SDK_PREFIX)/share/cmake/wasi-sdk.cmake
else ifeq ($(TRIPLE), wasm32-unknown-wasip1-threads)
LIBXML2_CMAKE_OPTIONS = -DLIBXML2_WITH_THREADS=ON \
	-DLIBXML2_WITH_THREAD_ALLOC=ON \
	-DHAVE_PTHREAD_H=ON \
	-DCMAKE_TOOLCHAIN_FILE=$(WASI_SDK_PREFIX)/share/cmake/wasi-sdk-pthread.cmake
else
$(error TRIPLE must be wasm32-unknown-wasi or wasm32-unknown-wasip1-threads)
endif

build/libxml2.$(TRIPLE).BUILT:
	mkdir -p build/libxml2.$(TRIPLE)
	cd build/libxml2.$(TRIPLE) && cmake $(ROOT_DIR)/src/libxml2 -GNinja \
	        -DLIBXML2_WITH_C14N=OFF \
	        -DLIBXML2_WITH_CATALOG=OFF \
	        -DLIBXML2_WITH_DEBUG=OFF \
	        -DLIBXML2_WITH_DOCB=OFF \
	        -DLIBXML2_WITH_FTP=OFF \
	        -DLIBXML2_WITH_HTML=OFF \
	        -DLIBXML2_WITH_HTTP=OFF \
	        -DLIBXML2_WITH_ICONV=OFF \
	        -DLIBXML2_WITH_ICU=OFF \
	        -DLIBXML2_WITH_ISO8859X=OFF \
	        -DLIBXML2_WITH_LEGACY=OFF \
	        -DLIBXML2_WITH_LZMA=OFF \
	        -DLIBXML2_WITH_MEM_DEBUG=OFF \
	        -DLIBXML2_WITH_MODULES=OFF \
	        -DLIBXML2_WITH_OUTPUT=ON \
	        -DLIBXML2_WITH_PATTERN=OFF \
	        -DLIBXML2_WITH_PROGRAMS=OFF \
	        -DLIBXML2_WITH_PUSH=ON \
	        -DLIBXML2_WITH_PYTHON=OFF \
	        -DLIBXML2_WITH_READER=OFF \
	        -DLIBXML2_WITH_REGEXPS=ON \
	        -DLIBXML2_WITH_RUN_DEBUG=OFF \
	        -DLIBXML2_WITH_SAX1=OFF \
	        -DLIBXML2_WITH_SCHEMAS=OFF \
	        -DLIBXML2_WITH_SCHEMATRON=OFF \
	        -DLIBXML2_WITH_TESTS=OFF \
	        -DLIBXML2_WITH_TREE=ON \
	        -DLIBXML2_WITH_VALID=ON \
	        -DLIBXML2_WITH_WRITER=OFF \
	        -DLIBXML2_WITH_XINCLUDE=OFF \
	        -DLIBXML2_WITH_XPATH=ON \
	        -DLIBXML2_WITH_XPTR=OFF \
	        -DLIBXML2_WITH_ZLIB=OFF \
	        -DBUILD_SHARED_LIBS=OFF \
		$(LIBXML2_CMAKE_OPTIONS) \
		-DWASI_SDK_PREFIX=$(WASI_SDK_PREFIX) \
		-DCMAKE_C_COMPILER_WORKS=ON \
		-DCMAKE_SYSROOT=$(WASI_SDK_PREFIX)/share/wasi-sysroot

	DESTDIR=$(DESTDIR) ninja install -C build/libxml2.$(TRIPLE)

	touch build/libxml2.$(TRIPLE).BUILT

build/package.$(TRIPLE).BUILT: build/libxml2.$(TRIPLE).BUILT
	mkdir -p build/libxml2-$(TRIPLE)
	cp -r $(DESTDIR)/usr/local/include build/libxml2-$(TRIPLE)/
	cp -r $(DESTDIR)/usr/local/lib build/libxml2-$(TRIPLE)/
	tar czf build/libxml2-$(TRIPLE).tar.gz -C build libxml2-$(TRIPLE)

single-package: build/package.$(TRIPLE).BUILT
package:
	$(MAKE) single-package TRIPLE=wasm32-unknown-wasi
	$(MAKE) single-package TRIPLE=wasm32-unknown-wasip1-threads
