/*
 * Copyright (C) 2016-2018 Apple Inc. All rights reserved.
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

#include "CatchScope.h"
#include "StackAlignment.h"
#include "VM.h"

namespace JSC {

struct EntryFrame;

class SuspendExceptionScope {
public:
    SuspendExceptionScope(VM* vm)
        : m_vm(vm)
    {
        auto scope = DECLARE_CATCH_SCOPE(*vm);
        oldException = scope.exception();
        scope.clearException();
    }
    ~SuspendExceptionScope()
    {
        m_vm->restorePreviousException(oldException);
    }
private:
    Exception* oldException;
    VM* m_vm;
};

class TopCallFrameSetter {
public:
    TopCallFrameSetter(VM& currentVM, CallFrame* callFrame)
        : vm(currentVM)
        , oldCallFrame(currentVM.topCallFrame)
    {
        currentVM.topCallFrame = callFrame;
    }

    ~TopCallFrameSetter()
    {
        vm.topCallFrame = oldCallFrame;
    }
private:
    VM& vm;
    CallFrame* oldCallFrame;
};

ALWAYS_INLINE static void assertStackPointerIsAligned()
{
#ifndef NDEBUG
#if CPU(X86) && !OS(WINDOWS)
    uintptr_t stackPointer;

    asm("movl %%esp,%0" : "=r"(stackPointer));
    ASSERT(!(stackPointer % stackAlignmentBytes()));
#endif
#endif
}

class NativeCallFrameTracer {
public:
    ALWAYS_INLINE NativeCallFrameTracer(VM* vm, CallFrame* callFrame)
    {
        ASSERT(vm);
        ASSERT(callFrame);
        ASSERT(reinterpret_cast<void*>(callFrame) < reinterpret_cast<void*>(vm->topEntryFrame));
        assertStackPointerIsAligned();
        vm->topCallFrame = callFrame;
    }
};

} // namespace JSC
