// How to use:
// clear ; node.exe screenshot-filter.mjs > augment.log ; cat augment.log | grep INFO | grep -B 1 --file=augments-filter.txt | grep -B 1 --file=skills-filter.txt ; cat augment.log | grep -v DEBUG | grep -B 1 ERROR

import Jimp from 'jimp';
import * as fs from 'fs';
import { exit } from 'process';

import { createWorker } from 'tesseract.js';

const SCREENSHOT_DIR = './Screenshots';

const SKILLS = ['Critical Eye', 'Critical Boost', 'Weakness Exploit', 'Master\'s Touch', 'Razor Sharp', 'Spare Shot', 'Normal/Rapid Up', 'Pierce Up', 'Spread Up', 'Ammo Up', 'Rapid Fire Up', 'Attack Boost', 'Guts', 'Handicraft', 'Agitator', 'Peak Performance', 'Resentment', 'Resuscitate', 'Coalescence', 'Latent Power', 'Maximum Might', 'Good Luck', 'Burst', 'Tune-Up', 'Rapid Morph', 'Artillery', 'Sneak Attack', 'Blood Rite', 'Bloodlust', 'Buildup Boost', 'Frostcraft', 'Dragon Conversion', 'Protective Polish', 'Mushroomancer', 'Mind\'s Eye', 'Critical Element', 'Ballistics', 'Critical Draw', 'Focus', 'Power Prolonger', 'Offensive Guard', 'Earplugs', 'Heroics', 'Hellfire Cloak', 'Wirebug Whisperer', 'Charge Master', 'Foray', 'Grinder (S)', 'Bladescale Hone', 'Redirection', 'Element Exploit', 'Adrenaline Rush', 'Furious', 'Status Trigger', 'Dragonheart', 'Mail of Hellfire', 'Strife', 'Powder Mantle', 'Wind Mantle', 'Frenzied Bloodlust', 'Load Shells', 'Guard', 'Guard Up', 'Poison Attack', 'Paralysis Attack', 'Sleep Attack', 'Blast Attack', 'Marathon Runner', 'Constitution', 'Stamina Surge', 'Punishing Draw', 'Quick Sheathe', 'Slugger', 'Special Ammo Boost', 'Steadiness', 'Speed Eating', 'Tremor Resistance', 'Bubbly Dance', 'Evade Window', 'Evade Extender', 'Partbreaker', 'Wall Runner', 'Counterstrike', 'Defiance', 'Reload Speed', 'Recoil Down', 'Chameleos Blessing', 'Kushala Blessing', 'Teostra Blessing', 'Embolden', 'Intrepid Heart', 'Flinch Free', 'Stamina Thief', 'Fire Attack', 'Water Attack', 'Ice Attack', 'Thunder Attack', 'Dragon Attack', 'Affinity Sliding', 'Horn Maestro', 'Defense Boost', 'Divine Blessing', 'Recovery Up', 'Recovery Speed', 'Windproof', 'Blight Resistance', 'Poison Resistance', 'Paralysis Resistance', 'Sleep Resistance', 'Stun Resistance', 'Muck Resistance', 'Blast Resistance', 'Speed Sharpening', 'Item Prolonger', 'Wide-Range', 'Free Meal', 'Fortify', 'Hunger Resistance', 'Leap of Faith', 'Diversion', 'Master Mounter', 'Spiribird\'s Call', 'Wall Runner (Boost)',
	// Skills not available but can show up via skill down
	'Dereliction'
];

const AUGMENT_PAGE_ARROW_LOCATION = { x: 125, y: 66 };
const FIRST_SKILL_SECOND_SLOT = { x: 115, y: 425 };
const THIRD_SKILL_FIRST_SLOT = { x: 90, y: 575 };
const THIRD_SKILL_FIRST_BORDER = { x: 90, y: 566 };

const LOCATION_FIRST_SLOT = { x: 262, y: 118 };
const LOCATION_SECOND_SLOT = { x: 305, y: 118 };
const LOCATION_THIRD_SLOT = { x: 346, y: 118 };
const SLOT_WIDTH = 38;

const AUGMENT_PAGINATION_Y_OFFSET = 35;

const COLOR_NO_SKILL_LINE = { r: 22, g: 22, b: 22 };
const COLOR_BACKGROUD_NO_SKILL_CHANGE = { r: 49, g: 49, b: 49 };
const COLOR_MIN_ARROW = 100;
const COLOR_MIN_GREEN_FOR_SKILL_INCRESE = 100;
const SKILL_SQUARES_WIDTH = 250;
const SKILL_SQUARE_HEIGH = 40;

// https://en.wikipedia.org/wiki/ANSI_escape_code
const ANSI_RED = '[0;31m';
const ANSI_GREEN = '[0;32m';
const ANSI_YELLOW = '[0;33m';
const ANSI_MAGENTA = '[0;35m';
const ANSI_CYAN = '[0;36m';
const ANSI_CLEAR = '[0m';

