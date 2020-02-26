#import "AudioplayersPlugin.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
    #import <MediaPlayer/MediaPlayer.h>
#endif

static NSString *const CHANNEL_NAME = @"xyz.luan/audioplayers";
NSString *const AudioplayersPluginStop = @"AudioplayersPluginStop";


static NSMutableDictionary * players;

@interface AudioplayersPlugin()
-(void) pause: (NSString *) playerId;
-(void) stop: (NSString *) playerId;
-(void) seek: (NSString *) playerId time: (CMTime) time;
-(void) onSoundComplete: (NSString *) playerId;
-(void) updateDuration: (NSString *) playerId;
-(void) onTimeInterval: (NSString *) playerId time: (CMTime) time;
@end

@implementation AudioplayersPlugin {
  FlutterResult _result;
}

typedef void (^VoidCallback)(NSString * playerId);

NSMutableSet *timeobservers;
FlutterMethodChannel *_channel_audioplayer;
bool _isDealloc = false;

NSObject<FlutterPluginRegistrar> *_registrar;
int64_t _updateHandleMonitorKey;

#if TARGET_OS_IPHONE
    FlutterEngine *_headlessEngine;
    FlutterMethodChannel *_callbackChannel;
    bool headlessServiceInitialized = false;

    NSString *_currentPlayerId; // to be used for notifications command center
    MPNowPlayingInfoCenter *_infoCenter;
    MPRemoteCommandCenter *remoteCommandCenter;
    
    NSString *osName = @"iOS";
#else
    NSString *osName = @"macOS";
#endif

NSString *_title; 
NSString *_albumTitle;
NSString *_artist;
NSString *_imageUrl;
int _duration;
const float _defaultPlaybackRate = 1.0;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  _registrar = registrar;
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:CHANNEL_NAME
                                   binaryMessenger:[registrar messenger]];
  AudioplayersPlugin* instance = [[AudioplayersPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  _channel_audioplayer = channel;
}

- (id)init {
  self = [super init];
  if (self) {
      _isDealloc = false;
      players = [[NSMutableDictionary alloc] init];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needStop) name:AudioplayersPluginStop object:nil];

    #if TARGET_OS_IPHONE
          // this method is used to listen to audio playpause event
          // from the notification area in the background.
          _headlessEngine = [[FlutterEngine alloc] initWithName:@"AudioPlayerIsolate"
                                                        project:nil];
          // This is the method channel used to communicate with
          // `_backgroundCallbackDispatcher` defined in the Dart portion of our plugin.
          // Note: we don't add a MethodCallDelegate for this channel now since our
          // BinaryMessenger needs to be initialized first, which is done in
          // `startHeadlessService` below.
          _callbackChannel = [FlutterMethodChannel
              methodChannelWithName:@"xyz.luan/audioplayers_callback"
                    binaryMessenger:_headlessEngine];
    #endif
  }
  return self;
}
    
- (void)needStop {
    _isDealloc = true;
    [self destroy];
}

#if TARGET_OS_IPHONE
    // Initializes and starts the background isolate which will process audio
    // events. `handle` is the handle to the callback dispatcher which we specified
    // in the Dart portion of the plugin.
    - (void)startHeadlessService:(int64_t)handle {
        // Lookup the information for our callback dispatcher from the callback cache.
        // This cache is populated when `PluginUtilities.getCallbackHandle` is called
        // and the resulting handle maps to a `FlutterCallbackInformation` object.
        // This object contains information needed by the engine to start a headless
        // runner, which includes the callback name as well as the path to the file
        // containing the callback.
        FlutterCallbackInformation *info = [FlutterCallbackCache lookupCallbackInformation:handle];
        NSAssert(info != nil, @"failed to find callback");
        NSString *entrypoint = info.callbackName;
        NSString *uri = info.callbackLibraryPath;

        // Here we actually launch the background isolate to start executing our
        // callback dispatcher, `_backgroundCallbackDispatcher`, in Dart.
        headlessServiceInitialized = [_headlessEngine runWithEntrypoint:entrypoint libraryURI:uri];
        if (headlessServiceInitialized) {
            // The headless runner needs to be initialized before we can register it as a
            // MethodCallDelegate or else we get an illegal memory access. If we don't
            // want to make calls from `_backgroundCallDispatcher` back to native code,
            // we don't need to add a MethodCallDelegate for this channel.
            [_registrar addMethodCallDelegate:self channel:_callbackChannel];
        }
    }
