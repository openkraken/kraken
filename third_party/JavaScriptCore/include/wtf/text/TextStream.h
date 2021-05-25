/*
 * Copyright (C) 2004, 2008 Apple Inc. All rights reserved.
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

#include <wtf/Forward.h>
#include <wtf/text/StringBuilder.h>

namespace WTF {

class TextStream {
public:
    struct FormatNumberRespectingIntegers {
        FormatNumberRespectingIntegers(double number)
            : value(number) { }

        double value;
    };
    
    enum Formatting {
        SVGStyleRect                = 1 << 0, // "at (0,0) size 10x10"
        NumberRespectingIntegers    = 1 << 1,
        LayoutUnitsAsIntegers       = 1 << 2,
    };
    
    using FormattingFlags = unsigned;
    
    enum class LineMode { SingleLine, MultipleLine };
    TextStream(LineMode lineMode = LineMode::MultipleLine, FormattingFlags formattingFlags = 0)
        : m_formattingFlags(formattingFlags)
        , m_multiLineMode(lineMode == LineMode::MultipleLine)
    {
    }

    WTF_EXPORT_PRIVATE TextStream& operator<<(bool);
    WTF_EXPORT_PRIVATE TextStream& operator<<(int);
    WTF_EXPORT_PRIVATE TextStream& operator<<(unsigned);
    WTF_EXPORT_PRIVATE TextStream& operator<<(long);
    WTF_EXPORT_PRIVATE TextStream& operator<<(unsigned long);
    WTF_EXPORT_PRIVATE TextStream& operator<<(long long);

    WTF_EXPORT_PRIVATE TextStream& operator<<(unsigned long long);
    WTF_EXPORT_PRIVATE TextStream& operator<<(float);
    WTF_EXPORT_PRIVATE TextStream& operator<<(double);
    WTF_EXPORT_PRIVATE TextStream& operator<<(const char*);
    WTF_EXPORT_PRIVATE TextStream& operator<<(const void*);
    WTF_EXPORT_PRIVATE TextStream& operator<<(const String&);
    // Deprecated. Use the NumberRespectingIntegers FormattingFlag instead.
    WTF_EXPORT_PRIVATE TextStream& operator<<(const FormatNumberRespectingIntegers&);

    FormattingFlags formattingFlags() const { return m_formattingFlags; }
    void setFormattingFlags(FormattingFlags flags) { m_formattingFlags = flags; }

    bool hasFormattingFlag(Formatting flag) const { return m_formattingFlags & flag; }

    template<typename T>
    void dumpProperty(const String& name, const T& value)
    {
        TextStream& ts = *this;
        ts.startGroup();
        ts << name << " " << value;
        ts.endGroup();
    }

    WTF_EXPORT_PRIVATE String release();
    
    WTF_EXPORT_PRIVATE void startGroup();
    WTF_EXPORT_PRIVATE void endGroup();
    WTF_EXPORT_PRIVATE void nextLine(); // Output newline and indent.

    int indent() const { return m_indent; }
    void increaseIndent(int amount = 1) { m_indent += amount; }
    void decreaseIndent(int amount = 1) { m_indent -= amount; ASSERT(m_indent >= 0); }

    WTF_EXPORT_PRIVATE void writeIndent();

    // Stream manipulators.
    TextStream& operator<<(TextStream& (*func)(TextStream&))
    {
        return (*func)(*this);
    }

    class IndentScope {
    public:
        IndentScope(TextStream& ts, int amount = 1)
            : m_stream(ts)
            , m_amount(amount)
        {
            m_stream.increaseIndent(m_amount);
        }
        ~IndentScope()
        {
            m_stream.decreaseIndent(m_amount);
        }

    private:
        TextStream& m_stream;
        int m_amount;
    };

    class GroupScope {
    public:
        GroupScope(TextStream& ts)
            : m_stream(ts)
        {
            m_stream.startGroup();
        }
        ~GroupScope()
        {
            m_stream.endGroup();
        }

    private:
        TextStream& m_stream;
    };

private:
    StringBuilder m_text;
    FormattingFlags m_formattingFlags { 0 };
    int m_indent { 0 };
    bool m_multiLineMode { true };
};

inline TextStream& indent(TextStream& ts)
{
    ts.writeIndent();
    return ts;
}

template<typename Item>
TextStream& operator<<(TextStream& ts, const Vector<Item>& vector)
{
    ts << "[";

    unsigned size = vector.size();
    for (unsigned i = 0; i < size; ++i) {
        ts << vector[i];
        if (i < size - 1)
            ts << ", ";
    }

    return ts << "]";
}

// Deprecated. Use TextStream::writeIndent() instead.
WTF_EXPORT_PRIVATE void writeIndent(TextStream&, int indent);

} // namespace WTF

using WTF::TextStream;
using WTF::indent;
