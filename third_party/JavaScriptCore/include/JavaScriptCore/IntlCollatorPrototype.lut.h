// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/IntlCollatorPrototype.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex collatorPrototypeTableIndex[4] = {
    { 0, -1 },
    { -1, -1 },
    { -1, -1 },
    { 1, -1 },
};

static const struct HashTableValue collatorPrototypeTableValues[2] = {
   { "compare", DontEnum|Accessor, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(IntlCollatorPrototypeGetterCompare), (intptr_t)static_cast<NativeFunction>(nullptr) } },
   { "resolvedOptions", DontEnum|Function, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(IntlCollatorPrototypeFuncResolvedOptions), (intptr_t)(0) } },
};

static const struct HashTable collatorPrototypeTable =
    { 2, 3, true, collatorPrototypeTableValues, collatorPrototypeTableIndex };

} // namespace JSC