#endif

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString * playerId = call.arguments[@"playerId"];
  NSLog(@"%@ => call %@, playerId %@", osName, call.method, playerId);

  typedef void (^CaseBlock)(void);

  // Squint and this looks like a proper switch!
  NSDictionary *methods = @{
                @"startHeadlessService":
                  ^{
                      #if TARGET_OS_IPHONE
                          if (call.arguments[@"handleKey"] == nil)
                              result(0);
                          [self startHeadlessService:[call.arguments[@"handleKey"][0] longValue]];
                      #else
                          result(FlutterMethodNotImplemented);
                      #endif
                  },
                @"monitorNotificationStateChanges":
                  ^{
                    if (call.arguments[@"handleMonitorKey"] == nil)
                        result(0);
                    _updateHandleMonitorKey = [call.arguments[@"handleMonitorKey"][0] longLongValue];
                  },
                @"play":
                  ^{
                    NSLog(@"play!");
                    NSString *url = call.arguments[@"url"];
                    if (url == nil)
                        result(0);
                    if (call.arguments[@"isLocal"] == nil)
                        result(0);
                    if (call.arguments[@"volume"] == nil)
                        result(0);
                    if (call.arguments[@"position"] == nil)
                        result(0);
                    if (call.arguments[@"respectSilence"] == nil)
                        result(0);
                    int isLocal = [call.arguments[@"isLocal"]intValue] ;
                    float volume = (float)[call.arguments[@"volume"] doubleValue] ;
                    int milliseconds = call.arguments[@"position"] == [NSNull null] ? 0.0 : [call.arguments[@"position"] intValue] ;
                    bool respectSilence = [call.arguments[@"respectSilence"]boolValue] ;
                    CMTime time = CMTimeMakeWithSeconds(milliseconds / 1000,NSEC_PER_SEC);
                    NSLog(@"isLocal: %d %@", isLocal, call.arguments[@"isLocal"] );
                    NSLog(@"volume: %f %@", volume, call.arguments[@"volume"] );
                    NSLog(@"position: %d %@", milliseconds, call.arguments[@"positions"] );
                    [self play:playerId url:url isLocal:isLocal volume:volume time:time isNotification:respectSilence];
                  },
                @"pause":
                  ^{
                    NSLog(@"pause");
                    [self pause:playerId];
                  },
                @"resume":
                  ^{
                    NSLog(@"resume");
                    [self resume:playerId];
                  },
                @"stop":
                  ^{
                    NSLog(@"stop");
                    [self stop:playerId];
                  },
                @"release":
                    ^{
                        NSLog(@"release");
                        [self stop:playerId];
                    },
                @"seek":
                  ^{
                    NSLog(@"seek");
                    if (!call.arguments[@"position"]) {
                      result(0);
                    } else {
                      int milliseconds = [call.arguments[@"position"] intValue];
                      NSLog(@"Seeking to: %d milliseconds", milliseconds);
                      [self seek:playerId time:CMTimeMakeWithSeconds(milliseconds / 1000,NSEC_PER_SEC)];
                    }
                  },
                @"setUrl":
                  ^{
                    NSLog(@"setUrl");
                    NSString *url = call.arguments[@"url"];
                    int isLocal = [call.arguments[@"isLocal"]intValue];
                    bool respectSilence = [call.arguments[@"respectSilence"]boolValue] ;
                    [ self setUrl:url
                          isLocal:isLocal
                          isNotification:respectSilence
                          playerId:playerId
                          onReady:^(NSString * playerId) {
                            result(@(1));
                          }
                    ];
                  },
                @"getDuration":
                    ^{
                        
                        int duration = [self getDuration:playerId];
                        NSLog(@"getDuration: %i ", duration);
                        result(@(duration));
                    },
                @"setVolume":
                  ^{
                    NSLog(@"setVolume");
                    float volume = (float)[call.arguments[@"volume"] doubleValue];
                    [self setVolume:volume playerId:playerId];
                  },
                @"getCurrentPosition":
                  ^{
                      int currentPosition = [self getCurrentPosition:playerId];
                      NSLog(@"getCurrentPosition: %i ", currentPosition);
                      result(@(currentPosition));
                  },
                @"setPlaybackRate":
                  ^{
                    NSLog(@"setPlaybackRate");
                    float playbackRate = (float)[call.arguments[@"playbackRate"] doubleValue];
                    [self setPlaybackRate:playbackRate playerId:playerId];
                  },
                @"setNotification":
                  ^{
                      #if TARGET_OS_IPHONE
                          NSLog(@"setNotification");
                          NSString *title = call.arguments[@"title"];
                          NSString *albumTitle = call.arguments[@"albumTitle"];
                          NSString *artist = call.arguments[@"artist"];
                          NSString *imageUrl = call.arguments[@"imageUrl"];

                          int forwardSkipInterval = [call.arguments[@"forwardSkipInterval"] intValue];
                          int backwardSkipInterval = [call.arguments[@"backwardSkipInterval"] intValue];
                          int duration = [call.arguments[@"duration"] intValue];
                          int elapsedTime = [call.arguments[@"elapsedTime"] intValue];

                          [self setNotification:title albumTitle:albumTitle artist:artist imageUrl:imageUrl
                                forwardSkipInterval:forwardSkipInterval backwardSkipInterval:backwardSkipInterval
                                duration:duration elapsedTime:elapsedTime playerId:playerId];
                      #else
                          result(FlutterMethodNotImplemented);
                      #endif
                  },
                @"setReleaseMode":
                  ^{
                    NSLog(@"setReleaseMode");
                    NSString *releaseMode = call.arguments[@"releaseMode"];
                    bool looping = [releaseMode hasSuffix:@"LOOP"];
                    [self setLooping:looping playerId:playerId];
                  }
                };

  [ self initPlayerInfo:playerId ];
  CaseBlock c = methods[call.method];
  if (c) c(); else {
    NSLog(@"not implemented");
    result(FlutterMethodNotImplemented);
  }
  if(![call.method isEqualToString:@"setUrl"]) {
    result(@(1));
  }
}

