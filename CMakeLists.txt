cmake_minimum_required(VERSION 3.14)
project(Seq)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic -Wall -Wno-return-type-c-linkage")
set(CMAKE_CXX_FLAGS_DEBUG "-g -fno-limit-debug-info")
set(CMAKE_CXX_FLAGS_RELEASE "-O3")
include_directories(.)

set(CPM_DOWNLOAD_VERSION 0.32.3)
set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")
if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
    message(STATUS "Downloading CPM.cmake...")
    file(DOWNLOAD https://github.com/TheLartians/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake ${CPM_DOWNLOAD_LOCATION})
endif()
include(${CPM_DOWNLOAD_LOCATION})

CPMAddPackage(
    NAME xz
    GITHUB_REPOSITORY "xz-mirror/xz"
    VERSION 5.2.5
    GIT_TAG e7da44d5151e21f153925781ad29334ae0786101
    EXCLUDE_FROM_ALL YES
    OPTIONS "BUILD_SHARED_LIBS OFF"
            "CMAKE_POSITION_INDEPENDENT_CODE ON")
if(xz_ADDED)
    set_target_properties(xz PROPERTIES EXCLUDE_FROM_ALL ON)
    set_target_properties(xzdec PROPERTIES EXCLUDE_FROM_ALL ON)
endif()

CPMAddPackage(
    NAME htslib
    VERSION 1.13
    URL "https://github.com/samtools/htslib/releases/download/1.13/htslib-1.13.tar.bz2"
    DOWNLOAD_ONLY YES)
if(htslib_ADDED)
    configure_file(
        ${CMAKE_SOURCE_DIR}/htslib-config.h.cmake
        ${htslib_SOURCE_DIR}/config.h
        COPYONLY)
    write_file(${htslib_SOURCE_DIR}/version.h
        "#define HTS_VERSION_TEXT \"${CPM_PACKAGE_htslib_VERSION}\"")
    write_file(${htslib_SOURCE_DIR}/config_vars.h
        "#define HTS_CC \"\"\n"
        "#define HTS_CPPFLAGS \"\"\n"
        "#define HTS_CFLAGS \"\"\n"
        "#define HTS_LDFLAGS \"\"\n"
        "#define HTS_LIBS \"\"\n")
    set(HTSLIB_FILES
        "${htslib_SOURCE_DIR}/kfunc.c"
        "${htslib_SOURCE_DIR}/kstring.c"
        "${htslib_SOURCE_DIR}/bcf_sr_sort.c"
        "${htslib_SOURCE_DIR}/bgzf.c"
        "${htslib_SOURCE_DIR}/errmod.c"
        "${htslib_SOURCE_DIR}/faidx.c"
        "${htslib_SOURCE_DIR}/header.c"
        "${htslib_SOURCE_DIR}/hfile.c"
        "${htslib_SOURCE_DIR}/hts.c"
        "${htslib_SOURCE_DIR}/hts_expr.c"
        "${htslib_SOURCE_DIR}/hts_os.c"
        "${htslib_SOURCE_DIR}/md5.c"
        "${htslib_SOURCE_DIR}/multipart.c"
        "${htslib_SOURCE_DIR}/probaln.c"
        "${htslib_SOURCE_DIR}/realn.c"
        "${htslib_SOURCE_DIR}/regidx.c"
        "${htslib_SOURCE_DIR}/region.c"
        "${htslib_SOURCE_DIR}/sam.c"
        "${htslib_SOURCE_DIR}/synced_bcf_reader.c"
        "${htslib_SOURCE_DIR}/vcf_sweep.c"
        "${htslib_SOURCE_DIR}/tbx.c"
        "${htslib_SOURCE_DIR}/textutils.c"
        "${htslib_SOURCE_DIR}/thread_pool.c"
        "${htslib_SOURCE_DIR}/vcf.c"
        "${htslib_SOURCE_DIR}/vcfutils.c"
        "${htslib_SOURCE_DIR}/cram/cram_codecs.c"
        "${htslib_SOURCE_DIR}/cram/cram_decode.c"
        "${htslib_SOURCE_DIR}/cram/cram_encode.c"
        "${htslib_SOURCE_DIR}/cram/cram_external.c"
        "${htslib_SOURCE_DIR}/cram/cram_index.c"
        "${htslib_SOURCE_DIR}/cram/cram_io.c"
        "${htslib_SOURCE_DIR}/cram/cram_stats.c"
        "${htslib_SOURCE_DIR}/cram/mFILE.c"
        "${htslib_SOURCE_DIR}/cram/open_trace_file.c"
        "${htslib_SOURCE_DIR}/cram/pooled_alloc.c"
        "${htslib_SOURCE_DIR}/cram/string_alloc.c"
        "${htslib_SOURCE_DIR}/htscodecs/htscodecs/arith_dynamic.c"
        "${htslib_SOURCE_DIR}/htscodecs/htscodecs/fqzcomp_qual.c"
        "${htslib_SOURCE_DIR}/htscodecs/htscodecs/htscodecs.c"
        "${htslib_SOURCE_DIR}/htscodecs/htscodecs/pack.c"
        "${htslib_SOURCE_DIR}/htscodecs/htscodecs/rANS_static4x16pr.c"
        "${htslib_SOURCE_DIR}/htscodecs/htscodecs/rANS_static.c"
        "${htslib_SOURCE_DIR}/htscodecs/htscodecs/rle.c"
        "${htslib_SOURCE_DIR}/htscodecs/htscodecs/tokenise_name3.c")
    add_library(htslib STATIC ${HTSLIB_FILES})
    target_include_directories(htslib BEFORE PRIVATE "${htslib_SOURCE_DIR}" "${xz_SOURCE_DIR}/src/liblzma/api")
    set_target_properties(htslib PROPERTIES
        POSITION_INDEPENDENT_CODE ON
        VISIBILITY_INLINES_HIDDEN ON)
endif()

CPMAddPackage(
    NAME simde
    URL "https://github.com/simd-everywhere/simde/archive/refs/tags/v0.7.2.tar.gz"
    VERSION 0.7.2
    DOWNLOAD_ONLY YES)
if(simde_ADDED)
    add_library(simde INTERFACE
        "${simde_SOURCE_DIR}/simde/arm/neon.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/aba.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/abd.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/abdl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/abs.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/add.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/addl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/addl_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/addlv.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/addv.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/addw.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/addw_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/and.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/bic.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/bsl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cagt.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/ceq.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/ceqz.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cge.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cgez.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cgt.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cgtz.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cle.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/clez.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cls.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/clt.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cltz.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/clz.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cnt.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/combine.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/create.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/cvt.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/dot.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/dot_lane.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/dup_lane.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/dup_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/eor.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/ext.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/get_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/get_lane.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/get_low.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/hadd.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/hsub.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/ld1.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/ld3.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/ld4.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/max.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/maxnm.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/maxv.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/min.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/minnm.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/minv.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mla.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mla_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mlal.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mlal_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mlal_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mls.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mlsl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mlsl_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mlsl_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/movl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/movl_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/movn.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/movn_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mul.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mul_lane.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mul_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mull.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mull_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mull_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/mvn.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/neg.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/orn.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/orr.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/padal.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/padd.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/paddl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/pmax.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/pmin.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qabs.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qadd.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qdmulh.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qdmull.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qmovn.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qmovn_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qmovun.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qneg.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qrdmulh.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qrdmulh_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qshl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qsub.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qtbl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/qtbx.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rbit.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/reinterpret.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rev16.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rev32.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rev64.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rhadd.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rnd.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rndi.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rndm.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rndn.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rndp.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rshl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rshr_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/rsra_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/set_lane.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/shl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/shl_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/shr_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/sra_n.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/st1.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/st1_lane.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/st3.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/st4.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/sub.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/subl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/subw.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/subw_high.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/tbl.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/tbx.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/trn.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/trn1.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/trn2.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/tst.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/types.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/uqadd.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/uzp.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/uzp1.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/uzp2.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/zip.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/zip1.h"
        "${simde_SOURCE_DIR}/simde/arm/neon/zip2.h"
        "${simde_SOURCE_DIR}/simde/check.h"
        "${simde_SOURCE_DIR}/simde/debug-trap.h"
        "${simde_SOURCE_DIR}/simde/hedley.h"
        "${simde_SOURCE_DIR}/simde/simde-align.h"
        "${simde_SOURCE_DIR}/simde/simde-arch.h"
        "${simde_SOURCE_DIR}/simde/simde-common.h"
        "${simde_SOURCE_DIR}/simde/simde-complex.h"
        "${simde_SOURCE_DIR}/simde/simde-constify.h"
        "${simde_SOURCE_DIR}/simde/simde-detect-clang.h"
        "${simde_SOURCE_DIR}/simde/simde-diagnostic.h"
        "${simde_SOURCE_DIR}/simde/simde-features.h"
        "${simde_SOURCE_DIR}/simde/simde-math.h"
        "${simde_SOURCE_DIR}/simde/x86/avx.h"
        "${simde_SOURCE_DIR}/simde/x86/avx2.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/2intersect.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/abs.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/add.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/adds.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/and.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/andnot.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/avg.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/blend.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/broadcast.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/cast.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/cmp.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/cmpeq.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/cmpge.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/cmpgt.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/cmple.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/cmplt.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/copysign.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/cvt.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/cvts.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/div.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/extract.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/fmadd.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/fmsub.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/fnmadd.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/fnmsub.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/insert.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/kshift.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/load.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/loadu.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/lzcnt.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/madd.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/maddubs.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/max.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/min.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/mov.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/mov_mask.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/movm.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/mul.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/mulhi.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/mulhrs.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/mullo.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/negate.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/or.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/packs.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/packus.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/permutex2var.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/permutexvar.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/sad.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/set.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/set1.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/set4.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/setone.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/setr.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/setr4.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/setzero.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/shuffle.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/sll.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/slli.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/sllv.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/sqrt.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/sra.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/srai.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/srav.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/srl.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/srli.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/srlv.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/store.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/storeu.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/sub.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/subs.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/test.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/types.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/unpackhi.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/unpacklo.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/xor.h"
        "${simde_SOURCE_DIR}/simde/x86/avx512/xorsign.h"
        "${simde_SOURCE_DIR}/simde/x86/clmul.h"
        "${simde_SOURCE_DIR}/simde/x86/fma.h"
        "${simde_SOURCE_DIR}/simde/x86/gfni.h"
        "${simde_SOURCE_DIR}/simde/x86/mmx.h"
        "${simde_SOURCE_DIR}/simde/x86/sse.h"
        "${simde_SOURCE_DIR}/simde/x86/sse2.h"
        "${simde_SOURCE_DIR}/simde/x86/sse3.h"
        "${simde_SOURCE_DIR}/simde/x86/sse4.1.h"
        "${simde_SOURCE_DIR}/simde/x86/sse4.2.h"
        "${simde_SOURCE_DIR}/simde/x86/ssse3.h"
        "${simde_SOURCE_DIR}/simde/x86/svml.h"
        "${simde_SOURCE_DIR}/simde/x86/xop.h")
    target_include_directories(simde INTERFACE simde/)
endif()

set(SEQ_FILES
    seq.cpp
    seq.h
    sw/ksw2.h
    sw/ksw2_extd2_sse.cpp
    sw/ksw2_exts2_sse.cpp
    sw/ksw2_extz2_sse.cpp
    sw/ksw2_gg2_sse.cpp
    sw/intersw.h
    sw/intersw.cpp)
set(SEQ_IR_FILES
    ir/pipeline.cpp
    ir/pipeline.h
    ir/revcomp.cpp
    ir/revcomp.h
    ir/seq.cpp
    ir/seq.h)
add_library(seq SHARED ${SEQ_FILES} ${SEQ_IR_FILES})
add_library(seq_static STATIC ${HTSLIB_FILES} ${SEQ_FILES})
add_dependencies(seq htslib simde)
add_dependencies(seq_static htslib simde)
if (APPLE AND CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL "arm64")
    set_source_files_properties(sw/intersw.cpp PROPERTIES COMPILE_FLAGS -mcpu=apple-m1)
else()
    set_source_files_properties(sw/intersw.cpp PROPERTIES COMPILE_FLAGS -march=native)
endif()
if(APPLE)
    target_link_libraries(seq PRIVATE
      -Wl,-force_load,$<TARGET_FILE:htslib>)
else()
    target_link_libraries(seq PRIVATE
      -Wl,--whole-archive $<TARGET_FILE:htslib> -Wl,--no-whole-archive)
endif()

find_package(LLVM REQUIRED CONFIG)
separate_arguments(LLVM_DEFINITIONS_LIST NATIVE_COMMAND ${LLVM_DEFINITIONS})
add_definitions(${LLVM_DEFINITIONS_LIST})

if(NOT CODON_PATH)
    set(CODON_PATH "$ENV{HOME}/.codon")
endif()

target_include_directories(seq PRIVATE "${CODON_PATH}/include" ${LLVM_INCLUDE_DIRS} "${simde_SOURCE_DIR}")
target_link_directories(seq PRIVATE "${CODON_PATH}/lib/codon")
target_link_libraries(seq PRIVATE codonrt codonc)

target_include_directories(seq_static BEFORE PRIVATE "${htslib_SOURCE_DIR}" "${xz_SOURCE_DIR}/src/liblzma/api" "${CODON_PATH}/include" "${simde_SOURCE_DIR}")
set_target_properties(seq_static PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    VISIBILITY_INLINES_HIDDEN ON)


# Download and unpack googletest at configure time
include(FetchContent)
FetchContent_Declare(googletest
  URL https://github.com/google/googletest/archive/609281088cfefc76f9d0ce82e1ff6c30cc3591e5.zip)
# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)
enable_testing()
if(IS_DIRECTORY "${googletest_SOURCE_DIR}")
    set_property(DIRECTORY ${googletest_SOURCE_DIR} PROPERTY EXCLUDE_FROM_ALL YES)
endif()
add_executable(seqtest test/main.cpp)
target_include_directories(seqtest PRIVATE "${CODON_PATH}/include" ${LLVM_INCLUDE_DIRS})
target_link_directories(seqtest PRIVATE "${CODON_PATH}/lib/codon")
target_link_libraries(seqtest codonrt codonc gtest_main)
target_compile_definitions(seqtest PRIVATE TEST_DIR="${CMAKE_CURRENT_SOURCE_DIR}/test")

install(TARGETS seq DESTINATION build)
install(TARGETS seq_static DESTINATION build)
install(FILES plugin.toml DESTINATION .)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/stdlib DESTINATION .)
