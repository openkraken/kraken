// Automatically generated from JavaScriptCore/runtime/GeneratorPrototype.cpp using JavaScriptCore/create_hash_table. DO NOT EDIT!

#include "JSCBuiltins.h"
#include "Lookup.h"

namespace JSC {

static const struct CompactHashIndex generatorPrototypeTableIndex[8] = {
    { -1, -1 },
    { 0, -1 },
    { -1, -1 },
    { -1, -1 },
    { -1, -1 },
    { -1, -1 },
    { 2, -1 },
    { 1, -1 },
};

static const struct HashTableValue generatorPrototypeTableValues[3] = {
   { "next", ((static_cast<unsigned>(PropertyAttribute::DontEnum|PropertyAttribute::Function)) & ~PropertyAttribute::Function) | PropertyAttribute::Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(generatorPrototypeNextCodeGenerator), (intptr_t)1 } },
   { "return", ((static_cast<unsigned>(PropertyAttribute::DontEnum|PropertyAttribute::Function)) & ~PropertyAttribute::Function) | PropertyAttribute::Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(generatorPrototypeReturnCodeGenerator), (intptr_t)1 } },
   { "throw", ((static_cast<unsigned>(PropertyAttribute::DontEnum|PropertyAttribute::Function)) & ~PropertyAttribute::Function) | PropertyAttribute::Builtin, NoIntrinsic, { (intptr_t)static_cast<BuiltinGenerator>(generatorPrototypeThrowCodeGenerator), (intptr_t)1 } },
};

static const struct HashTable generatorPrototypeTable =
    { 3, 7, false, nullptr, generatorPrototypeTableValues, generatorPrototypeTableIndex };

} // namespace JSC
