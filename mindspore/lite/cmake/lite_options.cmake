set(BUILD_LITE "on")

include(${CMAKE_CURRENT_SOURCE_DIR}/secure_option.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/compile_link_option.cmake)

#Options that can be configured through environment variables or manually
set(MSLITE_GPU_BACKEND "" CACHE STRING "enable gpu backend, \
    opencl only support arm64 and x86_64 , tensorrt only support x86_64, opencl/cuda/tensorrt/off")
set(MSLITE_REGISTRY_DEVICE "off" CACHE STRING "Compile Mindspore Lite that supports specific devices, \
    currently supported devices: Hi3516D/Hi3519A/Hi3559A/SD3403")
set(MSLITE_MICRO_PLATFORM "auto" CACHE STRING "Platform of micro static library micro static, \
    currently supported : cortex-m7/auto")
if(NOT ENABLE_CLOUD_AND_LITE)
    set(MSLITE_MINDDATA_IMPLEMENT "lite_cv" CACHE STRING "off, lite_cv, cloud, or full")
else()
    if(${CMAKE_HOST_SYSTEM_PROCESSOR} MATCHES "aarch64")
        set(PLATFORM_ARM64 "on")
        set(MACHINE_LINUX_ARM64 "on")
    endif()
endif()
option(MSLITE_ENABLE_NPU "enable npu, only arm64 or arm32 support" off)
option(MSLITE_ENABLE_TRAIN "enable train" on)
option(MSLITE_ENABLE_SSE "enable SSE instruction set, only x86_64 support" off)
option(MSLITE_ENABLE_AVX "enable AVX instruction set, only x86_64 support" off)
option(MSLITE_ENABLE_AVX512 "enable AVX512 instruction set, only x86_64 support" off)
option(MSLITE_ENABLE_CONVERTER "enable converter" on)
option(MSLITE_ENABLE_TOOLS "enable tools" on)
option(MSLITE_ENABLE_TESTCASES "enable testcase" off)
option(MSLITE_ENABLE_RUNTIME_PASS "enable runtime pass" on)
option(MSLITE_ENABLE_HIGH_PERFORMANCE "enable high performance" off)
option(MSLITE_ENABLE_STRING_KERNEL "enable string kernel" on)
option(MSLITE_ENABLE_CONTROLFLOW "enable control and tensorlist" on)
option(MSLITE_ENABLE_AUTO_PARALLEL "enable automatic parallelism" on)
option(MSLITE_ENABLE_WEIGHT_DECODE "enable weight decode" on)
option(MSLITE_ENABLE_CUSTOM_KERNEL "enable extend kernel registry" on)
option(MSLITE_ENABLE_MINDRT "enable mindrt use" on)
option(MSLITE_ENABLE_DELEGATE "enable delegate use" on)
option(MSLITE_ENABLE_FP16 "Whether to compile Fp16 operator" off)
option(MSLITE_ENABLE_INT8 "Whether to compile Int8 operator" on)
option(MSLITE_ENABLE_ACL "enable ACL" off)
option(MSLITE_ENABLE_MODEL_ENCRYPTION "enable model encryption" off)
option(MSLITE_ENABLE_SPARSE_COMPUTE "enable sparse kernel" off)
option(MSLITE_ENABLE_RUNTIME_CONVERT "enable runtime convert" off)
option(MSLITE_ENABLE_RUNTIME_GLOG "enable runtime glog" off)
option(MSLITE_ENABLE_COVERAGE "enable code coverage" off)
option(MSLITE_ENABLE_SERVER_INFERENCE "enable inference on server" off)
option(MSLITE_ENABLE_DYNAMIC_THREAD_DISTRIBUTE "enable distribute thread dynamically" off)
option(MSLITE_ENABLE_BFC_MEMORY "enable distribute BFC memory" off)
option(MSLITE_ENABLE_PARALLEL_INFERENCE "enable parallel inference interface" off)
option(MSLITE_ENABLE_SHARING_MODEL_WEIGHT "enable sharing model weight" off)
option(MSLITE_ENABLE_EXPERIMENTAL_KERNEL "enable experimental kernel" on)
option(MSLITE_ENABLE_GRAPH_KERNEL "enable graph kernel" off)
option(MSLITE_ENABLE_CONVERT_PYTORCH_MODEL "enable to convert pytorch model" off)
option(MSLITE_ENABLE_KERNEL_EXECUTOR "enable kernel executor" off)
option(MSLITE_ENABLE_GITEE_MIRROR "enable download third_party from gitee mirror" off)
option(MSLITE_ENABLE_CLOUD_FUSION_INFERENCE "enable cloud and device fusion inference architecture" off)

