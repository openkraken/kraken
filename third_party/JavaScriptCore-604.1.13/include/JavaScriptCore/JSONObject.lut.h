// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/JSONObject.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex jsonTableIndex[4] = {
    { -1, -1 },
    { 0, -1 },
    { -1, -1 },
    { 1, -1 },
};

static const struct HashTableValue jsonTableValues[2] = {
   { "parse", DontEnum|Function, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(JSONProtoFuncParse), (intptr_t)(2) } },
   { "stringify", DontEnum|Function, NoIntrinsic, { (intptr_t)static_cast<NativeFunction>(JSONProtoFuncStringify), (intptr_t)(3) } },
};

static const struct HashTable jsonTable =
    { 2, 3, false, jsonTableValues, jsonTableIndex };

} // namespace JSC
