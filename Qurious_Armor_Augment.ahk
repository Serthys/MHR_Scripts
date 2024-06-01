;;;;;;;;;
; DOCS  ;
;;;;;;;;;
; Controls:
; - Exit: Use the F10 key or the Mouse Wheel Click to exit the script at any time.
; - Pause: Use the Pause keyboard key to stop/resume the script execution. If it was paused during a key hold the key 
; will still be hold.

; Requirements:
; Disable the automatic save on: Options -> Save Data -> Autosave Settings -> Off, otherwise the game will save after 
; closing the blacksmith menu.

; Description:
; This script will save the game (if `saveGame` is enabled), travel to the Kamura blacksmith and roll the selected 
; augment option (`augmentOption`) on the first piece of equipment (leave only one equipped for consistency) for the 
; amount of times defined (`loops`), take a screenshot (with `screenshot` enabled) save it on the `screenshotsFolder` 
; location and pause the script execution. After that you can check the screenshots taken and:
; - If you want any augment just go to "Return To title Screen" -> "No" -> "Yes" to quit without saving and go back in. 
; The augment order will be the same, so you can change to loops variable to roll to 1 before the one you want (and 
; disable the `screenshot` variable for faster rolls) to perform the rolls until that one. Equip the piece you want the 
; roll on and augment it.
; - If you don't want any augment just hit the `Pause` keyboard key and it will start the script again.

; Notes: 
; The sleep times are hardcoded for my system to work consistently, if it gets stuck you can edit this file to add 
; extra sleep at some specific point or change the `extraSleepTime` variable in the configuration to add time to all 
; sleeps.
; I tested the screenshots working with 16:9 aspect ratio on 800x600 and 1440x1080 reolutions, other aspect ratios or 
; resolutions might have different results. Change the `screnshotCoordinates` variable for better results.
;;;;;;;;;
; /DOCS ;
;;;;;;;;;

#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir% ; to use the running script directory

;;;;;;;;;;;;;;;;;
; DEPENDENCIES  ;
;;;;;;;;;;;;;;;;;
; dependency for waiting for pixel color, used to wait for black screens
#Include ahk_dependencies/WaitPixelColor.ahk
; dependency for screenshots
#Include ahk_dependencies/Gdip_All.ahk
; dependency for managing the configuration file
#Include ahk_dependencies/Ini/Ini.ahk
;;;;;;;;;;;;;;;;;
; /DEPENDENCIES ;
;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
; Config loading  ;
;;;;;;;;;;;;;;;;;;;
global Conf := Ini("augments_conf.ini")
global saveGame := Conf.GENERAL.saveGame == "true"
global screenshot := Conf.GENERAL.screenshot == "true"
global screenshotsFolder := Conf.GENERAL.screenshotsFolder
if (!screenshotsFolder) {
  global screenshotsFolder := "Screenshots"
}
global screnshotCoordinates := Conf.GENERAL.screnshotCoordinates

global loops := Conf.GENERAL.loops + 0
global augmentOption := Conf.GENERAL.augmentOption + 0

global programName := Conf.GENERAL.programName
global extraSleepTime := Conf.GENERAL.extraSleepTime + 0
global silent := Conf.GENERAL.silent == "true"
global manual := Conf.GENERAL.manual == "true"
;;;;;;;;;;;;;;;;;;;
; /Config loading ;
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROGRAM INITIALIZATION  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Window name to change focus
pause()
pToken := Gdip_Startup()
focusWindow(programName)
printTime()
ToolTip,Loops done: %0%/%loops%,0,0
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; /PROGRAM INITIALIZATION ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;
; PROGRAM START ;
;;;;;;;;;;;;;;;;;
main()

main() {
  fastTravelToBlacksmith()
  Loop {
    if(!manual && saveGame) {
      saveGame()
    }
    if(!manual) {
      startAugmentMenu()
    }
    augmentLoop()
    pause()
    exitMenu()
  }
}

