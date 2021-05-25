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

#include "BInline.h"
#include "EligibilityResult.h"
#include "IsoAllocator.h"
#include "IsoHeapImpl.h"
#include "IsoPage.h"

namespace bmalloc {

template<typename Config>
IsoAllocator<Config>::IsoAllocator(IsoHeapImpl<Config>& heap)
    : m_heap(&heap)
{
}

template<typename Config>
IsoAllocator<Config>::~IsoAllocator()
{
}

template<typename Config>
void* IsoAllocator<Config>::allocate(bool abortOnFailure)
{
    static constexpr bool verbose = false;
    void* result = m_freeList.allocate<Config>(
        [&] () -> void* {
            return allocateSlow(abortOnFailure);
        });
    if (verbose)
        fprintf(stderr, "%p: allocated %p of size %u\n", m_heap, result, Config::objectSize);
    return result;
}

template<typename Config>
BNO_INLINE void* IsoAllocator<Config>::allocateSlow(bool abortOnFailure)
{
    std::lock_guard<Mutex> locker(m_heap->lock);
    
    EligibilityResult<Config> result = m_heap->takeFirstEligible();
    if (result.kind != EligibilityKind::Success) {
        RELEASE_BASSERT(result.kind == EligibilityKind::OutOfMemory);
        RELEASE_BASSERT(!abortOnFailure);
        return nullptr;
    }
    
    if (m_currentPage)
        m_currentPage->stopAllocating(m_freeList);
    
    m_currentPage = result.page;
    m_freeList = m_currentPage->startAllocating();
    
    return m_freeList.allocate<Config>([] () { BCRASH(); return nullptr; });
}

template<typename Config>
void IsoAllocator<Config>::scavenge()
{
    if (m_currentPage) {
        std::lock_guard<Mutex> locker(m_heap->lock);
        m_currentPage->stopAllocating(m_freeList);
        m_currentPage = nullptr;
        m_freeList.clear();
    }
}

} // namespace bmalloc