#Option that can be configured through manually
option(ENABLE_VERBOSE "" off)
option(ENABLE_MODEL_OBF "if support model obfuscation" off)
set(VERSION_STR "1.7.0" CACHE STRING "get from version")

if(MACHINE_LINUX_ARM64)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv8-a+fp16")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8-a+fp16")
endif()

if(DEFINED ENV{MSLITE_ENABLE_EXPERIMENTAL_KERNEL})
    set(MSLITE_ENABLE_EXPERIMENTAL_KERNEL $ENV{MSLITE_ENABLE_EXPERIMENTAL_KERNEL})
endif()

if(DEFINED ENV{MSLITE_GPU_BACKEND})
    set(MSLITE_GPU_BACKEND $ENV{MSLITE_GPU_BACKEND})
endif()
if(DEFINED ENV{MSLITE_REGISTRY_DEVICE})
    set(MSLITE_REGISTRY_DEVICE $ENV{MSLITE_REGISTRY_DEVICE})
endif()
if(DEFINED ENV{MSLITE_MICRO_PLATFORM})
    set(MSLITE_MICRO_PLATFORM $ENV{MSLITE_MICRO_PLATFORM})
endif()
if(DEFINED ENV{MSLITE_ENABLE_NPU})
    set(MSLITE_ENABLE_NPU $ENV{MSLITE_ENABLE_NPU})
endif()
if(DEFINED ENV{MSLITE_ENABLE_TRAIN})
    set(MSLITE_ENABLE_TRAIN $ENV{MSLITE_ENABLE_TRAIN})
endif()

if(DEFINED ENV{MSLITE_ENABLE_SERVER_INFERENCE})
    set(MSLITE_ENABLE_SERVER_INFERENCE $ENV{MSLITE_ENABLE_SERVER_INFERENCE})
endif()
if(MSLITE_ENABLE_SERVER_INFERENCE)
    set(MSLITE_ENABLE_DYNAMIC_THREAD_DISTRIBUTE on)
    set(MSLITE_ENABLE_BFC_MEMORY on)
    set(MSLITE_ENABLE_PARALLEL_INFERENCE on)
    set(MSLITE_ENABLE_SHARING_MODEL_WEIGHT on)
    set(MSLITE_ENABLE_RUNTIME_GLOG on)
    set(MSLITE_ENABLE_AVX512 on)
endif()
if(DEFINED ENV{MSLITE_ENABLE_SSE})
    set(MSLITE_ENABLE_SSE $ENV{MSLITE_ENABLE_SSE})
endif()
if(DEFINED ENV{MSLITE_ENABLE_AVX})
    set(MSLITE_ENABLE_AVX $ENV{MSLITE_ENABLE_AVX})
endif()
if(DEFINED ENV{MSLITE_ENABLE_AVX512})
    set(MSLITE_ENABLE_AVX512 $ENV{MSLITE_ENABLE_AVX512})
endif()
if(DEFINED ENV{MSLITE_ENABLE_CONVERTER})
    set(MSLITE_ENABLE_CONVERTER $ENV{MSLITE_ENABLE_CONVERTER})
endif()
if(DEFINED ENV{MSLITE_ENABLE_RUNTIME_CONVERT})
    set(MSLITE_ENABLE_RUNTIME_CONVERT $ENV{MSLITE_ENABLE_RUNTIME_CONVERT})
