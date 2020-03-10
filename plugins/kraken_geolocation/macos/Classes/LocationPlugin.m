#import "LocationPlugin.h"

#ifdef COCOAPODS
@import CoreLocation;
#else
#import <CoreLocation/CoreLocation.h>
#endif

@interface LocationPlugin() <FlutterStreamHandler, CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *clLocationManager;
@property (copy, nonatomic)   FlutterResult      flutterResult;
@property (assign, nonatomic) BOOL               locationWanted;
@property (assign, nonatomic) BOOL               permissionWanted;

@property (copy, nonatomic)   FlutterEventSink   flutterEventSink;
@property (assign, nonatomic) BOOL               flutterListening;
@property (assign, nonatomic) BOOL               hasInit;
@end

@implementation LocationPlugin {
    NSViewController *_viewController;
}

+(void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *channel =
        [FlutterMethodChannel methodChannelWithName:@"lyokone/location"
                                    binaryMessenger:registrar.messenger];
    FlutterEventChannel *stream =
        [FlutterEventChannel eventChannelWithName:@"lyokone/locationstream"
                                  binaryMessenger:registrar.messenger];

    LocationPlugin *instance = [[LocationPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [stream setStreamHandler:instance];
}

-(instancetype)initWithViewController:(NSViewController *)viewController {
    self = [super init];

    if (self) {
        self.locationWanted = NO;
        self.permissionWanted = NO;
        self.flutterListening = NO;
        self.hasInit = NO;
    }
    return self;
}

-(void)initLocation {
    if (!(self.hasInit)) {
        self.hasInit = YES;

        if ([CLLocationManager locationServicesEnabled]) {
            self.clLocationManager = [[CLLocationManager alloc] init];
            self.clLocationManager.delegate = self;
            self.clLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        }
    }
}

-(void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    [self initLocation];
    if ([call.method isEqualToString:@"changeSettings"]) {
        if ([CLLocationManager locationServicesEnabled]) {
            NSDictionary *dictionary = @{
                @"0" : @(kCLLocationAccuracyKilometer),
                @"1" : @(kCLLocationAccuracyHundredMeters),
                @"2" : @(kCLLocationAccuracyNearestTenMeters),
                @"3" : @(kCLLocationAccuracyBest),
                @"4" : @(kCLLocationAccuracyBestForNavigation)
            };

            self.clLocationManager.desiredAccuracy =
                [dictionary[call.arguments[@"accuracy"]] doubleValue];
            double distanceFilter = [call.arguments[@"distanceFilter"] doubleValue];
            if (distanceFilter == 0){
                distanceFilter = kCLDistanceFilterNone;
            }
            self.clLocationManager.distanceFilter = distanceFilter;
            result(@1);
        }
    } else if ([call.method isEqualToString:@"getLocation"]) {
        if (![CLLocationManager locationServicesEnabled]) {
            result([FlutterError errorWithCode:@"SERVICE_STATUS_DISABLED" message:@"Failed to get location. Location services disabled" details:nil]);
            return;
        }
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            // Location services are requested but user has denied
            NSString *message = @"The user explicitly denied the use of location services for this "
                "app or location services are currently disabled in Settings.";
            result([FlutterError errorWithCode:@"PERMISSION_DENIED"
                                       message:message
                                       details:nil]);
            return;
        }

        self.flutterResult = result;
        self.locationWanted = YES;

        if ([self isPermissionGranted]) {
            [self.clLocationManager startUpdatingLocation];
        }
    } else if ([call.method isEqualToString:@"hasPermission"]) {
        if ([self isPermissionGranted]) {
            result(@1);
        } else {
            result(@0);
        }
    } else if ([call.method isEqualToString:@"requestPermission"]) {
        if ([self isPermissionGranted]) {
            result(@1);
        } else {
            result(@2);
        }
    } else if ([call.method isEqualToString:@"serviceEnabled"]) {
        if ([CLLocationManager locationServicesEnabled]) {
            result(@1);
        } else {
            result(@0);
        }
    } else if ([call.method isEqualToString:@"requestService"]) {
        if ([CLLocationManager locationServicesEnabled]) {
            result(@1);
        } else {
            NSString *message = @"To use location, go to your Settings App > Privacy > Location Services.";
            NSAlert *alert = [NSAlert init];
            [alert setMessageText:@"Location is Disabled"];
            [alert addButtonWithTitle:@"OK"];
            [alert setInformativeText:message];
            [alert setAlertStyle:NSCriticalAlertStyle];
            [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
                if(returnCode == NSAlertFirstButtonReturn){
                   //确定
                }else if(returnCode == NSAlertSecondButtonReturn){
                   //取消
                }
            }];
            result(@0);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}


-(BOOL) isPermissionGranted {
    //macos dont need request permission

    return YES;
}

-(FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    self.flutterEventSink = events;
    self.flutterListening = YES;

    if ([self isPermissionGranted]) {
        [self.clLocationManager startUpdatingLocation];
    }
    return nil;
}

-(FlutterError*)onCancelWithArguments:(id)arguments {
    self.flutterListening = NO;
    [self.clLocationManager stopUpdatingLocation];
    return nil;
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager*)manager
    didUpdateLocations:(NSArray<CLLocation*>*)locations {
    CLLocation *location = locations.firstObject;
    NSTimeInterval timeInSeconds = [location.timestamp timeIntervalSince1970];
    NSDictionary<NSString*,NSNumber*>* coordinatesDict =
        @{
          @"latitude": @(location.coordinate.latitude),
          @"longitude": @(location.coordinate.longitude),
          @"accuracy": @(location.horizontalAccuracy),
          @"altitude_accuracy": @(location.verticalAccuracy),
          @"altitude": @(location.altitude),
          @"speed": @(location.speed),
          @"speed_accuracy": @0.0,
          @"heading": @(location.course),
          @"time": @(((double) timeInSeconds) * 1000.0)  // in milliseconds since the epoch
        };

    if (self.locationWanted) {
        self.locationWanted = NO;
        self.flutterResult(coordinatesDict);
    }
    if (self.flutterListening) {
        self.flutterEventSink(coordinatesDict);
    } else {
        [self.clLocationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied) {
        // The user denied authorization
        NSLog(@"User denied permissions");
        if (self.permissionWanted) {
            self.permissionWanted = NO;
            self.flutterResult(@0);
        }
    }
}

@end
