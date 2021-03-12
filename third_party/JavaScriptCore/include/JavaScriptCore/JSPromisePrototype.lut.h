// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/JSPromisePrototype.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "JSCBuiltins.h"
#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex promisePrototypeTableIndex[4] = {
    { 0, -1 },
    { -1, -1 },
    { -1, -1 },
    { 1, -1 },
};

static const struct HashTableValue promisePrototypeTableValues[2] = {
   { "then", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(promisePrototypeThenCodeGenerator), (intptr_t)2 } },
   { "catch", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(promisePrototypeCatchCodeGenerator), (intptr_t)1 } },
};

static const struct HashTable promisePrototypeTable =
    { 2, 3, false, promisePrototypeTableValues, promisePrototypeTableIndex };

} // namespace JSC
