import 'dart:collection';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:kraken/bridge.dart';

class PerformanceEntry {
  PerformanceEntry(this.name, this.entryType, this.startTime, this.duration);

  final String name;
  final String entryType;
  final double startTime;
  final double duration;
}

class PerformanceTiming {
  static SplayTreeMap<int, PerformanceTiming> _instanceMap = SplayTreeMap();

  static PerformanceTiming instance(int contextId) {
    if (!_instanceMap.containsKey(contextId)) {
      _instanceMap[contextId] = PerformanceTiming();
    }
    return _instanceMap[contextId];
  }

  void mark(String name, [double startTime]) {
    if (startTime == null) {
      startTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    }

    PerformanceEntry entry = PerformanceEntry(name, 'mark', startTime, 0);
    entries.add(entry);
  }

  Pointer<NativePerformanceEntryList> toNative() {
    Pointer<NativePerformanceEntryList> list = allocate<NativePerformanceEntryList>();
    Pointer<Pointer<NativePerformanceEntry>> nativeEntries =
        allocate<NativePerformanceEntry>(count: entries.length).cast<Pointer<NativePerformanceEntry>>();

    for (int i = 0; i < entries.length; i ++) {
      Pointer<NativePerformanceEntry> nativeEntry = allocate<NativePerformanceEntry>();
      nativeEntry.ref.name = Utf8.toUtf8(entries[i].name);
      nativeEntry.ref.entryType = Utf8.toUtf8(entries[i].entryType);
      nativeEntry.ref.startTime = entries[i].startTime;
      nativeEntry.ref.duration = entries[i].duration;
      nativeEntries[i] = nativeEntry;
    }

    list.ref.length = entries.length;
    list.ref.entries = nativeEntries;
    return list;
  }

  List<PerformanceEntry> entries = List();
}
