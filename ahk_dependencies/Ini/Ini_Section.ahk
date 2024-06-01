
; Version: 2023.04.20.1

class Ini_Section extends Ini_File.Ini_Object {

    ;#region Public

    Persist() {
        local
        IniRead buffer, % this.__path, % this.__name
        keys := {}
        for _, key in StrSplit(buffer, "`n") {
            key := StrSplit(key, "=")[1]
            keys[key] := true
        }
        for key, value in this {
            keys.Delete(key)
            value := value = "" ? "" : " " value
            IniWrite % value, % this.__path, % this.__name, % key
        }
        for key in keys
            IniDelete % this.__path, % this.__name, % key
    }

    Sync(Set := "") {
        if (Set = "")
            return this.__sync
        return this.__sync := !!Set
    }
    ;#endregion

    ;#region Overload

    Delete(Key) {
        if (this.__sync)
            IniDelete % this.__path, % this.__name, % Key
    }
    ;#endregion

    ;#region Meta

    __New(Path, Name, Data, Sync := false) {
        local
        ObjRawSet(this, "__path", Path)
        ObjRawSet(this, "__name", Name)
        ObjRawSet(this, "__sync", Sync)
        if (!IsObject(Data))
            Ini_ToObject(Data)
        for key, value in Data
            this[key] := value
    }

    __Set(Key, Value) {
        if (this.__sync && Value != this.__data[Key]) {
            Value := Value = "" ? "" : " " Value
            IniWrite % Value, % this.__path, % this.__name, % Key
        }
    }
    ;#endregion

}
