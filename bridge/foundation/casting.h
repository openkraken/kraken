/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef KRAKENBRIDGE_FOUNDATION_CASTING_H_
#define KRAKENBRIDGE_FOUNDATION_CASTING_H_

#include <cassert>
#include <type_traits>

namespace kraken {

// Helpers for downcasting in a class hierarchy.
//
//   IsA<T>(x): returns true if |x| can be safely downcast to T*. Usage of this
//       should not be common; if it is paired with a call to To<T>, consider
//       using DynamicTo<T> instead (see below). Note that this also returns
//       false if |x| is nullptr.
//
//   To<T>(x): unconditionally downcasts and returns |x| as a T*.
//   Use when IsA<T>(x) is known to be true due to external invariants.
//   If |x| is nullptr, returns nullptr.
//
//   DynamicTo<T>(x): downcasts and returns |x| as a T* iff IsA<T>(x) is true,
//       and nullptr otherwise. This is useful for combining a conditional
//       branch on IsA<T>(x) and an invocation of To<T>(x), e.g.:
//           if (IsA<DerivedClass>(x))
//             To<DerivedClass>(x)->...
//       can be written:
//           if (auto* derived = DynamicTo<DerivedClass>(x))
//             derived->...;
//
// Marking downcasts as safe is done by specializing the DowncastTraits
// template:
//
// template <>
// struct DowncastTraits<DerivedClass> {
//   static bool AllowFrom(const BaseClass& b) {
//     return b.IsDerivedClass();
//   }
//   static bool AllowFrom(const AnotherBaseClass& b) {
//     return b.type() == AnotherBaseClass::kDerivedClassTag;
//   }
// };
//
// int main() {
//   BaseClass* base = CreateDerived();
//   AnotherBaseClass* another_base = CreateDerived();
//   UnrelatedClass* unrelated = CreateUnrelated();
//
//   std::cout << std::boolalpha;
//   std::cout << IsA<Derived>(base) << '\n';          // prints true
//   std::cout << IsA<Derived>(another_base) << '\n';  // prints true
//   std::cout << IsA<Derived>(unrelated) << '\n';     // prints false
// }
template <typename T>
struct DowncastTraits {
  template <typename U>
  static bool AllowFrom(const U&) {
    static_assert(sizeof(U) == 0, "no downcast traits specialization for T");
    assert(false);
    return false;
  }
};

namespace internal {

// Though redundant with the return type inferred by `auto`, the trailing return
// type is needed for SFINAE.
template <typename Derived, typename Base>
auto IsDowncastAllowedHelper(const Base& from) -> decltype(DowncastTraits<Derived>::AllowFrom(from)) {
  return DowncastTraits<Derived>::AllowFrom(from);
}

}  // namespace internal

// Returns true iff the conversion from Base to Derived is allowed. For the
// pointer overloads, returns false if the input pointer is nullptr.
template <typename Derived, typename Base>
bool IsA(const Base& from) {
  return internal::IsDowncastAllowedHelper<Derived>(from);
}

template <typename Derived, typename Base>
bool IsA(const Base* from) {
  return from && IsA<Derived>(*from);
}

template <typename Derived, typename Base>
bool IsA(Base& from) {
  return IsA<Derived>(static_cast<const Base&>(from));
}

template <typename Derived, typename Base>
bool IsA(Base* from) {
  return from && IsA<Derived>(*from);
}

// Unconditionally downcasts from Base to Derived. Internally, this asserts
// that |from| is a Derived to help catch bad casts in testing/fuzzing. For the
// pointer overloads, returns nullptr if the input pointer is nullptr.
template <typename Derived, typename Base>
const Derived& To(const Base& from) {
  return static_cast<const Derived&>(from);
}

template <typename Derived, typename Base>
const Derived* To(const Base* from) {
  return from ? &To<Derived>(*from) : nullptr;
}

template <typename Derived, typename Base>
Derived& To(Base& from) {
  return static_cast<Derived&>(from);
}
template <typename Derived, typename Base>
Derived* To(Base* from) {
  return from ? &To<Derived>(*from) : nullptr;
}

// Safely downcasts from Base to Derived. If |from| is not a Derived, returns
// nullptr; otherwise, downcasts from Base to Derived. For the pointer
// overloads, returns nullptr if the input pointer is nullptr.
template <typename Derived, typename Base>
const Derived* DynamicTo(const Base* from) {
  return IsA<Derived>(from) ? To<Derived>(from) : nullptr;
}

template <typename Derived, typename Base>
const Derived* DynamicTo(const Base& from) {
  return IsA<Derived>(from) ? &To<Derived>(from) : nullptr;
}

template <typename Derived, typename Base>
Derived* DynamicTo(Base* from) {
  return IsA<Derived>(from) ? To<Derived>(from) : nullptr;
}

template <typename Derived, typename Base>
Derived* DynamicTo(Base& from) {
  return IsA<Derived>(from) ? &To<Derived>(from) : nullptr;
}

}  // namespace kraken

#endif  // KRAKENBRIDGE_FOUNDATION_CASTING_H_