augmentLoop() {
  loopCount := 0
  maxLoops := loops ; reset loop counter if the augmenting continues
  if (manual) {
    maxLoops := 0
  }
  Loop {
    ToolTip,Loops done: %loopCount%/%maxLoops%,0,0
    loopCount += 1
    augmentArmor(loopCount)
    if (maxLoops != 0) {
      ToolTip,Loops done: %loopCount%/%maxLoops%,0,0
    } else {
      ToolTip,Loops done: %loopCount%,0,0
    }
    OutputDebug, Loops Done: %loopCount%
    if (loopCount = maxLoops) {
      OutputDebug, Done augmenting
      beep()
      beep()
      break
    }
  }
}

fastTravelToBlacksmith() {
  OutputDebug, fastTravelToBlacksmith
  sleep(50) ; wait for UI update
  pressKey("m") ; open travel menu
  sleep(50) ; wait for UI update
  pressKey("Space") ; press Market
  sleep(1) ; wait for UI update
  waitForBlackScreen() ; wait for black screen
  sleep(100) ; wait for UI update
  pressKey("a", 1450) ; move toward Arlow
  pressKey("w", 1500) ; face Arlow
  sleep(50) ; wait to face Arlow
}

exitMenu() {
  OutputDebug, exitMenu
  pressKey("Esc") ;
  sleep(400) ; wait for UI update
  pressKey("Esc") ;
  sleep(400) ; wait for UI update
  pressKey("Esc") ;
  sleep(400) ; wait for UI update
  pressKey("Esc") ;
  sleep(2500) ; wait for UI update
}

saveGame() {
  OutputDebug, saveGame
  pressKey("Esc") ;
  sleep(500) ; wait for UI update
  pressKey("Left") ;
  sleep(66) ; wait for UI update
  pressKey("Down") ;
  sleep(66) ; wait for UI update
  pressKey("Down") ;
  sleep(66) ; wait for UI update
  pressKey("Down") ;
  sleep(250) ; wait for UI update
  pressKey("Space") ; press Confirm
  sleep(250) ; wait for UI update
  pressKey("Left") ; move to Yes
  sleep(250) ; wait for UI update
  pressKey("Space") ; press Yes
  sleep(4500) ; wait for UI update
}

startAugmentMenu() {
  OutputDebug, startaugmentMenu
  pressKey("f") ;
  sleep(1500) ; wait for UI update
  pressKey("Down") ;
  sleep(100) ; wait for UI update
  pressKey("Down") ;
  sleep(100) ; wait for UI update
  pressKey("Down") ;
  sleep(100) ; wait for UI update
  pressKey("Space") ; press Qurious Armor crafting
  sleep(200) ; wait for UI update
  pressKey("Space") ; select the first one
  sleep(200) ; wait for UI update

  if (augmentOption = 2) { ; for Skills+
    pressKey("Down") ; down to Augment: Stability
    sleep(200) ; wait for UI update
    pressKey("Down") ; down to Augment: Skills+
    sleep(200) ; wait for UI update
  }
  if (augmentOption = 3) { ; for Skills+
    pressKey("Down") ; down to Augment: Stability
    sleep(200) ; wait for UI update
    pressKey("Down") ; down to Augment: Skills+
    sleep(200) ; wait for UI update
    pressKey("Down") ; down to Augment: Slots+
    sleep(200) ; wait for UI update
  }

  pressKey("Space") ; press the selected option
  sleep(200) ; wait for UI update
}

augmentArmor(loopCount) {
  pressKey("x") ; autoselect materials
  sleep(150) ; wait for UI update
  pressKey("Space") ; press Confirm
  sleep(225) ; wait for UI update
  pressKey("Space") ; press Yes
  if (waitForBlackScreen(5000) = 2) { ; wait for black screen
    OutputDebug, Black screen not found
    beep()
    beep()
    pause()
  }
  sleep(425)
  if (manual) {
    pause()
  } else {
    screenshotAugment(loopCount)
  }
  pressKey("Esc")
  pressKey("a")
  pressKey("Space")
  pressKey("Space")
  sleep(525)
}

