#import <Flutter/Flutter.h>

#import "KrakenMethodChannelPlugin.h"

typedef void(^MessageHandler)(FlutterMethodCall*, FlutterResult);

@interface KrakenMethodChannel : NSObject<NSCopying,NSMutableCopying>
@property KrakenMethodChannelPlugin* krakenMethodChannelPlugin;
@property FlutterMethodChannel* channel;
@property MessageHandler handler;

-(void) handleMessageCall:(FlutterMethodCall*)call result:(FlutterResult)result;
-(void) setMessageHandler:(MessageHandler) handler;
-(void) invokeMethod:(NSString *)method arguments:(nullable id) arguments;

+(instancetype)sharedMethodChannel;
-(void)onAttach:(KrakenMethodChannelPlugin*)plugin channel:(FlutterMethodChannel*) channel;

@end
