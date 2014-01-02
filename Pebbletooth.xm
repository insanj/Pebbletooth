#import <objc/runtime.h>
#include <stdlib.h>

/* Detect Pebble connection from BluetoothManager */
@interface BluetoothManager
+ (id)sharedInstance;
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
	objc_setAssociatedObject(self, @"PTShouldOverride", @(pebble), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	%orig;
}
%end

/* Return accurate image for Bluetooth icon request */
@interface _UILegibilityImageSet : NSObject
+(id)imageFromImage:(UIImage *)arg1 withShadowImage:(UIImage *)arg2;
@end

@interface UIStatusBarBluetoothItemView
-(id)contentsImage;
@end

%hook UIStatusBarBluetoothItemView
-(id)contentsImage{
	BOOL shouldOverride = [objc_getAssociatedObject(self, @"PTShouldOverride") boolValue];
	NSLog(@"Pebbletooth: [DEBUG] -contentsImage: orig:%@, shouldOverride:%@", %orig, shouldOverride?@"YES":@"NO");
	return shouldOverride?[_UILegibilityImageSet imageFromImage:[UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"] withShadowImage:[UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"]]:%orig;
}
/*
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	BOOL shouldOverride = [objc_getAssociatedObject(self, @"PTShouldOverride") boolValue];
	NSLog(@"Pebbletooth: [DEBUG] -updateForNewData: arg1:%@, arg2:%i, orig:%@ shouldOverride:%@", arg1, arg2, %orig?@"YES":@"NO", shouldOverride?@"YES":@"NO");
	return shouldOverride?YES:%orig;
}*/
%end