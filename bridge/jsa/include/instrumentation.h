/*
 * Copyright (C) 2019 Alibaba Inc. All rights reserved.
 * Author: Kraken Team.
 */

#ifndef JSA_INSTRUMENTATION_H_
#define JSA_INSTRUMENTATION_H_

#include <string>

#include "js_type.h"

namespace alibaba {
namespace jsa {

/// Methods for starting and collecting instrumentation, an \c Instrumentation
/// instance is associated with a particular \c Runtime instance, which it
/// controls the instrumentation of.
class Instrumentation {
public:
  virtual ~Instrumentation() = default;

  /// Returns GC statistics as a JSON-encoded string, with an object containing
  /// "type" and "version" fields outermost. "type" is a string, unique to a
  /// particular implementation of \c jsa::Instrumentation, and "version" is a
  /// number to indicate any revision to that implementation and its output
  /// format.
  ///
  /// \pre This call can only be made on the instrumentation instance of a
  ///   context initialised to collect GC statistics.
  ///
  /// \post All cumulative measurements mentioned in the output are accumulated
  ///   across the entire lifetime of the Runtime.
  ///
  /// \return the GC statistics collected so far, as a JSON-encoded string.
  virtual std::string getRecordedGCStats() = 0;

  /// Request statistics about the current state of the context's heap. This
  /// function can be called at any time, and should produce information that is
  /// correct at the instant it is called (i.e, not stale).
  ///
  /// \return a jsa Value containing whichever statistics the context supports
  ///   for its heap.
  virtual Value getHeapInfo(bool includeExpensive) = 0;

  /// perform a full garbage collection
  virtual void collectGarbage() = 0;

  /// Captures the heap to a file
  ///
  /// \param path to save the heap capture
  ///
  /// \param compact Whether the JSON should be compact or pretty
  ///
  /// \return true iff the heap capture succeeded
  virtual bool createSnapshotToFile(const std::string &path, bool compact) = 0;

  /// Captures the heap to an output stream
  ///
  /// \param os output stream to write to.
  ///
  /// \param compact Whether the JSON should be compact or pretty
  ///
  /// \return true iff the heap capture succeeded.
  virtual bool createSnapshotToStream(std::ostream &os, bool compact) = 0;

  /// Write a trace of bridge traffic to the given file name.
  virtual void
  writeBridgeTrafficTraceToFile(const std::string &fileName) const = 0;

  /// Write basic block profile trace to the given file name.
  virtual void
  writeBasicBlockProfileTraceToFile(const std::string &fileName) const = 0;

  /// Dump external profiler symbols to the given file name.
  virtual void dumpProfilerSymbolsToFile(const std::string &fileName) const = 0;
};

} // namespace jsa
} // namespace alibaba

#endif // JSA_INSTRUMENTATION_H_