endif()
if(DEFINED ENV{ENABLE_AKG} AND NOT MSLITE_ENABLE_RUNTIME_CONVERT)
    set(MSLITE_ENABLE_GRAPH_KERNEL $ENV{ENABLE_AKG})
endif()
if(DEFINED ENV{MSLITE_ENABLE_TOOLS})
    set(MSLITE_ENABLE_TOOLS $ENV{MSLITE_ENABLE_TOOLS})
endif()
if(DEFINED ENV{MSLITE_ENABLE_TESTCASES})
    set(MSLITE_ENABLE_TESTCASES $ENV{MSLITE_ENABLE_TESTCASES})
endif()
if(DEFINED ENV{MSLITE_ENABLE_RUNTIME_PASS})
    set(MSLITE_ENABLE_RUNTIME_PASS $ENV{MSLITE_ENABLE_RUNTIME_PASS})
endif()
if(DEFINED ENV{MSLITE_ENABLE_HIGH_PERFORMANCE})
    set(MSLITE_ENABLE_HIGH_PERFORMANCE $ENV{MSLITE_ENABLE_HIGH_PERFORMANCE})
endif()
if(DEFINED ENV{MSLITE_ENABLE_STRING_KERNEL})
    set(MSLITE_ENABLE_STRING_KERNEL $ENV{MSLITE_ENABLE_STRING_KERNEL})
endif()
if(DEFINED ENV{MSLITE_ENABLE_CONTROLFLOW})
    set(MSLITE_ENABLE_CONTROLFLOW $ENV{MSLITE_ENABLE_CONTROLFLOW})
endif()
if(DEFINED ENV{MSLITE_ENABLE_AUTO_PARALLEL})
    set(MSLITE_ENABLE_AUTO_PARALLEL $ENV{MSLITE_ENABLE_AUTO_PARALLEL})
endif()
if(DEFINED ENV{MSLITE_ENABLE_WEIGHT_DECODE})
    set(MSLITE_ENABLE_WEIGHT_DECODE $ENV{MSLITE_ENABLE_WEIGHT_DECODE})
endif()
if(DEFINED ENV{MSLITE_ENABLE_CUSTOM_KERNEL})
    set(MSLITE_ENABLE_CUSTOM_KERNEL $ENV{MSLITE_ENABLE_CUSTOM_KERNEL})
endif()
if(DEFINED ENV{MSLITE_ENABLE_MINDRT})
    set(MSLITE_ENABLE_MINDRT $ENV{MSLITE_ENABLE_MINDRT})
endif()
if(DEFINED ENV{MSLITE_ENABLE_DELEGATE})
    set(MSLITE_ENABLE_DELEGATE $ENV{MSLITE_ENABLE_DELEGATE})
endif()
if(DEFINED ENV{MSLITE_ENABLE_FP16})
    set(MSLITE_ENABLE_FP16 $ENV{MSLITE_ENABLE_FP16})
endif()
if(DEFINED ENV{MSLITE_ENABLE_INT8})
    set(MSLITE_ENABLE_INT8 $ENV{MSLITE_ENABLE_INT8})
endif()
if(DEFINED ENV{MSLITE_ENABLE_SPARSE_COMPUTE})
    set(MSLITE_ENABLE_SPARSE_COMPUTE $ENV{MSLITE_ENABLE_SPARSE_COMPUTE})
endif()
if(DEFINED ENV{MSLITE_ENABLE_ACL})
    set(MSLITE_ENABLE_ACL $ENV{MSLITE_ENABLE_ACL})
endif()
if(DEFINED ENV{MSLITE_MINDDATA_IMPLEMENT})
    set(MSLITE_MINDDATA_IMPLEMENT $ENV{MSLITE_MINDDATA_IMPLEMENT})
