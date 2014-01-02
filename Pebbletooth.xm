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
	if(userInfo)
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
		UIImage *replacement = [UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"];
		return [_UILegibilityImageSet imageFromImage:replacement withShadowImage:replacement];
	}

	return %orig;
}
%end