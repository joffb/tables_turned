superfamiconv --no-remap --mode sms -i gfx/text.png -m assets/text_map.bin -T 384 -t assets/text_tiles.bin -p assets/text_pal.bin
superfamiconv --no-remap --no-discard --no-flip --mode sms -i gfx/checker.png -m assets/checker_map.bin -T 48 -t assets/checker_tiles.bin -p assets/checker_pal.bin
superfamiconv --no-remap --mode sms -i gfx/gradient.png -m assets/gradient_map.bin -T 384 -t assets/gradient_tiles.bin -p assets/gradient_pal.bin

python ../banjo_git/banjo/furnace2json.py -o music/tune.json music/tune.fur
python ../banjo_git/banjo/json2sms.py -o music/tune.asm -i tune music/tune.json 

wla-z80 main.asm 
wlalink -s -r linkfile.txt tables_turned.sms