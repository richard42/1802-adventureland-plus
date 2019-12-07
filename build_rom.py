#!/usr/bin/env python

import os
import sys

TOOLDIR = "../../"

if __name__ == "__main__":
    # Initialize tool paths
    a18Path = os.path.join(TOOLDIR, "A18", "a18")
    ulzPath = os.path.join(TOOLDIR, "ulz", "ulz")
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
    # Step 4: read the compressed data and write out an A18 assembly file containing the compressed data
    ulzData = open("adv_core_ulz.bin", "r").read()
    sizeComp = len(ulzData)
    fOut = open("adv_core_ulz.asm", "w")
    fOut.write(";__________________________________________________________________________________________________\n")
    fOut.write("; Compressed adventureland program data\n\n")
    fOut.write("GAMESTART   EQU %04XH\n" % addrGameStart)
    fOut.write("ULZSIZE     EQU %04XH\n" % sizeComp)
    fOut.write("ULZDATA\n")
    dataIdx = 0
    while dataIdx < sizeComp:
        if (dataIdx & 15) == 0:
            fOut.write("                DB          ")
        strDataByte = "$%02X" % ord(ulzData[dataIdx])
        if dataIdx == sizeComp - 1:
            fOut.write(strDataByte + "\n\n")
            break
        if (dataIdx & 15) == 15:
            fOut.write(strDataByte + "\n")
        else:
            fOut.write(strDataByte + ", ")
        dataIdx += 1
    fOut.close()