endif()
if(DEFINED ENV{MSLITE_ENABLE_MODEL_ENCRYPTION})
    if((${CMAKE_SYSTEM_NAME} MATCHES "Linux" AND PLATFORM_X86_64)
            OR((PLATFORM_ARM64 OR PLATFORM_ARM32) AND ANDROID_NDK_TOOLCHAIN_INCLUDED))
        set(MSLITE_ENABLE_MODEL_ENCRYPTION $ENV{MSLITE_ENABLE_MODEL_ENCRYPTION})
    else()
        set(MSLITE_ENABLE_MODEL_ENCRYPTION OFF)
    endif()
endif()

if(DEFINED ENV{MSLITE_ENABLE_COVERAGE})
    set(MSLITE_ENABLE_COVERAGE $ENV{MSLITE_ENABLE_COVERAGE})
endif()

if(DEFINED ENV{MSLITE_ENABLE_SERVING})
    set(MSLITE_ENABLE_SERVING $ENV{MSLITE_ENABLE_SERVING})
endif()
if(DEFINED ENV{MSLITE_ENABLE_KERNEL_EXECUTOR})
    set(MSLITE_ENABLE_KERNEL_EXECUTOR $ENV{MSLITE_ENABLE_KERNEL_EXECUTOR})
endif()

if(DEFINED ENV{MSLITE_ENABLE_CONVERT_PYTORCH_MODEL} AND DEFINED ENV{LIB_TORCH_PATH})
    set(ENABLE_CONVERT_PYTORCH_MODEL $ENV{MSLITE_ENABLE_CONVERT_PYTORCH_MODEL})
    set(LIB_TORCH_PATH $ENV{LIB_TORCH_PATH})
endif()

if(DEFINED ENV{MSLITE_ENABLE_GITEE_MIRROR})
    set(MSLITE_ENABLE_GITEE_MIRROR $ENV{MSLITE_ENABLE_GITEE_MIRROR})
endif()

if(MSLITE_ENABLE_GITEE_MIRROR)
    set(ENABLE_GITEE ON)
endif()

if(DEFINED ENV{MSLITE_ENABLE_CLOUD_FUSION_INFERENCE})
    set(MSLITE_ENABLE_CLOUD_FUSION_INFERENCE $ENV{MSLITE_ENABLE_CLOUD_FUSION_INFERENCE})
endif()

if(TOOLCHAIN_NAME STREQUAL "himix200")
    set(TARGET_HIMIX on)
    set(TARGET_HIMIX200 on)
elseif(TOOLCHAIN_NAME STREQUAL "himix100")
    set(TARGET_HIMIX on)
    set(TARGET_HIMIX100 on)
elseif(TOOLCHAIN_NAME STREQUAL "mix210")
    set(TARGET_MIX210 on)
elseif(TOOLCHAIN_NAME STREQUAL "ohos-lite")
    set(TARGET_OHOS_LITE on)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 7.3.0
        AND NOT TARGET_HIMIX AND NOT TARGET_MIX210)
    message(FATAL_ERROR "GCC version ${CMAKE_CXX_COMPILER_VERSION} must not be less than 7.3.0")
endif()

if(NOT MSLITE_ENABLE_ACL)
    set(ENABLE_GLIBCXX ON)
else()
    set(MSLITE_ENABLE_TRAIN off)
endif()

if(PLATFORM_ARM64)
    if(MSLITE_GPU_BACKEND STREQUAL "")
        set(MSLITE_GPU_BACKEND "opencl")
    endif()
    if((NOT MSLITE_GPU_BACKEND STREQUAL "opencl") AND (NOT MSLITE_GPU_BACKEND STREQUAL "off"))
        message("invalid MSLITE_GPU_BACKEND value ${MSLITE_GPU_BACKEND} for arm64, MSLITE_GPU_BACKEND is set to off.")
        set(MSLITE_GPU_BACKEND "off")
    endif()
