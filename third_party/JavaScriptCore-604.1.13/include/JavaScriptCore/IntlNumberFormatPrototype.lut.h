// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/IntlNumberFormatPrototype.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex numberFormatPrototypeTableIndex[4] = {
    { -1, -1 },
    { 0, -1 },
    { -1, -1 },
    { 1, -1 },
};

static const struct HashTableValue numberFormatPrototypeTableValues[2] = {
   { "format", DontEnum|Accessor, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(IntlNumberFormatPrototypeGetterFormat), (intptr_t)static_cast<NativeFunction>(nullptr) } },
   { "resolvedOptions", DontEnum|Function, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(IntlNumberFormatPrototypeFuncResolvedOptions), (intptr_t)(0) } },
};

static const struct HashTable numberFormatPrototypeTable =
    { 2, 3, true, numberFormatPrototypeTableValues, numberFormatPrototypeTableIndex };

} // namespace JSC
