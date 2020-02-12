// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/JSPromiseConstructor.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "JSCBuiltins.h"
#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex promiseConstructorTableIndex[9] = {
    { 2, -1 },
    { -1, -1 },
    { 0, 8 },
    { -1, -1 },
    { -1, -1 },
    { 1, -1 },
    { -1, -1 },
    { -1, -1 },
    { 3, -1 },
};

static const struct HashTableValue promiseConstructorTableValues[4] = {
   { "resolve", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(promiseConstructorResolveCodeGenerator), (intptr_t)1 } },
   { "reject", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(promiseConstructorRejectCodeGenerator), (intptr_t)1 } },
   { "race", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(promiseConstructorRaceCodeGenerator), (intptr_t)1 } },
   { "all", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(promiseConstructorAllCodeGenerator), (intptr_t)1 } },
};

static const struct HashTable promiseConstructorTable =
    { 4, 7, false, promiseConstructorTableValues, promiseConstructorTableIndex };

} // namespace JSC
