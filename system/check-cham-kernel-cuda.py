#!/usr/bin/env python3
"""Exercise a small CUDA allocation on the expected kernel, without root."""
import ctypes
import platform
import sys

expected = sys.argv[1] if len(sys.argv) == 2 else "6.8.12-cham-lab1"
if len(sys.argv) > 2:
    sys.exit("Usage: check-cham-kernel-cuda.py [expected-kernel]")
if platform.release() != expected:
    sys.exit(f"FAIL: running kernel {platform.release()}; expected {expected}")

cuda = ctypes.CDLL("libcuda.so.1")


def check(name, *args):
    result = getattr(cuda, name)(*args)
    if result:
        raise RuntimeError(f"{name} failed: CUDA error {result}")


check("cuInit", 0)
device = ctypes.c_int()
check("cuDeviceGet", ctypes.byref(device), 0)
name = ctypes.create_string_buffer(128)
check("cuDeviceGetName", name, len(name), device)
context = ctypes.c_void_p()
check("cuCtxCreate_v2", ctypes.byref(context), 0, device)
pointer = ctypes.c_uint64()
try:
    size = 16 * 1024 * 1024
    check("cuMemAlloc_v2", ctypes.byref(pointer), ctypes.c_size_t(size))
    check("cuMemsetD8_v2", pointer, 0x5A, ctypes.c_size_t(size))
    check("cuCtxSynchronize")
    sample = (ctypes.c_ubyte * 16)()
    check("cuMemcpyDtoH_v2", sample, pointer, ctypes.c_size_t(len(sample)))
    if bytes(sample) != bytes([0x5A]) * len(sample):
        raise RuntimeError("CUDA readback mismatch")
    print(f"PASS: CUDA memory allocation and readback on {name.value.decode()}")
finally:
    if pointer.value:
        check("cuMemFree_v2", pointer)
    check("cuCtxDestroy_v2", context)