screenshotAugment(loopCount) {
  if (!screenshot) {
    return
  }
  sleep(1350) ; wait for the red sparkles to be gone
  if (screnshotCoordinates) {
    snap := Gdip_BitmapFromScreen(screnshotCoordinates)
  } else {
    WinGetPos, X, Y, W, H, %programName%
    X := X + 10
    Y := Y + 1
    W := W - 20
    H := H - 10
    coords := X . "|" . Y . "|" . W . "|" . H
    snap := Gdip_BitmapFromScreen(coords)
  }

  OutputDebug, Screenshot taken

  filename := Format("{}/{:1}-{:04}.png", screenshotsFolder,augmentOption, loopCount)
  Gdip_SaveBitmapToFile(snap, filename)

  Gdip_DisposeImage(snap)
}

pressKey(key, presstime:=65, sleepTime:=65) {
  OutputDebug, pressing: %key%
  send,{%key% Down}
  sleep(presstime)
  send,{%key% Up}
  sleep(sleepTime)
}

waitForBlackScreen(timeout:= 0) {
  WinGetPos, X, Y, W, H, %programName%
  y := Y + H/2
  x1 := X + 30
  x2 := x1 + W/8
  OutputDebug, "wait for black screen"
  WaitPixelColor(0x000000, x1, y, timeout)
  return WaitPixelColor(0x000000, x2, y, timeout)
}

printTime() {
  FormatTime, currentTime, %A_Now%, yyyy-MM-ddTHH:mm:ssZ
  OutputDebug, %currentTime%
}

focusWindow(windowName) {
  WinActivate, %windowName%
  sleep(333)
}

pause() {
  OutputDebug, Waiting to Unpause
  ToolTip, Waiting to Unpause,0,0
  Pause ; stops the script execution
}

beep() {
  if (!silent)
    SoundBeep
}

sleep(sleepTime) {
  totalSleep := sleepTime + extraSleepTime
  sleep, totalSleep
}

;;;;;;;;;;;;;;;;;;;
; Unused methods  ;
;;;;;;;;;;;;;;;;;;;
getPixelColor() {
  ; Read RGB color from pixel 
  ARGB := gdip_getpixel( snap, 0, 0 )
  RGB := ARGBtoRGB( ARGB )
  OutputDebug, %RGB%
  components := HexRGBtoComponents(RGB)
  if (components[1] > 10) { ; high red
    sleep(1050) ; wait for the red tint to go
    snap := Gdip_BitmapFromScreen(screnshotCoordinates) ;; 27' primary screen
  }
}

ARGBtoRGB( ARGB ) {
  setFormat, IntegerFast, hex
  ARGB := ARGB & 0x00ffffff
  ARGB .= "" ; Necessary due to the "fast" mode.
  setFormat, IntegerFast, d
  return ARGB
}

HexRGBtoComponents(RGB) {
  components := []
  noPrefix := SubStr(RGB, 3)
  OutputDebug, %noPrefix%
  if (StrLen(noPrefix) = 5) {
    noPrefix = 0%noPrefix%
  }
  OutputDebug, %noPrefix%
  red := SubStr(noPrefix, 1, 2)
  OutputDebug, red: %red%
  components.Push(red)
  green := SubStr(noPrefix, 3, 2)
  OutputDebug, green: %green%
  components.Push(green) ; green
  blue := SubStr(noPrefix, 5, 2)
  OutputDebug, blue: %blue%
  components.Push(blue) ; blue
  return components
}
;;;;;;;;;;;;;;;;;;;
; /Unused methods ;
;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;
; Mapped Hotkeys  ;
;;;;;;;;;;;;;;;;;;;
F10:: 
  exitScript()
return

MButton:: 
  exitScript()
return

exitScript() {
  send,{w Up}
  send,{a Up}
  send,{s Up}
  send,{d Up}
  send,{x Up}
  send,{Space Up}
  printTime()
ExitApp
}

; Key mapped to stop the script execution and to let it continue
Pause:: 
  Pause
  focusWindow(programName)
return 

;;;;;;;;;;;;;;;;;;;
; /Mapped Hotkeys ;
;;;;;;;;;;;;;;;;;;;