elseif(PLATFORM_ARM32)
    if((NOT MSLITE_GPU_BACKEND STREQUAL "opencl") AND (NOT MSLITE_GPU_BACKEND STREQUAL "off") AND
    (NOT MSLITE_GPU_BACKEND STREQUAL ""))
        message("invalid MSLITE_GPU_BACKEND value ${MSLITE_GPU_BACKEND} for arm32, MSLITE_GPU_BACKEND is set to off.")
        set(MSLITE_GPU_BACKEND "off")
    endif()
elseif(WIN32)
    set(MSLITE_GPU_BACKEND "off")
else()
    if(${MSLITE_REGISTRY_DEVICE}  STREQUAL "SD3403")
        set(MSLITE_ENABLE_DPICO_ATC_ADAPTER on)
    endif()
    if(MSLITE_GPU_BACKEND STREQUAL "")
        set(MSLITE_GPU_BACKEND "off")
    endif()
    if((NOT MSLITE_GPU_BACKEND STREQUAL "tensorrt") AND (NOT MSLITE_GPU_BACKEND STREQUAL "off") AND
    (NOT MSLITE_GPU_BACKEND STREQUAL "cuda") AND (NOT MSLITE_GPU_BACKEND STREQUAL "opencl"))
        message("invalid MSLITE_GPU_BACKEND value ${MSLITE_GPU_BACKEND} for x86_64, MSLITE_GPU_BACKEND is set to off.")
        set(MSLITE_GPU_BACKEND "off")
    endif()
endif()

if(PLATFORM_ARM64 OR PLATFORM_ARM32)
    set(PLATFORM_ARM "on")
    set(MSLITE_ENABLE_SSE off)
    set(MSLITE_ENABLE_AVX off)
    set(MSLITE_ENABLE_AVX512 off)
    if(NOT MACHINE_LINUX_ARM64)
        set(MSLITE_ENABLE_CONVERTER off)
    endif()
    set(MSLITE_ENABLE_RUNTIME_GLOG off)
    set(MSLITE_ENABLE_RUNTIME_CONVERT off)
#set for cross - compiling toolchain
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)
else()
    set(MSLITE_ENABLE_NPU off)
endif()

if(DEFINED ENV{MSLITE_ENABLE_RUNTIME_GLOG})
    set(MSLITE_ENABLE_RUNTIME_GLOG $ENV{MSLITE_ENABLE_RUNTIME_GLOG})
endif()

if(DEFINED ENV{MSLITE_ENABLE_DYNAMIC_THREAD_DISTRIBUTE})
    set(MSLITE_ENABLE_DYNAMIC_THREAD_DISTRIBUTE $ENV{MSLITE_ENABLE_DYNAMIC_THREAD_DISTRIBUTE})
endif()

if(DEFINED ENV{MSLITE_ENABLE_BFC_MEMORY})
    set(MSLITE_ENABLE_BFC_MEMORY $ENV{MSLITE_ENABLE_BFC_MEMORY})
endif()

if(DEFINED ENV{MSLITE_ENABLE_PARALLEL_INFERENCE})
    set(MSLITE_ENABLE_PARALLEL_INFERENCE $ENV{MSLITE_ENABLE_PARALLEL_INFERENCE})
endif()

if(DEFINED ENV{MSLITE_ENABLE_SHARING_MODEL_WEIGHT})
    set(MSLITE_ENABLE_SHARING_MODEL_WEIGHT $ENV{MSLITE_ENABLE_SHARING_MODEL_WEIGHT})
endif()

if(MSLITE_ENABLE_SSE OR MSLITE_ENABLE_AVX OR MSLITE_ENABLE_AVX512 OR WIN32)
    set(MSLITE_ENABLE_RUNTIME_CONVERT off)
endif()

if(MSLITE_ENABLE_TRAIN AND NOT MSLITE_ENABLE_WEIGHT_DECODE)
    message(FATAL_ERROR "If MSLITE_ENABLE_WEIGHT_DECODE use if configured as off, "
            "MSLITE_ENABLE_TRAIN must also be configured as off")
endif()

