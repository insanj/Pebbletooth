#import <objc/runtime.h>
#include <stdlib.h>

/* Make sure tweak understand inter-app communications and image-set classes */
@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

/* Detect Pebble connection from BluetoothManager */
@interface BluetoothManager
+(id)sharedInstance;
-(void)_connectedStatusChanged;
-(id)connectedDevices;
@end

%hook BluetoothManager
-(void)_connectedStatusChanged{
	BOOL pebble = NO;
	for(id device in [self connectedDevices])
		if ([[device name] rangeOfString:@"Pebble"].location != NSNotFound)
			pebble = YES;

	NSLog(@"Pebbletooth: detected connection of Bluetooth device that %@ to be a Pebble (currently connected to: %@).", pebble?@"appears":@"does not appear", [[self connectedDevices] description]);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"PTUpdate" object:nil userInfo:@{@"overrideUpdate" : @(pebble)}];
	%orig;
}
%end

@interface UIStatusBarItemView : UIView
-(id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4;
-(void)dealloc;
@end

@interface UIStatusBarBluetoothItemView : UIStatusBarItemView
-(id)contentsImage;
@end

@interface _UILegibilityImageSet : NSObject
+(id)imageFromImage:(UIImage *)arg1 withShadowImage:(UIImage *)arg2;
@end

%hook UIStatusBarBluetoothItemView
%new -(void)setPebbletoothOverride:(NSDictionary *)userInfo{
	objc_setAssociatedObject(self, @"PTShouldOverride", userInfo[@"shouldOverride"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4{
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setPebbletoothOverride:) name:@"PTUpdate" object:nil];
	return %orig;
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}

-(id)contentsImage{
	BOOL shouldOverride = [objc_getAssociatedObject(self, @"PTShouldOverride") boolValue];
	NSLog(@"Pebbletooth: [DEBUG] -contentsImage: orig:%@, shouldOverride:%@", %orig, shouldOverride?@"YES":@"NO");
	return shouldOverride?[_UILegibilityImageSet imageFromImage:[UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"] withShadowImage:[UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"]]:%orig;
}

/* commented because this overriding this would probably cancel out above
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	BOOL shouldOverride = [objc_getAssociatedObject(self, @"PTShouldOverride") boolValue];
	NSLog(@"Pebbletooth: [DEBUG] -updateForNewData: arg1:%@, arg2:%i, orig:%@ shouldOverride:%@", arg1, arg2, %orig?@"YES":@"NO", shouldOverride?@"YES":@"NO");
	return shouldOverride?YES:%orig;
}*/
%end