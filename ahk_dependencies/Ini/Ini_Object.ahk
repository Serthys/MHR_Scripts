
; Version: 2023.04.20.1

class Ini_Object {

    ;#region Public

    Clone() {
        local
        name := ObjGetBase(this).__Class
        clone := new %name%()
        clone.__data := this.__data.Clone()
        return clone
    }

    Count() {
        return this.__data.Count()
    }

    Delete(Parameters*) {
        return this.__data.Delete(Parameters*)
    }

    GetAddress(Key) {
        return this.__data.GetAddress(Key)
    }

    GetCapacity(Parameters*) {
        return this.__data.GetCapacity(Parameters*)
    }

    HasKey(Key) {
        return this.__data.HasKey(Key)
    }

    Insert(_*) {
        throw Exception("Deprecated.", -1, A_ThisFunc)
    }

    InsertAt(Parameters*) {
        this.__data.InsertAt(Parameters*)
    }

    Length() {
        return this.__data.Length()
    }

    MaxIndex() {
        return this.__data.MaxIndex()
    }

    MinIndex() {
        return this.__data.MinIndex()
    }

    Pop() {
        return this.__data.Pop()
    }

    Push(Parameters*) {
        return this.__data.Push(Parameters*)
    }

    Remove(_*) {
        throw Exception("Deprecated.", -1, A_ThisFunc)
    }

    RemoveAt(Parameters*) {
        return this.__data.RemoveAt(Parameters*)
    }

    SetCapacity(Parameters*) {
        return this.__data.SetCapacity(Parameters*)
    }
    ;#endregion

    ;#region Private

    _NewEnum() {
        return this.__data._NewEnum()
    }
    ;#endregion

    ;#region Meta

    __Get(Parameters*) { ; Key[, Key...]
        return this.__data[Parameters*]
    }

    __Init() {
        ObjRawSet(this, "__data", {})
    }

    __Set(Parameters*) { ; Key, Value[, Value...]
        local
        value := Parameters.Pop()
        this.__data[Parameters*] := value
        return value
    }
    ;#endregion

}
