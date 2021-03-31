/*
 * Copyright (C) 2020 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKEN_DEBUGGER_MAYBE_H
#define KRAKEN_DEBUGGER_MAYBE_H

#define IP_NOEXCEPT noexcept

#include <memory>
#include <string>

namespace kraken {
namespace debugger {
template <typename T> class Maybe {
public:
  Maybe() : m_value() {}
  Maybe(std::unique_ptr<T> value) : m_value(std::move(value)) {}
  Maybe(Maybe &&other) IP_NOEXCEPT : m_value(std::move(other.m_value)) {}

  void operator=(std::unique_ptr<T> value) {
    m_value = std::move(value);
  }
  T *fromJust() const {
    return m_value.get();
  }
  T *fromMaybe(T *defaultValue) const {
    return m_value ? m_value.get() : defaultValue;
  }
  bool isJust() const {
    return !!m_value;
  }
  std::unique_ptr<T> takeJust() {
    return std::move(m_value);
  }

private:
  std::unique_ptr<T> m_value;
};

template <typename T> class MaybeBase {
public:
  MaybeBase() : m_isJust(false) {}
  MaybeBase(T value) : m_isJust(true), m_value(value) {}
  MaybeBase(MaybeBase &&other) IP_NOEXCEPT : m_isJust(other.m_isJust), m_value(std::move(other.m_value)) {}
  void operator=(T value) {
    m_value = value;
    m_isJust = true;
  }
  T fromJust() const {
    return m_value;
  }
  T fromMaybe(const T &defaultValue) const {
    return m_isJust ? m_value : defaultValue;
  }
  bool isJust() const {
    return m_isJust;
  }
  T takeJust() {
    return m_value;
  }

protected:
  bool m_isJust;
  T m_value;
};

template <> class Maybe<bool> : public MaybeBase<bool> {
public:
  Maybe() {
    m_value = false;
  }
  Maybe(bool value) : MaybeBase(value) {}
  Maybe(Maybe &&other) IP_NOEXCEPT : MaybeBase(std::move(other)) {}
  using MaybeBase::operator=;
};

template <> class Maybe<int> : public MaybeBase<int> {
public:
  Maybe() {
    m_value = 0;
  }
  Maybe(int value) : MaybeBase(value) {}
  Maybe(Maybe &&other) IP_NOEXCEPT : MaybeBase(std::move(other)) {}
  using MaybeBase::operator=;
};

template <> class Maybe<double> : public MaybeBase<double> {
public:
  Maybe() {
    m_value = 0;
  }
  Maybe(double value) : MaybeBase(value) {}
  Maybe(Maybe &&other) IP_NOEXCEPT : MaybeBase(std::move(other)) {}
  using MaybeBase::operator=;
};

template <> class Maybe<std::string> : public MaybeBase<std::string> {
public:
  Maybe() {}
  Maybe(const std::string &value) : MaybeBase(value) {}
  Maybe(Maybe &&other) IP_NOEXCEPT : MaybeBase(std::move(other)) {}
  using MaybeBase::operator=;
};
} // namespace debugger
} // namespace kraken

#endif // KRAKEN_DEBUGGER_MAYBE_H
