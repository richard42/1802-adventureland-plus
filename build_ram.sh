#!/bin/bash
xlate=${1:-ansi}
sed -f xlate_$xlate.txt adventureland.asm.in > adventureland.asm
sed -f xlate_$xlate.txt adventureland_data.asm.in > adventureland_data.asm
./tools/a18 game_ram.asm -l adventureland.prn -o adventureland.hex -b adventureland.bin

