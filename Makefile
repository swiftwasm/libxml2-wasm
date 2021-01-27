ROOT_DIR = ${CURDIR}
DESTDIR = $(abspath build/install)

ifndef WASI_SDK_PREFIX
$(error WASI_SDK_PREFIX is not set)
endif

build/libxml2.BUILT:
	mkdir -p build/libxml2
	cd build/libxml2 && cmake $(ROOT_DIR)/src/libxml2 -GNinja \
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
	        -DLIBXML2_WITH_THREADS=OFF \
	        -DLIBXML2_WITH_THREAD_ALLOC=OFF \
	        -DLIBXML2_WITH_TREE=ON \
	        -DLIBXML2_WITH_VALID=ON \
	        -DLIBXML2_WITH_WRITER=OFF \
	        -DLIBXML2_WITH_XINCLUDE=OFF \
	        -DLIBXML2_WITH_XPATH=ON \
	        -DLIBXML2_WITH_XPTR=OFF \
	        -DLIBXML2_WITH_ZLIB=OFF \
	        -DBUILD_SHARED_LIBS=OFF \
		-DWASI_SDK_PREFIX=$(WASI_SDK_PREFIX) \
		-DCMAKE_C_COMPILER_WORKS=ON \
		-DCMAKE_SYSROOT=$(WASI_SDK_PREFIX)/share/wasi-sysroot \
	        -DCMAKE_TOOLCHAIN_FILE=$(WASI_SDK_PREFIX)/share/cmake/wasi-sdk.cmake

	DESTDIR=$(DESTDIR) ninja install -C build/libxml2

	touch build/libxml2.BUILT

build/package.BUILT: build/libxml2.BUILT
	mkdir -p build/libxml2-wasm32-unknown-wasi
	cp -r build/install/usr/local/include build/libxml2-wasm32-unknown-wasi/
	cp -r build/install/usr/local/lib build/libxml2-wasm32-unknown-wasi/
	tar czf build/libxml2-wasm32-unknown-wasi.tar.gz -C build libxml2-wasm32-unknown-wasi

package: build/package.BUILT
