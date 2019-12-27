//
//  kraken_cpp_to_dart.hpp
//  sources
//
//  Created by 对象 on 2019/8/7.
//

#ifndef kraken_cpp_to_dart_hpp
#define kraken_cpp_to_dart_hpp

#include <string>

#if OS_WIN
#define FLUTTER_EXPORT __declspec(dllexport)
#else  // OS_WIN
#define FLUTTER_EXPORT __attribute__((visibility("default")))
#endif  // OS_WIN

FLUTTER_EXPORT
const char* KrakenInvokeDartFromCpp(const char* functionName, const char* args);

FLUTTER_EXPORT
int KrakenRegisterSetTimeout(int callbackId, int timeout);

FLUTTER_EXPORT
int KrakenRegisterSetInterval(int callbackId, int timeout);

FLUTTER_EXPORT
void KrakenInvokeClearTimeout(int timerId);

FLUTTER_EXPORT
void KrakenInvokeClearInterval(int timerId);

FLUTTER_EXPORT
void KrakenInvokeFetch(int fetchId, const char* url, const char* data);

FLUTTER_EXPORT
double KrakenGetScreenWidth();

FLUTTER_EXPORT
double KrakenGetScreenHeight();

FLUTTER_EXPORT
double KrakenGetScreenAvailWidth();

FLUTTER_EXPORT
double KrakenGetScreenAvailHeight();

#endif /* kraken_cpp_to_dart_hpp */