-(void) initPlayerInfo: (NSString *) playerId {
  NSMutableDictionary * playerInfo = players[playerId];
  if (!playerInfo) {
    players[playerId] = [@{@"isPlaying": @false, @"volume": @(1.0), @"rate": @(_defaultPlaybackRate), @"looping": @(false)} mutableCopy];
  }
}

#if TARGET_OS_IPHONE
    -(void) setNotification: (NSString *) title
            albumTitle:  (NSString *) albumTitle
            artist:  (NSString *) artist
            imageUrl:  (NSString *) imageUrl
            forwardSkipInterval:  (int) forwardSkipInterval
            backwardSkipInterval:  (int) backwardSkipInterval
            duration:  (int) duration
            elapsedTime:  (int) elapsedTime
            playerId: (NSString*) playerId {
        _title = title;
        _albumTitle = albumTitle;
        _artist = artist;
        _imageUrl = imageUrl;
        _duration = duration;

        _infoCenter = [MPNowPlayingInfoCenter defaultCenter];
        
        [ self updateNotification:elapsedTime ];

        if (remoteCommandCenter == nil) {
          remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];

          MPSkipIntervalCommand *skipBackwardIntervalCommand = [remoteCommandCenter skipBackwardCommand];
          [skipBackwardIntervalCommand setEnabled:YES];
          [skipBackwardIntervalCommand addTarget:self action:@selector(skipBackwardEvent:)];
          skipBackwardIntervalCommand.preferredIntervals = @[@(backwardSkipInterval)];  // Set your own interval

          MPSkipIntervalCommand *skipForwardIntervalCommand = [remoteCommandCenter skipForwardCommand];
          skipForwardIntervalCommand.preferredIntervals = @[@(forwardSkipInterval)];  // Max 99
          [skipForwardIntervalCommand setEnabled:YES];
          [skipForwardIntervalCommand addTarget:self action:@selector(skipForwardEvent:)];

          MPRemoteCommand *pauseCommand = [remoteCommandCenter pauseCommand];
          [pauseCommand setEnabled:YES];
          [pauseCommand addTarget:self action:@selector(playOrPauseEvent:)];
          
          MPRemoteCommand *playCommand = [remoteCommandCenter playCommand];
          [playCommand setEnabled:YES];
          [playCommand addTarget:self action:@selector(playOrPauseEvent:)];

          MPRemoteCommand *togglePlayPauseCommand = [remoteCommandCenter togglePlayPauseCommand];
          [togglePlayPauseCommand setEnabled:YES];
          [togglePlayPauseCommand addTarget:self action:@selector(playOrPauseEvent:)];
        }
    }

    -(MPRemoteCommandHandlerStatus) skipBackwardEvent: (MPSkipIntervalCommandEvent *) skipEvent {
        NSLog(@"Skip backward by %f", skipEvent.interval);
        NSMutableDictionary * playerInfo = players[_currentPlayerId];
        AVPlayer *player = playerInfo[@"player"];
        AVPlayerItem *currentItem = player.currentItem;
        CMTime currentTime = currentItem.currentTime;
        CMTime newTime = CMTimeSubtract(currentTime, CMTimeMakeWithSeconds(skipEvent.interval, NSEC_PER_SEC));
        // if CMTime is negative, set it to zero
        if (CMTimeGetSeconds(newTime) < 0) {
          [ self seek:_currentPlayerId time:CMTimeMakeWithSeconds(0,1) ];
        } else {
          [ self seek:_currentPlayerId time:newTime ];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }

    -(MPRemoteCommandHandlerStatus) skipForwardEvent: (MPSkipIntervalCommandEvent *) skipEvent {
        NSLog(@"Skip forward by %f", skipEvent.interval);
        NSMutableDictionary * playerInfo = players[_currentPlayerId];
        AVPlayer *player = playerInfo[@"player"];
        AVPlayerItem *currentItem = player.currentItem;
        CMTime currentTime = currentItem.currentTime;
        CMTime maxDuration = currentItem.duration;
        CMTime newTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(skipEvent.interval, NSEC_PER_SEC));
        // if CMTime is more than max duration, limit it
        if (CMTimeGetSeconds(newTime) > CMTimeGetSeconds(maxDuration)) {
          [ self seek:_currentPlayerId time:maxDuration ];
        } else {
          [ self seek:_currentPlayerId time:newTime ];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }
    -(MPRemoteCommandHandlerStatus) playOrPauseEvent: (MPSkipIntervalCommandEvent *) playOrPauseEvent {
        NSLog(@"playOrPauseEvent");

        NSMutableDictionary * playerInfo = players[_currentPlayerId];
        AVPlayer *player = playerInfo[@"player"];
        bool _isPlaying = false;
        NSString *playerState;
        if (player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            // player is playing and pause it
            [ self pause:_currentPlayerId ];
            _isPlaying = false;
            playerState = @"paused";
        } else if (player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
            // player is paused and resume it
            [ self resume:_currentPlayerId ];
            _isPlaying = true;
            playerState = @"playing";
        }
        [_channel_audioplayer invokeMethod:@"audio.onNotificationPlayerStateChanged" arguments:@{@"playerId": _currentPlayerId, @"value": @(_isPlaying)}];
        [_callbackChannel invokeMethod:@"audio.onNotificationBackgroundPlayerStateChanged" arguments:@{@"playerId": _currentPlayerId, @"updateHandleMonitorKey": @(_updateHandleMonitorKey), @"value": playerState}];
        return MPRemoteCommandHandlerStatusSuccess;
    }

    -(void) updateNotification: (int) elapsedTime {
      NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
      playingInfo[MPMediaItemPropertyTitle] = _title;
      playingInfo[MPMediaItemPropertyAlbumTitle] = _albumTitle;
      playingInfo[MPMediaItemPropertyArtist] = _artist;
      
      NSURL *url = [[NSURL alloc] initWithString:_imageUrl];
      UIImage *artworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
      if (artworkImage)
      {
          MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: artworkImage];
          playingInfo[MPMediaItemPropertyArtwork] = albumArt;
      }

      playingInfo[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithInt: _duration];
      playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithInt: elapsedTime];

      playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = @(_defaultPlaybackRate);
      NSLog(@"setNotification done");

      if (_infoCenter != nil) {
        _infoCenter.nowPlayingInfo = playingInfo;
      }
    }
