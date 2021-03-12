// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/StringConstructor.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "JSCBuiltins.h"
#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex stringConstructorTableIndex[8] = {
    { -1, -1 },
    { 2, -1 },
    { -1, -1 },
    { -1, -1 },
    { 1, -1 },
    { -1, -1 },
    { -1, -1 },
    { 0, -1 },
};

static const struct HashTableValue stringConstructorTableValues[3] = {
   { "fromCharCode", DontEnum|Function, FromCharCodeIntrinsic, { (intptr_t)static_cast<NativeFunction>(stringFromCharCode), (intptr_t)(1) } },
   { "fromCodePoint", DontEnum|Function, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(stringFromCodePoint), (intptr_t)(1) } },
   { "raw", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(stringConstructorRawCodeGenerator), (intptr_t)1 } },
};

static const struct HashTable stringConstructorTable =
    { 3, 7, false, stringConstructorTableValues, stringConstructorTableIndex };

} // namespace JSC
