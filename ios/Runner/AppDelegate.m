#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Flutter uses this channel to open iOS app settings when notification
  // permission has been denied and the system prompt can no longer be shown.
  FlutterViewController* controller =
      (FlutterViewController*)self.window.rootViewController;
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"task_tracker/device_settings"
                                  binaryMessenger:controller.binaryMessenger];

  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"openNotificationSettings" isEqualToString:call.method]) {
      NSURL* settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
      if ([[UIApplication sharedApplication] canOpenURL:settingsUrl]) {
        [[UIApplication sharedApplication] openURL:settingsUrl
                                           options:@{}
                                 completionHandler:nil];
        result(@YES);
      } else {
        result(@NO);
      }
    } else {
      result(FlutterMethodNotImplemented);
    }
  }];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
