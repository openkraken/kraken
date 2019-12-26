//
//  kraken_cpp_to_dart.hpp
//  sources
//
//  Created by 对象 on 2019/8/7.
//

#ifndef kraken_cpp_to_dart_hpp
#define kraken_cpp_to_dart_hpp

#if OS_WIN
#define FLUTTER_EXPORT __declspec(dllexport)
#else  // OS_WIN
#define FLUTTER_EXPORT __attribute__((visibility("default")))
#endif  // OS_WIN

FLUTTER_EXPORT
const char* KrakenInvokeDartFromCpp(const char* name, const char* arg);

#endif /* kraken_cpp_to_dart_hpp */