if(MSLITE_ENABLE_CONTROLFLOW AND NOT MSLITE_ENABLE_MINDRT)
    message(FATAL_ERROR "If MSLITE_ENABLE_MINDRT use if configured as off, "
            "MSLITE_ENABLE_CONTROLFLOW must also be configured as off")
endif()

if(MSLITE_ENABLE_RUNTIME_CONVERT)
    set(MSLITE_ENABLE_RUNTIME_GLOG on)
    set(MSLITE_ENABLE_CONVERTER on)
endif()

if(MSLITE_ENABLE_CLOUD_FUSION_INFERENCE)
    set(MSLITE_ENABLE_RUNTIME_GLOG on)
endif()

if(MSLITE_ENABLE_TRAIN)
    set(SUPPORT_TRAIN on)
    if(NOT MSLITE_MINDDATA_IMPLEMENT STREQUAL "off" OR NOT PLATFORM_ARM)
        set(MSLITE_MINDDATA_IMPLEMENT full)
    endif()
endif()

if(MSLITE_ENABLE_NPU)
    set(SUPPORT_NPU on)
    if(NOT PLATFORM_ARM)
        message(FATAL_ERROR "NPU only support platform arm.")
    endif()
    if(DEFINED ENV{HWHIAI_DDK})
        message("HWHIAI_DDK=$ENV{HWHIAI_DDK}")
    else()
        message(FATAL_ERROR "please set HWHIAI_DDK, example: export HWHIAI_DDK=/root/usr/hwhiai-ddk-100.510.010.010/")
    endif()
endif()

if(TARGET_HIMIX OR TARGET_OHOS_LITE)
  set(MSLITE_ENABLE_MINDRT off)
endif()

if(MSVC)
  set(MSLITE_ENABLE_CONVERTER off)
endif()

if(MSLITE_GPU_BACKEND STREQUAL cuda)
    set(MSLITE_ENABLE_CONVERTER on)
    set(MSLITE_ENABLE_RUNTIME_GLOG on)
endif()

if(MSLITE_ENABLE_FP16 AND PLATFORM_ARM32 AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 9.0 OR CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 12.0)
        message(STATUS "If you want to build fp16 in arm82_a32, please use android nkd r21e or r22b!")
        set(MSLITE_ENABLE_FP16 off)
    endif()
endif()

