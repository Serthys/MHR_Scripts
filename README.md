# MHR_Scripts
This repository manages a bunch of scripts for `Monster Hunter Rise`.

# Dependencies:
- [AutoHotKey(v2)](https://www.autohotkey.com/) to send inputs to the game
- [Node](https://nodejs.org/en) to run Optical Character Recognition using [tesseract.js](https://tesseract.projectnaptha.com/)

# Usage
## [Qurious_Armor_Augment.ahk](https://github.com/Serthys/MHR_Scripts/blob/main/Qurious_Armor_Augment.ahk)
Automatically rolls augments rolls on armor and takes screenshots, see the script file for more details. Uses the file [augments_conf.ini](https://github.com/Serthys/MHR_Scripts/blob/main/augments_conf.ini) to configure mutliple parameters.

## [qurious_augment_ocr.mjs](https://github.com/Serthys/MHR_Scripts/blob/main/qurious_augment_ocr.mjs) (to improve)
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
Input sample:

![0-0023](https://github.com/Serthys/MHR_Scripts/assets/13573099/b730cd2f-5c92-4052-9035-143b7e710ff0)

Output sample:
 
![image](https://github.com/Serthys/MHR_Scripts/assets/13573099/9d89273a-c7e4-4c81-9d24-b1e5df9325a5)