#endif

-(void) setUrl: (NSString*) url
       isLocal: (bool) isLocal
       isNotification: (bool) respectSilence
       playerId: (NSString*) playerId
       onReady:(VoidCallback)onReady
{
  NSMutableDictionary * playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];
  #if TARGET_OS_IPHONE
    _currentPlayerId = playerId; // to be used for notifications command center
  #endif
  NSMutableSet *observers = playerInfo[@"observers"];
  AVPlayerItem *playerItem;
    
  NSLog(@"setUrl %@", url);
    
  #if TARGET_OS_IPHONE
      // code moved from play() to setUrl() to fix the bug of audio not playing in ios background
      NSError *error = nil;
      BOOL success = false;

      AVAudioSessionCategory category = respectSilence ? AVAudioSessionCategoryAmbient : AVAudioSessionCategoryPlayback;
      // When using AVAudioSessionCategoryPlayback, by default, this implies that your app’s audio is nonmixable—activating your session
      // will interrupt any other audio sessions which are also nonmixable. AVAudioSessionCategoryPlayback should not be used with
      // AVAudioSessionCategoryOptionMixWithOthers option. If so, it prevents infoCenter from working correctly.
      if (respectSilence) {
        success = [[AVAudioSession sharedInstance] setCategory:category withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
      } else {
        success = [[AVAudioSession sharedInstance] setCategory:category error:&error];
      }
    
      if (!success) {
        NSLog(@"Error setting speaker: %@", error);
      }
      [[AVAudioSession sharedInstance] setActive:YES error:&error];
  #endif
    
  if (!playerInfo || ![url isEqualToString:playerInfo[@"url"]]) {
    if (isLocal) {
      playerItem = [ [ AVPlayerItem alloc ] initWithURL:[ NSURL fileURLWithPath:url ]];
    } else {
      playerItem = [ [ AVPlayerItem alloc ] initWithURL:[ NSURL URLWithString:url ]];
    }
      
    if (playerInfo[@"url"]) {
      [[player currentItem] removeObserver:self forKeyPath:@"player.currentItem.status" ];

      [ playerInfo setObject:url forKey:@"url" ];

      for (id ob in observers) {
         [ [ NSNotificationCenter defaultCenter ] removeObserver:ob ];
      }
      [ observers removeAllObjects ];
      [ player replaceCurrentItemWithPlayerItem: playerItem ];
    } else {
      player = [[ AVPlayer alloc ] initWithPlayerItem: playerItem ];
      observers = [[NSMutableSet alloc] init];

      [ playerInfo setObject:player forKey:@"player" ];
      [ playerInfo setObject:url forKey:@"url" ];
      [ playerInfo setObject:observers forKey:@"observers" ];

      // stream player position
      CMTime interval = CMTimeMakeWithSeconds(0.2, NSEC_PER_SEC);
      id timeObserver = [ player  addPeriodicTimeObserverForInterval: interval queue: nil usingBlock:^(CMTime time){
        [self onTimeInterval:playerId time:time];
      }];
        [timeobservers addObject:@{@"player":player, @"observer":timeObserver}];
    }
      
    id anobserver = [[ NSNotificationCenter defaultCenter ] addObserverForName: AVPlayerItemDidPlayToEndTimeNotification
                                                                        object: playerItem
                                                                         queue: nil
                                                                    usingBlock:^(NSNotification* note){
                                                                        [self onSoundComplete:playerId];
                                                                    }];
    [observers addObject:anobserver];
      
    // is sound ready
    [playerInfo setObject:onReady forKey:@"onReady"];
    [playerItem addObserver:self
                          forKeyPath:@"player.currentItem.status"
                          options:0
                          context:(void*)playerId];
      
  } else {
    if ([[player currentItem] status ] == AVPlayerItemStatusReadyToPlay) {
      onReady(playerId);
    }
  }
}