/** Init **/
const tesseractWorker = await createWorker('eng');
/** Init end **/

/** Methods **/

const debug = (string) => {
	console.debug(string);
}

const listFiles = async (directory) => {
	const dirEntries = await fs.readdirSync(directory, { withFileTypes: true });
	return dirEntries
		.filter(dirEntry => dirEntry.isFile() && dirEntry.name.includes(".png"))
		.map(dirEntry => dirEntry.name);
};

const checkAugmentPages = async (image) => {
	const rgbArrow = Jimp.intToRGBA(image.getPixelColor(AUGMENT_PAGE_ARROW_LOCATION.x, AUGMENT_PAGE_ARROW_LOCATION.y));
	if (rgbArrow.r > COLOR_MIN_ARROW && rgbArrow.g > COLOR_MIN_ARROW && rgbArrow.b > COLOR_MIN_ARROW) {
		debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + ' Screenshot has 4 or more skills changed.')
		return true;
	}
	return false;
};

const hasOnly2SkillsChanged = async (image, hasAugmentPages) => {
	if (hasAugmentPages) {
		return false;
	}

	const rgbBorder = Jimp.intToRGBA(image.getPixelColor(THIRD_SKILL_FIRST_BORDER.x, THIRD_SKILL_FIRST_BORDER.y));
	debug(rgb);
	if (rgbBorder.r == COLOR_NO_SKILL_LINE.r && rgbBorder.g == COLOR_NO_SKILL_LINE.g && rgbBorder.b == COLOR_NO_SKILL_LINE.b) {
		debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + ' Screenshot has only 2 skills changed.')
		return true;
	} else if (rgbBorder.r > COLOR_NO_SKILL_LINE.r && rgbBorder.r < COLOR_BACKGROUD_NO_SKILL_CHANGE.r) {
		// red hue present
		const rgbNoBorder = Jimp.intToRGBA(image.getPixelColor(THIRD_SKILL_FIRST_BORDER.x, THIRD_SKILL_FIRST_BORDER.y - 1));
		debug('rgbBorder: ' + JSON.stringify(rgbBorder));
		debug('rgbNoBorder: ' + JSON.stringify(rgbNoBorder));
		if (Math.abs(rgbNoBorder.r - rgbBorder.r) < 20) {
			debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + ' Screenshot has only 2 skills changed.')
			return true;
		}
	}
	debug(ANSI_CYAN + '[DEBUG]' + ANSI_CLEAR + ' Screenshot has 3 or more skills changed.')
	return false;
};

const hasfirstSkillWithOnlyOneLevel = async (image) => {
	const rgb = Jimp.intToRGBA(image.getPixelColor(FIRST_SKILL_SECOND_SLOT.x, FIRST_SKILL_SECOND_SLOT.y));
	debug(rgb);
	if (rgb.g > COLOR_MIN_GREEN_FOR_SKILL_INCRESE) {
		debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + ' Screenshot has 1+ levels or more on the first skill.')
		return false;
	}
	debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + ' Screenshot only has 1 level on the first skill.')
	return true;
};

const checkSlotIncreses = async (image, slotLocation, hasAugmentPages) => {
	const color = { r: 0, g: 0, b: 0 };
	let count = 0;
	const startingY = slotLocation.y + (hasAugmentPages ? AUGMENT_PAGINATION_Y_OFFSET : 0);
	image.scan(
		slotLocation.x,
		startingY,
		SLOT_WIDTH,
		1,
		(x, y, index) => {
			const red = image.bitmap.data[index + 0];
			const green = image.bitmap.data[index + 1];
			const blue = image.bitmap.data[index + 2];
			color.r += red;
			color.g += green;
			color.b += blue;
			count++;
		}
	);
	color.r = Math.round(color.r / count);
	color.g = Math.round(color.g / count);
	color.b = Math.round(color.b / count);
	debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + ' slot average color: [' + JSON.stringify(color) + '].');
	if (color.g >= 65 && color.r < 55 && color.b < 55) {
		debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + ' Screenshot has slot/s on' + JSON.stringify(slotLocation) + '.');
		return true;
	}
	return false;
};

const blockSkillSquares = (image, hasAugmentPages) => {
	const y_offset = hasAugmentPages ? AUGMENT_PAGINATION_Y_OFFSET : 0;
	const skillSquaresStartingYs = [400, 476, 552];
	for (const skillSquaresStartingY of skillSquaresStartingYs) {
		image.scan(
			59,
			skillSquaresStartingY + y_offset,
			SKILL_SQUARES_WIDTH,
			SKILL_SQUARE_HEIGH,
			(x, y, index) => {
				image.bitmap.data[index + 0] = 22; // red
				image.bitmap.data[index + 1] = 22; // green
				image.bitmap.data[index + 2] = 22; // blue
			}
		);
	}
};
/** Methods end **/

