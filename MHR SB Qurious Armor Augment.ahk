#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

if not A_IsAdmin
{
  ToolTip, Must run the scrip as Admin,0,0
  sleep 5000
  ExitApp
}
#Include WaitPixelColor.ahk
#Include Gdip_All.ahk

global programName := "Monster Hunter Rise"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unpause on the Select material screen after selecting the item and Augment method
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; OutputDebug, Waiting to Unpause
; ToolTip, Waiting to Unpause,0,0
; Pause
pToken := Gdip_Startup()
focusWindow()

; Overrides all config
; global manual := true
;;;;;;;;;;;;;;;;;;;;;;
global initialMaxLoops := 109
global save := true
global screenshot := true
global craftingOption := 0 ; Normal
; global craftingOption := 2 ; Skills+
; global craftingOption := 3 ; Slots+

ToolTip,Loops done: %0%/%initialMaxLoops%,0,0
printTime()
fastTravelToBlacksmith()
Loop {
  if(!manual && save) {
    save()
  }
  if(!manual) {
    startAugmentMenu()
  }
  main()
  Pause
  exitMenu()
}

main() {
  loopCount := 0
  maxLoops := initialMaxLoops
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
      SoundBeep
      SoundBeep
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
  sleep, 50 ; wait for UI update
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
  if waitForBlackScreen(30000) = 2 { ; wait for black screen
    OutputDebug, Black screen not found
    SoundBeep
    SoundBeep
    Pause
  }
  sleep, 425
  if (manual) {
    Pause
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
  sleep, 1350 ; wait for sparkles to be gone
  ; snap := Gdip_BitmapFromScreen("-1563|-128|571|973") ;; 24'
  ; snap := Gdip_BitmapFromScreen("-1171|182|426|727") ;; 27'
  snap := Gdip_BitmapFromScreen("749|182|426|727") ;; 27' primary screen
  OutputDebug, Screenshot taken

  ; Read RGB color from pixel 
  ; ARGB := gdip_getpixel( snap, 0, 0 )
  ; RGB := ARGBtoRGB( ARGB )
  ; OutputDebug, %RGB%
  ; components := HexRGBtoComponents(RGB)
  ; if (components[1] > 10) { ; high red
  ;   sleep, 1050 ; wait for the red tint to go
  ;   snap := Gdip_BitmapFromScreen("749|182|426|727") ;; 27' primary screen
  ; }

  filename := Format("Screenshots/{:1}-{:04}.png", craftingOption, loopCount)
  Gdip_SaveBitmapToFile(snap, filename)

  Gdip_DisposeImage(snap)
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

pressKey(key, presstime:=65, sleepTime:=65) {
  OutputDebug, pressing: %key%
  send,{%key% Down}
  sleep, presstime
  send,{%key% Up}
  sleep, sleepTime
}

waitForBlackScreen(time:= 0) {
  OutputDebug, "wait for black screen"
  WaitPixelColor(0x000000, 500, 500, time)
  return WaitPixelColor(0x000000, 1000, 500, time)
}

printTime() {
  FormatTime, currentTime, %A_Now%, yyyy-MM-ddTHH:mm:ssZ
  OutputDebug, %currentTime%
}

focusWindow() {
  WinActivate, %programName%
  sleep, 333
}

MButton::
  send,{w Up}
  send,{a Up}
  send,{s Up}
  send,{d Up}
  send,{x Up}
  send,{Space Up}
  printTime()
ExitApp ; exit the script with mouse wheel click at any time

Pause::
  Pause
  focusWindow()