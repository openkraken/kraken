//
//  BundleManager.h
//  kraken_bundle
//
//  Created by lzl on 2020/3/30.
//
#import <Flutter/Flutter.h>
#import "KrakenBundlePlugin.h"

@interface KrakenBundleManager : NSObject<NSCopying,NSMutableCopying>
@property NSString* bundleUrl;
@property NSString* zipBundleUrl;
@property KrakenBundlePlugin* krakenBundlePlugin;
@property FlutterMethodChannel* channel;

+(instancetype)shareBundleManager;
-(NSString*)getBundleUrl;
-(NSString*)getZipBundleUrl;
-(void)setUp:(NSString*)bundleUrl zipUrl:(NSString*)zipBundleUrl;
-(void)reload;
-(void)onAttach:(KrakenBundlePlugin*)krakenBundlePlugin channel:(FlutterMethodChannel*) channel;
-(void)onDetach;
@end