for (const fileName of await listFiles(SCREENSHOT_DIR)) {
	console.log(ANSI_CYAN + '[INFO]' + ANSI_CLEAR + ' Reading screenshot: [' + ANSI_YELLOW + fileName + ANSI_CLEAR + '].');
	const screenshotPath = `${SCREENSHOT_DIR}/${fileName}`;
	const image = await Jimp.read(screenshotPath);

	const hasAugmentPages = await checkAugmentPages(image);
	// const onlyTwoSkillsChanged = await hasOnly2SkillsChanged(image, hasAugmentPages);
	// const firstSkillWithOnlyOneLevel = await hasfirstSkillWithOnlyOneLevel(image);
	const slot1Increased = await checkSlotIncreses(image, LOCATION_FIRST_SLOT, hasAugmentPages);
	const slot2Increased = await checkSlotIncreses(image, LOCATION_SECOND_SLOT, hasAugmentPages);
	const slot3Increased = await checkSlotIncreses(image, LOCATION_THIRD_SLOT, hasAugmentPages);
	const slotsIncreased = slot1Increased + slot2Increased + slot3Increased;
	debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + " Slots increased: " + slotsIncreased + ' (' + slot1Increased + "," + slot2Increased + "," + slot3Increased + ')')

	blockSkillSquares(image, hasAugmentPages);
	const cropX = 59;// crop left side to remove the skill symbols
	const cropY = hasAugmentPages ? 366 + AUGMENT_PAGINATION_Y_OFFSET : 366; // crop the top to remove the resistances
	const width = image.bitmap.width - cropX - 40; // crop riget border
	const height = image.bitmap.height - cropY - (hasAugmentPages ? 130 - AUGMENT_PAGINATION_Y_OFFSET : 130); // crop the bottom to remove the confirm
	image.crop(cropX, cropY, width, height);
	// await image.writeAsync(`${SCREENSHOT_DIR}/test.png`);
	const cropped = await image.getBufferAsync('image/png')

	const ret = await tesseractWorker.recognize(cropped);
	const reading = ret.data.text;
	let lines = reading.split('\n').filter((l) => l.length);
	lines = lines.map((l) => l.startsWith('Lv ') ? l.split('Lv ')[1] : l);
	debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + ' Raw text: ' + lines + '');
	let augments = '[';
	let augmentMerit = 0;
	for (let i = 0; i < lines.length - 1; i += 2) {
		if (i != 0) augments += ', ';
		// keep numbers, lowercase, uppercase, space,  aphostrophe ('), dash (-) and parenthesis
		const skillName = lines[i].replace(/[^\x30-\x39\x41-\x5A\x61-\x7A /'\-\(\)]/, '').trim();
		debug(ANSI_MAGENTA + '[DEBUG]' + ANSI_CLEAR + ' skillName ' + (i / 2 + 1) + ': ' + skillName + '');
		if (!SKILLS.includes(skillName)) {
			console.log(ANSI_RED + '[ERROR]' + ANSI_CLEAR + ' Skill: ' + skillName + ' not found on list of possible skills');
		}
		const skillChange = lines[i + 1].replace(/[\]]/, '1').trim(); // replace wrong OCR'd "]" to "1"
		if (skillChange.includes('+')) {
			augments += ANSI_GREEN + skillName + ' ' + skillChange + ANSI_CLEAR;
			if (skillChange.includes('1')) {
				augmentMerit++;
			} else {
				augmentMerit += 2;
			}
		} else if (skillChange.includes('-') || skillChange.includes('None')) {
			augments += ANSI_RED + skillName + ' ' + skillChange + ANSI_CLEAR;
		} else {
			console.log(ANSI_RED + '[ERROR]' + ANSI_CLEAR + ' Unexpected skill level change:  [' + skillChange + '].');
		}
	}
	if (slotsIncreased) {
		if (augments.length > 1) {
			augments += ', ';
		}
		augments += ANSI_GREEN + '+' + slotsIncreased + ' Slot/s' + ANSI_CLEAR;
		augmentMerit += slotsIncreased;
	}
	augments += (hasAugmentPages ? (', ' + ANSI_RED + '...' + ANSI_CLEAR) : '') + ']';

	// Has slot and skill or more than one skill
	console.log(ANSI_CYAN + '[INFO]' + ANSI_CLEAR + ' Augments: ' + ANSI_YELLOW + '(' + augmentMerit + ')' + ANSI_CLEAR + augments + '.');

	// break; // uncomment to run only one file
};

await tesseractWorker.terminate();
