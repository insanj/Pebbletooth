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
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"PTUpdate" object:nil userInfo:@{@"shouldOverride" : pebble?@(2):@(1)}];
	%orig;
}
%end

%hook UIStatusBarBluetoothItemView
%new -(void)setPebbletoothOverride:(NSNotification *)notification{
	objc_setAssociatedObject(self, @"PTShouldOverride", [[notification userInfo] objectForKey:@"shouldOverride"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new -(int)getAndSetPebbletoothOverride{
	NSLog(@"------ fuck ni");
	int result = 1;
	for(id device in [[%c(BluetoothManager) sharedInstance] connectedDevices]){
		if([[device name] rangeOfString:@"Pebble"].location != NSNotFound){
			result = 2;
			break;
		}
	}

	objc_setAssociatedObject(self, @"PTShouldOverride", @(result), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return result;
}


-(id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4{
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setPebbletoothOverride:) name:@"PTUpdate" object:nil];
	for(id device in [[%c(BluetoothManager) sharedInstance] connectedDevices]){
		if([[device name] rangeOfString:@"Pebble"].location != NSNotFound){
			objc_setAssociatedObject(self, @"PTShouldOverride", @(2), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			return %orig;
		}
	}

	objc_setAssociatedObject(self, @"PTShouldOverride", @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return %orig;
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}

-(id)imageFromImageContextClippedToWidth:(float)arg1{
	NSLog(@"Pebbletooth: [DEBUG] -imageFromImage: %f", arg1);

	int savedOverride = [objc_getAssociatedObject(self, @"PTShouldOverride") intValue];
						NSLog(@"--- 1 %i", savedOverride);

	if(savedOverride == 0){
		savedOverride = [self getAndSetPebbletoothOverride];
	}

	if(savedOverride == 2){
		UIImage *replacement = [UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"];
		return [_UILegibilityImageSet imageFromImage:replacement withShadowImage:replacement];
	}

	return %orig;

}

-(id)imageWithShadowNamed:(id)arg1{
	NSLog(@"Pebbletooth: [DEBUG] -imageWithShadow: %@", arg1);
	int savedOverride = [objc_getAssociatedObject(self, @"PTShouldOverride") intValue];
						NSLog(@"--- 2 %i", savedOverride);

	if(savedOverride == 0){
		savedOverride = [self getAndSetPebbletoothOverride];
	}

	if(savedOverride == 2){
		UIImage *replacement = [UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"];
		return [_UILegibilityImageSet imageFromImage:replacement withShadowImage:replacement];
	}

	return %orig;
}

-(id)contentsImage{
	int savedOverride = [objc_getAssociatedObject(self, @"PTShouldOverride") intValue];
					NSLog(@"--- 3 %i", savedOverride);

	if(savedOverride == 0){
		savedOverride = [self getAndSetPebbletoothOverride];
	}

	if(savedOverride == 2){
		UIImage *replacement = [UIImage imageWithContentsOfFile:@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png"];
		return [_UILegibilityImageSet imageFromImage:replacement withShadowImage:replacement];
	}

	return %orig;
}
%end