-(void) play: (NSString*) playerId
         url: (NSString*) url
     isLocal: (int) isLocal
      volume: (float) volume
        time: (CMTime) time
      isNotification: (bool) respectSilence
{
  [ self setUrl:url 
         isLocal:isLocal 
         isNotification:respectSilence
         playerId:playerId 
         onReady:^(NSString * playerId) {
           NSMutableDictionary * playerInfo = players[playerId];
           AVPlayer *player = playerInfo[@"player"];
           [ player setVolume:volume ];
           [ player seekToTime:time ];

           if (@available(iOS 10.0, *)) {
             [player playImmediatelyAtRate:_defaultPlaybackRate];
           } else {
             [ player play];
           }

           [ playerInfo setObject:@true forKey:@"isPlaying" ];
         }    
  ];
}

-(void) updateDuration: (NSString *) playerId
{
  NSMutableDictionary * playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];

  CMTime duration = [[[player currentItem]  asset] duration];
  NSLog(@"%@ -> updateDuration...%f", osName, CMTimeGetSeconds(duration));
  if(CMTimeGetSeconds(duration)>0){
    NSLog(@"%@ -> invokechannel", osName);
   int mseconds= CMTimeGetSeconds(duration)*1000;
    [_channel_audioplayer invokeMethod:@"audio.onDuration" arguments:@{@"playerId": playerId, @"value": @(mseconds)}];
  }
}

