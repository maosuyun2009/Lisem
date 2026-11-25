#!/usr/bin/env python3
"""Add the current VenusA split-CNN microprogram to a release QEMU binary."""

from pathlib import Path
import struct
import sys


TABLE_ENTRY = 0xB369E8
OLD_SIZE = 1440
NEW_SIZE = 1420
OLD_SHA256 = b"45a1bcf0d25c90421fe88cae61c3cbd71f5079a68f91f85057cfdcfe918ff517"
NEW_SHA256 = b"6f26ca978c00c69d101556372a5882820355cc47b2d9db00dc1a9ac3821c51fb"


def patch(path: Path) -> None:
    data = bytearray(path.read_bytes())
    size, pointer = struct.unpack_from("<QQ", data, TABLE_ENTRY)
    if size != OLD_SIZE:
        raise ValueError(f"unexpected LUNA table entry: size={size}, pointer={pointer:#x}")
    if data[pointer:pointer + 64] != OLD_SHA256:
        raise ValueError("unexpected old split-CNN fingerprint")
    struct.pack_into("<Q", data, TABLE_ENTRY, NEW_SIZE)
    data[pointer:pointer + 64] = NEW_SHA256
    path.write_bytes(data)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: patch_venusa_luna_cnn.py QEMU_BINARY")
    patch(Path(sys.argv[1]))
