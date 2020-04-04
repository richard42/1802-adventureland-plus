#!/usr/bin/env python

import os
import sys

TOOLDIR = "./tools"

if __name__ == "__main__":
    # Initialize tool paths
    a18Path = os.path.join(TOOLDIR, "a18")
    ulzPath = os.path.join(TOOLDIR, "ulz")
    # Preprocess source files
    term="ansi"
    if len(sys.argv) >= 2:
        term = sys.argv[1]
    cmd = "sed -f xlate_%s.txt adventureland.asm.in > adventureland.asm" % term
    print(cmd)
    numErrors = os.system(cmd)
    if numErrors > 0:
        print("Preprocessing 'adventureland.asm.in' failed.")
        sys.exit(1)
    cmd = "sed -f xlate_%s.txt adventureland_data.asm.in > adventureland_data.asm" % term
    print(cmd)
    numErrors = os.system(cmd)
    if numErrors > 0:
        print("Preprocessing 'adventureland_data.asm.in' failed.")
        sys.exit(1)

    # Step 1: assemble game core
    cmd = "%s game_rom_core.asm -l adventureland.prn -b adventureland.bin" % a18Path
    print(cmd)
    numErrors = os.system(cmd)
    if numErrors > 0:
        print("Assembly of 'game_rom_core.asm' failed.")
        sys.exit(1)
    # Step 2: read machine code of game core, get addresses, strip out LBR instructions, and rewrite
    binData = open("adventureland.bin", "r").read()
    if ord(binData[0]) != 0xC0:
        print("Invalid game core binary: missing starting LBR")
        sys.exit(1)
    sizeProgram = ord(binData[1]) * 256 + ord(binData[2]) - 0x10
    if sizeProgram + 3 > len(binData):
        print("Invalid game core binary: file data length %i is less than required program size %i" % (len(binData), sizeProgram + 3))
        sys.exit(1)
    if ord(binData[sizeProgram]) != 0xC0:
        print("Invalid game core binary: missing ending LBR")
        sys.exit(1)
    addrGameStart = ord(binData[sizeProgram+1]) * 256 + ord(binData[sizeProgram+2])
    if addrGameStart < 0x10 or addrGameStart >= sizeProgram + 0x10:
        print("Invalid game core binary: game start address %x is invalid" % addrGameStart)
        sys.exit(1)
    binData = binData[3:sizeProgram]
    open("adventureland.bin", "w").write(binData)
    # Step 3: compress binary data
    cmd = "%s c9 adventureland.bin adv_core_ulz.bin" % ulzPath
    print(cmd)
    numErrors = os.system(cmd)
    if numErrors > 0:
        print("ULZ compression of 'adventureland.bin' failed.")
        sys.exit(1)
    # Step 4: read the compressed data and rewrite the header
    ulzData = open("adv_core_ulz.bin", "r").read()
    ulzData = ulzData[8:]                           # strip out the 4-byte magic word and 4-byte chunk size
    sizeComp = len(ulzData)
    ulzData = chr(0xC0) + chr(0xCA) + chr(0x00) + chr(addrGameStart >> 8) + chr(addrGameStart & 255) + chr(sizeComp >> 8) + chr(sizeComp & 255) + ulzData
    open("adv_core_ulz.bin", "w").write(ulzData)
    # Step 5: assemble game loader
    cmd = "%s game_rom_loader.asm -l adv_rom_loader.prn -b adv_rom_loader.bin" % a18Path
    print(cmd)
    numErrors = os.system(cmd)
    if numErrors > 0:
        print("Assembly of 'game_rom_loader.asm' failed.")
        sys.exit(1)
    # Step 6: read machine code of game loader, and insert it and the compressed data into ROM image
    loaderBin = open("adv_rom_loader.bin", "r").read()
    loaderLength = len(loaderBin)
    ulzLength = len(ulzData)
    romData = open("mcsmp20r_base.bin", "r").read()
    romData = romData[:0x4A00] + loaderBin + romData[0x4A00+loaderLength:0x5000] + ulzData + romData[0x5000+ulzLength:]
    open("mcsmp20r_final.bin", "w").write(romData)

