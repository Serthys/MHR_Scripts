
; Version: 2023.04.20.1
; Usages and examples: https://redd.it/s1it4j

Ini(Path, Sync := true) {
    return new Ini_File(Path, Sync)
}

class Ini_File {

    ;#region Public

    Persist() {
        local
        IniRead buffer, % this.__path
        sections := {}
        for _, name in StrSplit(buffer, "`n")
            sections[name] := true
        for name in this.__data {
            this[name].Persist()
            sections.Delete(name)
        }
        for name in sections
            IniDelete % this.__path, % name
    }

    Sync(Set := "") {
        local
        if (Set = "")
            return this.__sync
        Set := !!Set
        for name in this
            this[name].Sync(Set)
        return this.__sync := Set
    }
    ;#endregion

    ;#region Overload

    Delete(Name) {
        if (this.__sync)
            IniDelete % this.__path, % Name
    }
    ;#endregion

    ;#region Meta

    __New(Path, Sync) {
        local
        ObjRawSet(this, "__path", Path)
        ObjRawSet(this, "__sync", false)
        IniRead buffer, % Path
        for _, name in StrSplit(buffer, "`n") {
            IniRead conts, % Path, % name
            this[name] := new this.Ini_Section(Path, name, conts)
        }
        this.Sync(Sync)
    }

    __Set(Key, Value) {
        local
        isObj := IsObject(Value)
        base := isObj ? ObjGetBase(Value) : false
        if (isObj && !base)
        || (base && base.__Class != "Ini_File.Ini_Section") {
            path := this.__path
            sync := this.__sync
            this[Key] := new Ini_File.Ini_Section(path, Key, Value, sync)
            return obj ; Stop, hammer time!
        }
    }
    ;#endregion

    #Include %A_LineFile%\..\Ini_Object.ahk
    #Include %A_LineFile%\..\Ini_Section.ahk

}

;#region Auxiliary

Ini_ToObject(ByRef Data) {
    local
    info := Data, Data := {}
    for _, pair in StrSplit(info, "`n") {
        pair := StrSplit(pair, "=",, 2)
        Data[pair[1]] := pair[2]
    }
}
;#endregion
