;;;;;;;;;
; DOCS  ;
;;;;;;;;;
; This script will save the game (if `save` is enabled), travel to the Kamura blacksmith and roll the selected augment option (`craftingOption`) on the first 
; piece of equipment (leave only one equipped for consistency) for the amount of times defined (`initialMaxLoops`) and pause the script execution. After that
; you can check the screenshots taken and:
; - If you want any augment just go to "Return To title Screen" -> "No" -> "Yes" to quit without saving and go back in, the augment order will be the same.
; - If you don't want any augment just with the `Pause` key to let it continue.

; Notes: 
; Disable the automatic save on: Options -> Save Data -> Autosave Settings -> Off, otherwise the game will save after closing the blacksmith menu.
; The sleep times are hardcoded for my system so you might need to change a few of them manually.
; I tested the screenshots working on 800x600 and 1440x1080, other resultions might have different results.
;;;;;;;;;
; /DOCS ;
;;;;;;;;;

#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir% ; use the running script directory

;;;;;;;;;;;;;;;;;
; DEPENDENCIES  ;
;;;;;;;;;;;;;;;;;
; dependency for waiting for pixel color, used to wait for black screens
#Include WaitPixelColor.ahk
; dependency for screenshots
#Include Gdip_All.ahk
;;;;;;;;;;;;;;;;;
; /DEPENDENCIES ;
;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;
; Variables to modify  ;
;;;;;;;;;;;;;;;;;;;;;;;;
; global manual := true ; uncomment for the script to stop for every augment
; global silent := true ; set to true to skip the beeps
global initialMaxLoops := 1 ; augments to roll
global save := true ; to save before rolling the augments
global screenshot := true ; comment when comming back to skips augments until the one desired
global screenshotsFolder := "Screenshots" ; folder to export the screenshots to

; Leave commented for a full window screenshot, uncomment to crop it
global screnshotCoordinates := "749|182|426|727" ; x, y, width, height
; global screnshotCoordinates := "749|182|426|727" ; 27', first monitor
; global screnshotCoordinates := "-1171|182|426|727" ; 27', left monitor
; global screnshotCoordinates := "-1563|-128|571|973" ; 24', left monitor

; Uncomment only one of these at the time
global craftingOption := 0 ; Normal, wear only "Valstrax Graves - Eclipse" for better OCR
; global craftingOption := 2 ; Skills+, wear only "Pride Vambraces" for better OCR
; global craftingOption := 3 ; Slots+
;;;;;;;;;;;;;;;;;;;;;;;;
; /Variables to modify ;
;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PROGRAM INITIALIZATION  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Window name to change focus
global programName := "Monster Hunter Rise"
pause()
pToken := Gdip_Startup()
focusWindow(programName)
ToolTip,Loops done: %0%/%initialMaxLoops%,0,0
printTime()
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
    if(!manual && save) {
      save()
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
  maxLoops := initialMaxLoops ; reset loop counter if the augmenting continues
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
  OutputDebug, fastTravelToArlow
  sleep, 50 ; wait for UI update
  pressKey("m") ; open travel menu
  sleep, 50 ; wait for UI update
  pressKey("Space") ; press Market
  sleep, 1 ; wait for UI update
  waitForBlackScreen() ; wait for black screen
  sleep, 100 ; wait for UI update
  pressKey("a", 1450) ; move toward Arlow
  pressKey("w", 1500) ; face Arlow
  sleep, 50 ; wait to face Arlow
}

exitMenu() {
  OutputDebug, exitMenu
  pressKey("Esc") ;
  sleep, 400 ; wait for UI update
  pressKey("Esc") ;
  sleep, 400 ; wait for UI update
  pressKey("Esc") ;
  sleep, 400 ; wait for UI update
  pressKey("Esc") ;
  sleep, 2500 ; wait for UI update
}

save() {
  OutputDebug, save
  pressKey("Esc") ;
  sleep, 500 ; wait for UI update
  pressKey("Left") ;
  sleep, 66 ; wait for UI update
  pressKey("Down") ;
  sleep, 66 ; wait for UI update
  pressKey("Down") ;
  sleep, 66 ; wait for UI update
  pressKey("Down") ;
  sleep, 250 ; wait for UI update
  pressKey("Space") ; press Confirm
  sleep, 250 ; wait for UI update
  pressKey("Left") ; move to Yes
  sleep, 250 ; wait for UI update
  pressKey("Space") ; press Yes
  sleep, 4500 ; wait for UI update
}

startAugmentMenu() {
  OutputDebug, startaugmentMenu
  pressKey("f") ;
  sleep, 1500 ; wait for UI update
  pressKey("Down") ;
  sleep, 100 ; wait for UI update
  pressKey("Down") ;
  sleep, 100 ; wait for UI update
  pressKey("Down") ;
  sleep, 100 ; wait for UI update
  pressKey("Space") ; press Qurious Armor crafting
  sleep, 200 ; wait for UI update
  pressKey("Space") ; select the first one
  sleep, 200 ; wait for UI update

  if (craftingOption = 2) { ; for Skills+
    pressKey("Down") ; down to Augment: Stability
    sleep, 200 ; wait for UI update
    pressKey("Down") ; down to Augment: Skills+
    sleep, 200 ; wait for UI update
  }
  if (craftingOption = 3) { ; for Skills+
    pressKey("Down") ; down to Augment: Stability
    sleep, 200 ; wait for UI update
    pressKey("Down") ; down to Augment: Skills+
    sleep, 200 ; wait for UI update
    pressKey("Down") ; down to Augment: Slots+
    sleep, 200 ; wait for UI update
  }

  pressKey("Space") ; press the selected option
  sleep, 200 ; wait for UI update
}

augmentArmor(loopCount) {
  pressKey("x") ; autoselect materials
  sleep, 150 ; wait for UI update
  pressKey("Space") ; press Confirm
  sleep, 225 ; wait for UI update
  pressKey("Space") ; press Yes
  if (waitForBlackScreen(5000) = 2) { ; wait for black screen
    OutputDebug, Black screen not found
    beep()
    beep()
    pause()
  }
  sleep, 425
  if (manual) {
    pause()
  } else {
    screenshotAugment(loopCount)
  }
  pressKey("Esc")
  pressKey("a")
  pressKey("Space")
  pressKey("Space")
  sleep, 525
}

screenshotAugment(loopCount) {
  if (!screenshot) {
    return
  }
  sleep, 1350 ; wait for the red sparkles to be gone
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

  filename := Format("{}/{:1}-{:04}.png", screenshotsFolder,craftingOption, loopCount)
  Gdip_SaveBitmapToFile(snap, filename)

  Gdip_DisposeImage(snap)
}

pressKey(key, presstime:=65, sleepTime:=65) {
  OutputDebug, pressing: %key%
  send,{%key% Down}
  sleep, presstime
  send,{%key% Up}
  sleep, sleepTime
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
  sleep, 333
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
    sleep, 1050 ; wait for the red tint to go
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
MButton::
  send,{w Up}
  send,{a Up}
  send,{s Up}
  send,{d Up}
  send,{x Up}
  send,{Space Up}
  printTime()
ExitApp ; exit the script with mouse wheel click at any time

; Key mapped to stop the script execution and to let it continue
Pause::
  Pause
  focusWindow(programName)
  ;;;;;;;;;;;;;;;;;;;
  ; /Mapped Hotkeys ;
  ;;;;;;;;;;;;;;;;;;;