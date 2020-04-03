#import "KrakenMethodChannel.h"

@implementation KrakenMethodChannel

static KrakenMethodChannel * _instance;

+(instancetype) sharedMethodChannel {
  return [[self alloc] init];
}


+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

-(void)onAttach:(KrakenMethodChannelPlugin*)plugin channel:(FlutterMethodChannel*) channel {
  _instance->_channel = channel;
  _instance->_krakenMethodChannelPlugin = plugin;
}

- (void)handleMessageCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if (_instance->_handler != nil) {
    _instance->_handler(call, result);
  }
}

- (void)setMessageHandler:(MessageHandler) handler {
  _instance->_handler = handler;
}

-(void) invokeMethod:(NSString *)method arguments:(nullable id) arguments {
  dispatch_async(dispatch_get_main_queue(), ^{
    [_instance->_channel invokeMethod:method arguments:arguments];
  });
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
  return _instance;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
  return _instance;
}


@end
