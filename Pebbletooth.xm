#include <stdlib.h>
#import <objc/runtime.h>
#import "PTHeaders.h"

%hook BluetoothManager
-(void)_connectedStatusChanged{
	BOOL pebble = NO;
	for(id device in [self connectedDevices]){
		if([[device name] rangeOfString:@"Pebble"].location != NSNotFound){
			pebble = YES;
			break;
		}
	}

	NSLog(@"Pebbletooth: detected connection of Bluetooth device that %@ to be a Pebble (currently connected to: %@).", pebble?@"appears":@"does not appear", [[self connectedDevices] description]);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"PTUpdate" object:nil userInfo:@{@"PTShouldOverride" : @(pebble)}];
	%orig;
}
%end

%hook UIStatusBarBluetoothItemView
%new -(void)setPebbletoothOverride:(NSDictionary *)userInfo{
	objc_setAssociatedObject(self, @"PTShouldOverride", userInfo[@"shouldOverride"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4{
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setPebbletoothOverride:) name:@"PTUpdate" object:nil];
	for(id device in [[%c(BluetoothManager) sharedInstance] connectedDevices]){
		if([[device name] rangeOfString:@"Pebble"].location != NSNotFound){
			objc_setAssociatedObject(self, @"PTShouldOverride", @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			break;
		}
	}

	return %orig;
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}

-(id)contentsImage{
	if([objc_getAssociatedObject(self, @"PTShouldOverride") boolValue]){
		NSLog(@"Pebbletooth: [DEBUG] -contentsImage: orig:%@, shouldOverride: YES", %orig);
		UIImage *replacement = [UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"];
		return [_UILegibilityImageSet imageFromImage:replacement withShadowImage:replacement];
	}

	else{
		NSLog(@"Pebbletooth: [DEBUG] -contentsImage: orig:%@, shouldOverride: NO", %orig);
		return %orig;
	}
}

/* commented because this overriding this would probably cancel out above
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	BOOL shouldOverride = [objc_getAssociatedObject(self, @"PTShouldOverride") boolValue];
	NSLog(@"Pebbletooth: [DEBUG] -updateForNewData: arg1:%@, arg2:%i, orig:%@ shouldOverride:%@", arg1, arg2, %orig?@"YES":@"NO", shouldOverride?@"YES":@"NO");
	return shouldOverride?YES:%orig;
}*/
%end