// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/MapPrototype.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "JSCBuiltins.h"
#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex mapPrototypeTableIndex[2] = {
    { -1, -1 },
    { 0, -1 },
};

static const struct HashTableValue mapPrototypeTableValues[1] = {
   { "forEach", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(mapPrototypeForEachCodeGenerator), (intptr_t)0 } },
};

static const struct HashTable mapPrototypeTable =
    { 1, 1, false, mapPrototypeTableValues, mapPrototypeTableIndex };

} // namespace JSC
