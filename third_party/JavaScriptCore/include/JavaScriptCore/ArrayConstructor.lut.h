// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/ArrayConstructor.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "JSCBuiltins.h"
#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex arrayConstructorTableIndex[4] = {
    { -1, -1 },
    { -1, -1 },
    { 1, -1 },
    { 0, -1 },
};

static const struct HashTableValue arrayConstructorTableValues[2] = {
   { "of", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(arrayConstructorOfCodeGenerator), (intptr_t)0 } },
   { "from", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(arrayConstructorFromCodeGenerator), (intptr_t)0 } },
};

static const struct HashTable arrayConstructorTable =
    { 2, 3, false, arrayConstructorTableValues, arrayConstructorTableIndex };

} // namespace JSC