message(STATUS "************MindSpore Lite Build Option:************")
message(STATUS "\tMSLITE_GPU_BACKEND                         = \t${MSLITE_GPU_BACKEND}")
message(STATUS "\tMSLITE_REGISTRY_DEVICE                     = \t${MSLITE_REGISTRY_DEVICE}")
message(STATUS "\tMSLITE_ENABLE_NPU                          = \t${MSLITE_ENABLE_NPU}")
message(STATUS "\tMSLITE_ENABLE_TRAIN                        = \t${MSLITE_ENABLE_TRAIN}")
message(STATUS "\tMSLITE_MICRO_PLATFORM                      = \t${MSLITE_MICRO_PLATFORM}")
message(STATUS "\tMSLITE_ENABLE_SSE                          = \t${MSLITE_ENABLE_SSE}")
message(STATUS "\tMSLITE_ENABLE_AVX                          = \t${MSLITE_ENABLE_AVX}")
message(STATUS "\tMSLITE_ENABLE_AVX512                       = \t${MSLITE_ENABLE_AVX512}")
message(STATUS "\tMSLITE_ENABLE_CONVERTER                    = \t${MSLITE_ENABLE_CONVERTER}")
message(STATUS "\tMSLITE_ENABLE_TOOLS                        = \t${MSLITE_ENABLE_TOOLS}")
message(STATUS "\tMSLITE_ENABLE_TESTCASES                    = \t${MSLITE_ENABLE_TESTCASES}")
message(STATUS "\tMSLITE_ENABLE_HIGH_PERFORMANCE             = \t${MSLITE_ENABLE_HIGH_PERFORMANCE}")
message(STATUS "\tMSLITE_ENABLE_RUNTIME_PASS                 = \t${MSLITE_ENABLE_RUNTIME_PASS}")
message(STATUS "\tMSLITE_ENABLE_STRING_KERNEL                = \t${MSLITE_ENABLE_STRING_KERNEL}")
message(STATUS "\tMSLITE_ENABLE_CONTROLFLOW                  = \t${MSLITE_ENABLE_CONTROLFLOW}")
message(STATUS "\tMSLITE_ENABLE_AUTO_PARALLEL                = \t${MSLITE_ENABLE_AUTO_PARALLEL}")
message(STATUS "\tMSLITE_ENABLE_WEIGHT_DECODE                = \t${MSLITE_ENABLE_WEIGHT_DECODE}")
message(STATUS "\tMSLITE_ENABLE_CUSTOM_KERNEL                = \t${MSLITE_ENABLE_CUSTOM_KERNEL}")
message(STATUS "\tMSLITE_ENABLE_MINDRT                       = \t${MSLITE_ENABLE_MINDRT}")
message(STATUS "\tMSLITE_MINDDATA_IMPLEMENT                  = \t${MSLITE_MINDDATA_IMPLEMENT}")
message(STATUS "\tMSLITE_ENABLE_DELEGATE                     = \t${MSLITE_ENABLE_DELEGATE}")
message(STATUS "\tMSLITE_ENABLE_ACL                          = \t${MSLITE_ENABLE_ACL}")
message(STATUS "\tMSLITE_ENABLE_FP16                         = \t${MSLITE_ENABLE_FP16}")
message(STATUS "\tMSLITE_ENABLE_INT8                         = \t${MSLITE_ENABLE_INT8}")
message(STATUS "\tMSLITE_ENABLE_MODEL_ENCRYPTION             = \t${MSLITE_ENABLE_MODEL_ENCRYPTION}")
message(STATUS "\tMSLITE_ENABLE_SPARSE_COMPUTE               = \t${MSLITE_ENABLE_SPARSE_COMPUTE}")
message(STATUS "\tMSLITE_ENABLE_RUNTIME_CONVERT              = \t${MSLITE_ENABLE_RUNTIME_CONVERT}")
message(STATUS "\tMSLITE_ENABLE_RUNTIME_GLOG                 = \t${MSLITE_ENABLE_RUNTIME_GLOG}")
message(STATUS "\tMSLITE_ENABLE_COVERAGE                     = \t${MSLITE_ENABLE_COVERAGE}")
message(STATUS "\tMSLITE_ENABLE_SERVER_INFERENCE             = \t${MSLITE_ENABLE_SERVER_INFERENCE}")
message(STATUS "\tMSLITE_ENABLE_DYNAMIC_THREAD_DISTRIBUTE    = \t${MSLITE_ENABLE_DYNAMIC_THREAD_DISTRIBUTE}")
message(STATUS "\tMSLITE_ENABLE_BFC_MEMORY                   = \t${MSLITE_ENABLE_BFC_MEMORY}")
message(STATUS "\tMSLITE_ENABLE_PARALLEL_INFERENCE           = \t${MSLITE_ENABLE_PARALLEL_INFERENCE}")
message(STATUS "\tMSLITE_ENABLE_SHARING_MODEL_WEIGHT         = \t${MSLITE_ENABLE_SHARING_MODEL_WEIGHT}")
message(STATUS "\tMSLITE_ENABLE_EXPERIMENTAL_KERNEL          = \t${MSLITE_ENABLE_EXPERIMENTAL_KERNEL}")
message(STATUS "\tMSLITE_ENABLE_GRAPH_KERNEL                 = \t${MSLITE_ENABLE_GRAPH_KERNEL}")
message(STATUS "\tMSLITE_ENABLE_KERNEL_EXECUTOR              = \t${MSLITE_ENABLE_KERNEL_EXECUTOR}")
message(STATUS "\tMSLITE_ENABLE_CLOUD_FUSION_INFERENCE       = \t${MSLITE_ENABLE_CLOUD_FUSION_INFERENCE}")