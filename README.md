Tables Have Turned

This is an SMS demo based on swapping between nametables (tile maps) mid-display to get some special effects.
It was inspired by the below demo by lidnariq, and by Flygon suggesting that a similar effect could be achieved by changing the nametable:
https://www.smspower.org/forums/20285-SMS1ColorTableShenanigans

Tested in Emulicious and on hardware SMS2 - should work at both 50hz and 60hz.
Most emulators seem to struggle with the "Gradient with Spotlight" effect - Snepulator and RetroArch's cores just display a static screen.

Brief descriptions how the effects work:

There can be up to 8 different nametables in VRAM - but each one uses a decent chunk of memory so there's less space for tiles when you use more nametables.
Other than for the Gradient screens, the tilemaps for these effects all look like a screen full of vertical bars and it's swapping between them which gives the effects!

SMSPower! Text scaling:
* Uses 6 different nametables, one for each row of pixels in the text
* A big lookup table says which nametable to use and how many lines each row of pixels occupies.

SMSPower! Text "waterfall":
* Uses the same 6 nametables, but a different lookup table.
* The first 16 entries in the table step backwards through the rows of pixels rather than forwards, so the top of the screen mirrors the text vertically.

Gradient with bars:
* Uses 4 nametables
    * normal
    * sprite palette
    * gradient horizontally flipped
    * gradient horizontally flipped with sprite palette
* One bar says whether to use the sprite palette, the other bar says whether to use the horizontally flipped gradient, and both effects combine if the bars overlap

Gradient with spotlight:
* Uses 2 nametables, normal and sprite palette
* Cycle timed code changes the nametable mid-line so it flips to the sprite palette and back
* Sine lookup table used to move the "spotlight" around
* Seems like the nametable is latched horizontally by the VDP every tile so the spotlight's sides are a bit jaggy!

Checkerboard:
* Uses all 8 possible nametables
* Nametable changes every 3 lines
* Sine lookup table used to decide which nametable to use in each line
* Palette swaps every 32 lines to swap the checkerboard's colours

Tools used:
* Written in assembly language using WLA-DX
* Tested in Emulicious and Snepulator
* Graphics drawn in Aseprite and converted with superfamiconv
* Music written in Furnace and played back with my Banjo sound driver

