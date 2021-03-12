// Automatically generated from /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/runtime/JSInternalPromiseConstructor.cpp using /Users/hejian/Downloads/dev_multi_process/Source/JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "JSCBuiltins.h"
#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex internalPromiseConstructorTableIndex[2] = {
    { 0, -1 },
    { -1, -1 },
};

static const struct HashTableValue internalPromiseConstructorTableValues[1] = {
   { "internalAll", ((DontEnum|Function) & ~Function) | Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(internalPromiseConstructorInternalAllCodeGenerator), (intptr_t)1 } },
};

static const struct HashTable internalPromiseConstructorTable =
    { 1, 1, false, internalPromiseConstructorTableValues, internalPromiseConstructorTableIndex };

} // namespace JSC
