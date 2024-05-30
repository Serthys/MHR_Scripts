# MHR_Scripts
This repository manages a bunch of scripts for `Monster Hunter Rise`.
It uses:
- [AutoHotKey(v2)](https://www.autohotkey.com/) to send inputs to the game
- [Node](https://nodejs.org/en) to run Optical Character Recognition using [tesseract.js](https://tesseract.projectnaptha.com/)

# Usage
## Qurious_Armor_Augment.ahk
Run the script with the game open and the caracter located in Elgado.

## screenshot-filter.mjs (to improve)
Run to analize the augment screenshots taken with OCR and export a detailed text log with the results, the results then can be filtered using common unix commands.

Analize the screenshots and output the text to a file:
```
node.exe screenshot-filter.mjs > augment.log
```
Filter the exported result text file to show only the skills and or relevant augment levels:
```
cat augment.log | grep INFO | grep -B 1 --file=augments-filter.txt | grep -B 1 --file=skills-filter.txt
```
Filter the exported result text file to show only any errors (usually some bad OCR character):
```
cat augment.log | grep -v DEBUG | grep -B 1 ERROR
```
 Output sample:
 ![image](https://github.com/Serthys/MHR_Scripts/assets/13573099/9d89273a-c7e4-4c81-9d24-b1e5df9325a5)
