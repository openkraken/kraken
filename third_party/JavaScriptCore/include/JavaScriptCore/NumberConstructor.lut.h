// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/NumberConstructor.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "JSCBuiltins.h"
#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex numberConstructorTableIndex[16] = {
    { 4, -1 },
    { -1, -1 },
    { -1, -1 },
    { -1, -1 },
    { -1, -1 },
    { 2, -1 },
    { -1, -1 },
    { -1, -1 },
    { -1, -1 },
    { 3, -1 },
    { -1, -1 },
    { 0, -1 },
    { -1, -1 },
    { 1, -1 },
    { -1, -1 },
    { -1, -1 },
};

static const struct HashTableValue numberConstructorTableValues[5] = {
   { "isFinite", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(numberConstructorIsFiniteCodeGenerator), (intptr_t)1 } },
   { "isInteger", DontEnum|Function, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(numberConstructorFuncIsInteger), (intptr_t)(1) } },
   { "isNaN", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(numberConstructorIsNaNCodeGenerator), (intptr_t)1 } },
   { "isSafeInteger", DontEnum|Function, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(numberConstructorFuncIsSafeInteger), (intptr_t)(1) } },
   { "parseFloat", DontEnum|Function, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(globalFuncParseFloat), (intptr_t)(1) } },
};

static const struct HashTable numberConstructorTable =
    { 5, 15, false, numberConstructorTableValues, numberConstructorTableIndex };

} // namespace JSC
