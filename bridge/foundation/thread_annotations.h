// Macros for static thread-safety analysis.
//
// These are from http://clang.llvm.org/docs/ThreadSafetyAnalysis.html (and thus
// really derive from google3's thread_annotations.h).
//
// TODO(vtl): We're still using the old-fashioned, deprecated annotations
// ("locks" instead of "capabilities"), since the new ones don't work yet (in
// particular, |TRY_ACQUIRE()| doesn't work: b/19264527).
// https://github.com/domokit/mojo/issues/314

#ifndef KRAKEN_FOUNDATION_THREAD_ANNOTATIONS_H_
#define KRAKEN_FOUNDATION_THREAD_ANNOTATIONS_H_

#include "macros.h"

// Enable thread-safety attributes only with clang.
// The attributes can be safely erased when compiling with other compilers.
#if defined(__clang__) && !defined(IS_ANDROID)
#define KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(x) __attribute__((x))
#else
#define KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(x)
#endif

#define KRAKEN_GUARDED_BY(x) KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(guarded_by(x))

#define KRAKEN_PT_GUARDED_BY(x)                                                \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(pt_guarded_by(x))

#define KRAKEN_ACQUIRE(...)                                                    \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(acquire_capability(__VA_ARGS__))

#define KRAKEN_RELEASE(...)                                                    \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(release_capability(__VA_ARGS__))

#define KRAKEN_ACQUIRED_AFTER(...)                                             \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(acquired_after(__VA_ARGS__))

#define KRAKEN_ACQUIRED_BEFORE(...)                                            \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(acquired_before(__VA_ARGS__))

#define KRAKEN_EXCLUSIVE_LOCKS_REQUIRED(...)                                   \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(exclusive_locks_required(__VA_ARGS__))

#define KRAKEN_SHARED_LOCKS_REQUIRED(...)                                      \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(shared_locks_required(__VA_ARGS__))

#define KRAKEN_LOCKS_EXCLUDED(...)                                             \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(locks_excluded(__VA_ARGS__))

#define KRAKEN_LOCK_RETURNED(x)                                                \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(lock_returned(x))

#define KRAKEN_LOCKABLE KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(lockable)

#define KRAKEN_SCOPED_LOCKABLE                                                 \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(scoped_lockable)

#define KRAKEN_EXCLUSIVE_LOCK_FUNCTION(...)                                    \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(exclusive_lock_function(__VA_ARGS__))

#define KRAKEN_SHARED_LOCK_FUNCTION(...)                                       \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(shared_lock_function(__VA_ARGS__))

#define KRAKEN_ASSERT_EXCLUSIVE_LOCK(...)                                      \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(assert_exclusive_lock(__VA_ARGS__))

#define KRAKEN_ASSERT_SHARED_LOCK(...)                                         \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(assert_shared_lock(__VA_ARGS__))

#define KRAKEN_EXCLUSIVE_TRYLOCK_FUNCTION(...)                                 \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(exclusive_trylock_function(__VA_ARGS__))

#define KRAKEN_SHARED_TRYLOCK_FUNCTION(...)                                    \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(shared_trylock_function(__VA_ARGS__))

#define KRAKEN_UNLOCK_FUNCTION(...)                                            \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(unlock_function(__VA_ARGS__))

#define KRAKEN_NO_THREAD_SAFETY_ANALYSIS                                       \
  KRAKEN_THREAD_ANNOTATION_ATTRIBUTE__(no_thread_safety_analysis)

// Use this in the header to annotate a function/method as not being
// thread-safe. This is equivalent to |KRAKEN_NO_THREAD_SAFETY_ANALYSIS|, but
// semantically different: it declares that the caller must abide by additional
// restrictions. Limitation: Unfortunately, you can't apply this to a method in
// an interface (i.e., pure virtual method) and have it applied automatically to
// implementations.
#define KRAKEN_NOT_THREAD_SAFE KRAKEN_NO_THREAD_SAFETY_ANALYSIS

#endif // KRAKEN_FOUNDATION_THREAD_ANNOTATIONS_H_
