; Use Scroll Lock to control keyboard
; and do not let Control, Alt, or Win modifiers act on Dvorak
#SingleInstance force
#Persistent
#UseHook On
#InstallKeybdHook

class KeyboardMapper {
	static NormalLayout := "``1234567890-=qwertyuiop[]asdfghjkl;'zxcvbnm,./"
	static ShiftLayout := "~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:""ZXCVBNM<>?"
	static KeysPerLayout := 46
	__New() {
		this.layouts := []
		this.currentLayout := ""
	}
	addLayout(layout){
		layout.validateLayout()
		this.layouts.Push(layout)
	}
	layoutNames(){
		names := []
		For index, value in this.layouts {
			names.Push(value.name)
		}
		return names
	}
	disableLayout(){
		this.currentLayout := ""
	}
	switchLayout(layoutName){
		this.currentLayout := ""
		For index, value in this.layouts {
			if(value.name == layoutName){
				this.currentLayout := value
				TrayTip, % "Layout Switched", % "Keyboard layout switched to " layoutName
			}
		}
	}
	mapKey(key, shift:=false){
		if(!this.currentLayout){
			return key
		}
		if(!shift){
			return this.mapKeyFromLayout(key, this.NormalLayout, this.currentLayout.normalLayout)
		} else {
			return this.mapKeyFromLayout(key, this.ShiftLayout, this.currentLayout.shiftLayout)
		}
	}
	mapKeyFromLayout(key, layout, toLayout){
		index := InStr(layout, key)
		return SubStr(toLayout, index, 1)
	}
	sendKey(key){
		IsShiftDown := GetKeyState("Shift")
		mappedKey := this.mapKey(key, IsShiftDown)
		SendRaw % mappedKey
	}
}

class KeyboardLayout {
	__New(name){
		this.name := name
	}
	setNormalLayout(layout){
		this.normalLayout := layout
	}
	setShiftLayout(layout){
		this.shiftLayout := layout
	}
	validateLayout(){
		if(StrLen(this.normalLayout) != KeyboardMapper.KeysPerLayout){
			MsgBox, % "Invalid Layout " this.normalLayout " must contain " KeyboardMapper.KeysPerLayout " characters"
			ExitApp
		}
		if(StrLen(this.shiftLayout) != KeyboardMapper.KeysPerLayout){
			MsgBox, % "Invalid Layout " this.normalLayout " must contain " KeyboardMapper.KeysPerLayout " characters"
			ExitApp
		}
	}
}

mapper := new KeyboardMapper()
dvorak := new KeyboardLayout("Dvorak")
dvorak.setNormalLayout("``1234567890-=',.pyfgcrl?+aoeuidhtns-/qjkxbmwvz")
dvorak.setShiftLayout("~!@#$%^&*()_+""<>PYFGCRL?+AOEUIDHTNS_:QJKXBMWVZ")
mapper.addLayout(dvorak)

pDvorak := new KeyboardLayout("Programmers Dvorak")
pDvorak.setNormalLayout("$&[{}(=*)+]!#;,.pyfgcrl/@aoeuidhtns-'qjkxbmwvz")
pDvorak.setShiftLayout("~%7531902468``:<>PYFGCRL?^AOEUIDHTNS_""QJKXBMWVZ")
mapper.addLayout(pDvorak)

mapper.disableLayout()

Menu, TRAY, Add
For index, value in mapper.layoutNames() {
	Menu, TRAY, Add, % value, OnSelectItem
}

normalKeys := "abcdefghijklmnopqrstuvwxyz"
specialKeys := "``1234567890-=~!@#$%^&*()_+[]{};':"",./<>?"

Loop, Parse, normalKeys
{
	Hotkey, %A_LoopField%, OnKeyPress
	Hotkey, +%A_LoopField%, OnUpperKeyPress
}
Loop, Parse, specialKeys
{
	Hotkey, %A_LoopField%, OnKeyPress
}

return

OnSelectItem(ItemName, ItemPos, MenuName){
	mapper.switchLayout(ItemName)
}

OnKeyPress:
	mapper.sendKey(A_ThisHotkey)
return

OnUpperKeyPress:
	key := SubStr(A_ThisHotkey, 2, 1)
	StringUpper, key, key
	mapper.sendKey(key)
return

F1::
	mapper.disableLayout()
return
F2::
	mapper.switchLayout("Dvorak")
return
F3::
	mapper.switchLayout("Programmers Dvorak")
return