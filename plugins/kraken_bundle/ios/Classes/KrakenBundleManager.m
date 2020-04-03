//
//  BundleManager.m
//  kraken_bundle
//
//  Created by lzl on 2020/3/30.
//

#import "KrakenBundleManager.h"

@implementation KrakenBundleManager;

static KrakenBundleManager * _instance;

+(instancetype)shareBundleManager{
    return [[self alloc]init];
}

+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

-(void)setUp:(NSString*)bundleUrl zipUrl:(NSString*)zipBundleUrl {
  if (bundleUrl != nil) {
    _instance->_bundleUrl = bundleUrl;
  }
  if (zipBundleUrl != nil) {
    _instance->_zipBundleUrl = zipBundleUrl;
  }
}

-(void)reload {
  if (_instance->_channel != nil) {
    [_instance->_channel invokeMethod:@"reload"
                            arguments:nil];
  }
}

-(void)onAttach:(KrakenBundlePlugin*)krakenBundlePlugin channel:(FlutterMethodChannel*) channel {
  _instance->_krakenBundlePlugin = krakenBundlePlugin;
  _instance->_channel = channel;
}

-(void)onDetach {
  _instance->_krakenBundlePlugin = nil;
}

-(NSString*)getBundleUrl {
  return _instance->_bundleUrl;
}

-(NSString*)getZipBundleUrl{
  return _instance->_zipBundleUrl;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
  return _instance;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
  return _instance;
}

@end
