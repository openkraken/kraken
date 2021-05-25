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
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#pragma once

#include <wtf/DumbPtrTraits.h>
#include <wtf/Gigacage.h>

namespace WTF {

template<Gigacage::Kind passedKind, typename T, typename PtrTraits = DumbPtrTraits<T>>
class CagedPtr {
public:
    static constexpr Gigacage::Kind kind = passedKind;

    CagedPtr() : CagedPtr(nullptr) { }
    CagedPtr(std::nullptr_t) : m_ptr(nullptr) { }

    explicit CagedPtr(T* ptr)
        : m_ptr(ptr)
    {
    }
    
    T* get() const
    {
        ASSERT(m_ptr);
        return Gigacage::caged(kind, PtrTraits::unwrap(m_ptr));
    }
    
    T* getMayBeNull() const
    {
        if (!m_ptr)
            return nullptr;
        return get();
    }

    CagedPtr& operator=(T* ptr)
    {
        m_ptr = ptr;
        return *this;
    }

    CagedPtr& operator=(T*&& ptr)
    {
        m_ptr = WTFMove(ptr);
        return *this;
    }

    bool operator==(const CagedPtr& other) const
    {
        return getMayBeNull() == other.getMayBeNull();
    }
    
    bool operator!=(const CagedPtr& other) const
    {
        return !(*this == other);
    }
    
    explicit operator bool() const
    {
        return *this != CagedPtr();
    }
    
    T& operator*() const { return *get(); }
    T* operator->() const { return get(); }

    template<typename IndexType>
    T& operator[](IndexType index) const { return get()[index]; }
    
protected:
    typename PtrTraits::StorageType m_ptr;
};

template<Gigacage::Kind passedKind, typename PtrTraits>
class CagedPtr<passedKind, void, PtrTraits> {
public:
    static constexpr Gigacage::Kind kind = passedKind;

    CagedPtr() : CagedPtr(nullptr) { }
    CagedPtr(std::nullptr_t) : m_ptr(nullptr) { }

    explicit CagedPtr(void* ptr)
        : m_ptr(ptr)
    {
    }
    
    void* get() const
    {
        ASSERT(m_ptr);
        return Gigacage::caged(kind, PtrTraits::unwrap(m_ptr));
    }
    
    void* getMayBeNull() const
    {
        if (!m_ptr)
            return nullptr;
        return get();
    }

    CagedPtr& operator=(void* ptr)
    {
        m_ptr = ptr;
        return *this;
    }

    bool operator==(const CagedPtr& other) const
    {
        return getMayBeNull() == other.getMayBeNull();
    }
    
    bool operator!=(const CagedPtr& other) const
    {
        return !(*this == other);
    }
    
    explicit operator bool() const
    {
        return *this != CagedPtr();
    }
    
protected:
    typename PtrTraits::StorageType m_ptr;
};

} // namespace WTF

using WTF::CagedPtr;

