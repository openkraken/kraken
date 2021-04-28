/*
 * Copyright (C) 2013-2018 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

#pragma once

#include "FunctionExecutable.h"
#include "JSFunction.h"
#include "NativeExecutable.h"

namespace JSC {

inline JSFunction* JSFunction::createWithInvalidatedReallocationWatchpoint(
    VM& vm, FunctionExecutable* executable, JSScope* scope)
{
    ASSERT(executable->singleton().hasBeenInvalidated());
    return createImpl(vm, executable, scope, selectStructureForNewFuncExp(scope->globalObject(vm), executable));
}

inline JSFunction::JSFunction(VM& vm, FunctionExecutable* executable, JSScope* scope, Structure* structure)
    : Base(vm, scope, structure)
    , m_executable(vm, this, executable)
    , m_rareData()
{
    assertTypeInfoFlagInvariants();
}

inline FunctionExecutable* JSFunction::jsExecutable() const
{
    ASSERT(!isHostFunctionNonInline());
    return static_cast<FunctionExecutable*>(m_executable.get());
}

inline bool JSFunction::isHostFunction() const
{
    ASSERT(m_executable);
    return m_executable->isHostFunction();
}

inline Intrinsic JSFunction::intrinsic() const
{
    return executable()->intrinsic();
}

inline bool JSFunction::isBuiltinFunction() const
{
    return !isHostFunction() && jsExecutable()->isBuiltinFunction();
}

inline bool JSFunction::isAnonymousBuiltinFunction() const
{
    return !isHostFunction() && jsExecutable()->isAnonymousBuiltinFunction();
}

inline bool JSFunction::isHostOrBuiltinFunction() const
{
    return isHostFunction() || isBuiltinFunction();
}

inline bool JSFunction::isClassConstructorFunction() const
{
    return !isHostFunction() && jsExecutable()->isClassConstructorFunction();
}

inline TaggedNativeFunction JSFunction::nativeFunction()
{
    ASSERT(isHostFunctionNonInline());
    return static_cast<NativeExecutable*>(m_executable.get())->function();
}

inline TaggedNativeFunction JSFunction::nativeConstructor()
{
    ASSERT(isHostFunctionNonInline());
    return static_cast<NativeExecutable*>(m_executable.get())->constructor();
}

inline bool isHostFunction(JSValue value, TaggedNativeFunction nativeFunction)
{
    JSFunction* function = jsCast<JSFunction*>(getJSFunction(value));
    if (!function || !function->isHostFunction())
        return false;
    return function->nativeFunction() == nativeFunction;
}

inline bool JSFunction::hasReifiedLength() const
{
    return m_rareData ? m_rareData->hasReifiedLength() : false;
}

inline bool JSFunction::hasReifiedName() const
{
    return m_rareData ? m_rareData->hasReifiedName() : false;
}

inline bool JSFunction::canUseAllocationProfile()
{
    if (isHostOrBuiltinFunction()) {
        if (isHostFunction())
            return false;

        VM& vm = globalObject()->vm();
        unsigned attributes;
        JSValue prototype = getDirect(vm, vm.propertyNames->prototype, attributes);
        if (!prototype || (attributes & PropertyAttribute::AccessorOrCustomAccessorOrValue))
            return false;
    }

    // If we don't have a prototype property, we're not guaranteed it's
    // non-configurable. For example, user code can define the prototype
    // as a getter. JS semantics require that the getter is called every
    // time |construct| occurs with this function as new.target.
    return jsExecutable()->hasPrototypeProperty();
}

inline FunctionRareData* JSFunction::ensureRareDataAndAllocationProfile(ExecState* exec, unsigned inlineCapacity)
{
    ASSERT(canUseAllocationProfile());
    if (UNLIKELY(!m_rareData))
        return allocateAndInitializeRareData(exec, inlineCapacity);
    if (UNLIKELY(!m_rareData->isObjectAllocationProfileInitialized()))
        return initializeRareData(exec, inlineCapacity);
    return m_rareData.get();
}

} // namespace JSC
