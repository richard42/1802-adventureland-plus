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
    binData = open("adventureland.bin", "rb").read()
    if binData[0] != 0xC0:
        print("Invalid game core binary: missing starting LBR")
        sys.exit(1)
    endProgram = binData[1] * 256 + binData[2]
    sizeProgram = (endProgram & 0x7FFF) - 0x10
    if sizeProgram + 3 > len(binData):
        print("Invalid game core binary: file data length %i is less than required program size %i" % (len(binData), sizeProgram + 3))
        sys.exit(1)
    if binData[sizeProgram] != 0xC0:
        print("Invalid game core binary: missing ending LBR")
        sys.exit(1)
    addrGameStart = binData[sizeProgram+1] * 256 + binData[sizeProgram+2]
    if (addrGameStart & 0x7FFF) < 0x10 or (addrGameStart & 0x7FFF) >= sizeProgram + 0x10:
        print("Invalid game core binary: game start address %x is invalid" % addrGameStart)
        sys.exit(1)
    binData = binData[3:sizeProgram]
    sizeProgram -= 3
    open("adventureland.bin", "wb").write(binData)
    # Step 3: compress binary data
    cmd = "%s c9 adventureland.bin adventureland.ulz" % ulzPath
    print(cmd)
    numErrors = os.system(cmd)
    if numErrors > 0:
        print("ULZ compression of 'adventureland.bin' failed.")
        sys.exit(1)
    ulzCoreData = open("adventureland.ulz", "rb").read()
    ulzCoreData = ulzCoreData[8:]                           # strip out the 4-byte magic word and 4-byte chunk size
    sizeCoreData = len(ulzCoreData)
    # Step 4: compress splash screen, load the compressed data, and prepend the data with the sizes
    nameSplashScreen = "splashscreen-%s.txt" % term
    sizeSplashScreen = os.stat(nameSplashScreen).st_size
    cmd = "%s c9 %s splashscreen.ulz" % (ulzPath, nameSplashScreen)
    print(cmd)
    numErrors = os.system(cmd)
    if numErrors > 0:
        print("ULZ compression of '%s' failed." % nameSplashScreen)
        sys.exit(1)
    ulzSplashData = open("splashscreen.ulz", "rb").read()
    ulzSplashData = ulzSplashData[8:]                           # strip out the 4-byte magic word and 4-byte chunk size
    sizeSplashData = len(ulzSplashData)
    ulzSplashData = bytearray([sizeSplashData >> 8, sizeSplashData & 255, sizeSplashScreen & 255, sizeSplashScreen >> 8]) + ulzSplashData
    sizeSplashData += 4
    if sizeSplashData > 0x0665:
        print("Error: ULZ-compressed splash screen is %i bytes. Maximum allowed is %i." % (sizeSplashData, 0x0665))
        sys.exit(1)
    # Step 5: assemble game loader, load the binary, and splice in the game starting address and game data sizes
    cmd = "%s game_rom_loader.asm -l game_rom_loader.prn -b game_rom_loader.bin" % a18Path
    print(cmd)
    numErrors = os.system(cmd)
    if numErrors > 0:
        print("Assembly of 'game_rom_loader.asm' failed.")
        sys.exit(1)
    loaderBin = open("game_rom_loader.bin", "rb").read()
    sizeLoader = len(loaderBin)
    loaderBin = loaderBin[:-6] + bytearray([addrGameStart >> 8, addrGameStart & 255, sizeCoreData >> 8, sizeCoreData & 255, sizeProgram & 255, sizeProgram >> 8])
    if sizeLoader + sizeCoreData > 0x3000:
        print("Error: ROM loader and compressed game data are too big (%i bytes). Maximum size is %i." % (sizeLoader + sizeCoreData, 0x3000))
        sys.exit(1)
    # Step 6: read machine code of game loader, and splice everything into the ROM image
    romData = open("mcsmp20r_base.bin", "rb").read()
    romData = romData[:0x499B] + ulzSplashData + romData[0x499B+sizeSplashData:0x5000] + loaderBin + ulzCoreData + romData[0x5000 + sizeLoader + sizeCoreData:]
    open("mcsmp20r_final.bin", "wb").write(romData)

