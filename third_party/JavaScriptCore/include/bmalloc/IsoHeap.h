/*
 * Copyright (C) 2017 Apple Inc. All rights reserved.
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

#include "IsoConfig.h"
#include "Mutex.h"

namespace bmalloc {

template<typename Config> class IsoHeapImpl;

namespace api {

// You have to declare IsoHeaps this way:
//
// static IsoHeap<type> myTypeHeap;
//
// It's not valid to create an IsoHeap except in static storage.

template<typename Type>
struct IsoHeap {
    typedef IsoConfig<sizeof(Type)> Config;
    
    void* allocate();
    void* tryAllocate();
    void deallocate(void* p);
    
    void scavenge();
    
    bool isInitialized();
    
    unsigned allocatorOffset() { return m_allocatorOffsetPlusOne - 1; }
    void setAllocatorOffset(unsigned value) { m_allocatorOffsetPlusOne = value + 1; }
    
    unsigned deallocatorOffset() { return m_deallocatorOffsetPlusOne - 1; }
    void setDeallocatorOffset(unsigned value) { m_deallocatorOffsetPlusOne = value + 1; }
    
    IsoHeapImpl<Config>& impl();
    
    Mutex m_initializationLock;
    unsigned m_allocatorOffsetPlusOne;
    unsigned m_deallocatorOffsetPlusOne;
    IsoHeapImpl<Config>* m_impl;
};

// Use this together with MAKE_BISO_MALLOCED_IMPL.
#define MAKE_BISO_MALLOCED(isoType) \
public: \
    static ::bmalloc::api::IsoHeap<isoType>& bisoHeap(); \
    \
    void* operator new(size_t, void* p) { return p; } \
    void* operator new[](size_t, void* p) { return p; } \
    \
    void* operator new(size_t size);\
    void operator delete(void* p);\
    \
    void* operator new[](size_t size) = delete; \
    void operator delete[](void* p) = delete; \
private: \
typedef int __makeBisoMallocedMacroSemicolonifier

} } // namespace bmalloc::api