-(int) getDuration: (NSString *) playerId {
    NSMutableDictionary * playerInfo = players[playerId];
    AVPlayer *player = playerInfo[@"player"];
    
   CMTime duration = [[[player currentItem]  asset] duration];
    int mseconds= CMTimeGetSeconds(duration)*1000;
    return mseconds;
}

-(int) getCurrentPosition: (NSString *) playerId {
    NSMutableDictionary * playerInfo = players[playerId];
    AVPlayer *player = playerInfo[@"player"];

    CMTime duration = [player currentTime];
    return CMTimeGetSeconds(duration) * 1000;
}

// No need to spam the logs with every time interval update
-(void) onTimeInterval: (NSString *) playerId
                  time: (CMTime) time {
    // NSLog(@"%@ -> onTimeInterval...", osName);
    if (_isDealloc) {
        return;
    }
    int seconds = CMTimeGetSeconds(time);
    int mseconds = seconds*1000;
    
    [_channel_audioplayer invokeMethod:@"audio.onCurrentPosition" arguments:@{@"playerId": playerId, @"value": @(mseconds)}];
}

-(void) pause: (NSString *) playerId {
  NSMutableDictionary * playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];

  [ player pause ];
  [playerInfo setObject:@false forKey:@"isPlaying"];
}

-(void) resume: (NSString *) playerId {
  NSMutableDictionary * playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];
  float playbackRate = [ playerInfo[@"rate"] floatValue];
  [player play];
  [ player setRate:playbackRate ];
  [playerInfo setObject:@true forKey:@"isPlaying"];
}

-(void) setVolume: (float) volume 
        playerId:  (NSString *) playerId {
  NSMutableDictionary *playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];
  playerInfo[@"volume"] = @(volume);
  [ player setVolume:volume ];
}

-(void) setPlaybackRate: (float) playbackRate 
        playerId:  (NSString *) playerId {
  NSLog(@"%@ -> calling setPlaybackRate", osName);
  
  NSMutableDictionary *playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];
  playerInfo[@"rate"] = @(playbackRate);
  [ player setRate:playbackRate ];
  #if TARGET_OS_IPHONE
      if (_infoCenter != nil) {
        AVPlayerItem *currentItem = player.currentItem;
        CMTime currentTime = currentItem.currentTime;
        [ self updateNotification:CMTimeGetSeconds(currentTime) ];
      }
  #endif
}

-(void) setLooping: (bool) looping
        playerId:  (NSString *) playerId {
  NSMutableDictionary *playerInfo = players[playerId];
  [playerInfo setObject:@(looping) forKey:@"looping"];
}

-(void) stop: (NSString *) playerId {
  NSMutableDictionary * playerInfo = players[playerId];

  if ([playerInfo[@"isPlaying"] boolValue]) {
    [ self pause:playerId ];
    [ self seek:playerId time:CMTimeMake(0, 1) ];
    [playerInfo setObject:@false forKey:@"isPlaying"];
  }
}

-(void) seek: (NSString *) playerId
        time: (CMTime) time {
  NSMutableDictionary * playerInfo = players[playerId];
  AVPlayer *player = playerInfo[@"player"];
  #if TARGET_OS_IPHONE
  [[player currentItem] seekToTime:time completionHandler:^(BOOL finished) {
      if (finished) {
          NSLog(@"ios -> seekComplete...");
          int seconds = CMTimeGetSeconds(time);
          if (_infoCenter != nil) {
            [ self updateNotification:seconds ];
          }
          [ _channel_audioplayer invokeMethod:@"audio.onSeekComplete" arguments:@{@"playerId": playerId,@"value":@(YES)}];
      }else{
          NSLog(@"ios -> seekCancelled...");
          [ _channel_audioplayer invokeMethod:@"audio.onSeekComplete" arguments:@{@"playerId": playerId,@"value":@(NO)}];
      }
  }];
  #else
  [[player currentItem] seekToTime:time];
  #endif
}

-(void) onSoundComplete: (NSString *) playerId {
  NSLog(@"%@ -> onSoundComplete...", osName);
  NSMutableDictionary * playerInfo = players[playerId];

  if (![playerInfo[@"isPlaying"] boolValue]) {
    return;
  }

  [ self pause:playerId ];

  if ([ playerInfo[@"looping"] boolValue]) {
    [ self seek:playerId time:CMTimeMakeWithSeconds(0,1) ];
    [ self resume:playerId ];
  }

  [ _channel_audioplayer invokeMethod:@"audio.onComplete" arguments:@{@"playerId": playerId}];
  #if TARGET_OS_IPHONE
      if (headlessServiceInitialized) {
          [_callbackChannel invokeMethod:@"audio.onNotificationBackgroundPlayerStateChanged" arguments:@{@"playerId": playerId, @"updateHandleMonitorKey": @(_updateHandleMonitorKey), @"value": @"completed"}];
      }
  #endif
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
  if ([keyPath isEqualToString: @"player.currentItem.status"]) {
    NSString *playerId = (__bridge NSString*)context;
    NSMutableDictionary * playerInfo = players[playerId];
    AVPlayer *player = playerInfo[@"player"];

    NSLog(@"player status: %ld",(long)[[player currentItem] status ]);

    // Do something with the status...
    if ([[player currentItem] status ] == AVPlayerItemStatusReadyToPlay) {
      [self updateDuration:playerId];

      VoidCallback onReady = playerInfo[@"onReady"];
      if (onReady != nil) {
        [playerInfo removeObjectForKey:@"onReady"];  
        onReady(playerId);
      }
    } else if ([[player currentItem] status ] == AVPlayerItemStatusFailed) {
      [_channel_audioplayer invokeMethod:@"audio.onError" arguments:@{@"playerId": playerId, @"value": @"AVPlayerItemStatus.failed"}];
    }
  } else {
    // Any unrecognized context must belong to super
    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
  }
}

- (void)destroy {
    for (id value in timeobservers)
    [value[@"player"] removeTimeObserver:value[@"observer"]];
    timeobservers = nil;
    
    for (NSString* playerId in players) {
        NSMutableDictionary * playerInfo = players[playerId];
        NSMutableSet * observers = playerInfo[@"observers"];
        for (id ob in observers)
        [[NSNotificationCenter defaultCenter] removeObserver:ob];
    }
    players = nil;
}
    
- (void)dealloc {
    [self destroy];
}


@end
