#include <stdlib.h>
#import <objc/runtime.h>
#import "../PTHeaders.h"


%hook UIStatusBarBluetoothItemView

%new -(void)setPebbletoothOverride:(NSNotification *)notification{
	BOOL shouldOverride = [[[notification userInfo] objectForKey:@"shouldOverride"] boolValue];
	objc_setAssociatedObject(self, @"PTShouldOverride", @(shouldOverride), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	if(shouldOverride){
		UIImage *replacement = [UIImage kitImageNamed:@"Pebbletooth.png"];
		
		UIGraphicsBeginImageContext(replacement.size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[replacement drawInRect:CGRectMake(0.f, 0.f, replacement.size.width, replacement.size.height)];
		//CGContextRetain(context);
		UIGraphicsEndImageContext();

		CGContext *_imageContext = MSHookIvar<CGContext *>(self, "_imageContext");
		_imageContext = context;
	}
}

%new -(BOOL)getAndSetPebbletoothOverride{
	BOOL pebble = NO;
	for(id device in [[%c(BluetoothManager) sharedInstance] connectedDevices]){
		if([[device name] rangeOfString:@"Pebble"].location != NSNotFound){
			pebble = YES;
			break;
		}
	}

	objc_setAssociatedObject(self, @"PTShouldOverride", @(pebble), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	if(pebble){
		UIImage *replacement = [UIImage kitImageNamed:@"Pebbletooth.png"];
		
		UIGraphicsBeginImageContext(replacement.size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[replacement drawInRect:CGRectMake(0.f, 0.f, replacement.size.width, replacement.size.height)];
		//CGContextRetain(context);
		UIGraphicsEndImageContext();

		CGContext *_imageContext = MSHookIvar<CGContext *>(self, "_imageContext");
		_imageContext = context;
	}

	return pebble;
}

-(id)initWithItem:(id)arg1 data:(id)arg2 actions:(int)arg3 style:(id)arg4{
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setPebbletoothOverride:) name:@"PTUpdate" object:nil];
	[self getAndSetPebbletoothOverride];
	return %orig;
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}

-(id)contentsImage{
	if([objc_getAssociatedObject(self, @"PTShouldOverride") boolValue])
		return [_UILegibilityImageSet imageFromImage:[UIImage kitImageNamed:@"Pebbletooth.png"] withShadowImage:[UIImage kitImageNamed:@"Pebbletooth-Shadow.png"]];

	return %orig;
}

-(id)imageWithShadowNamed:(id)arg1{
	if([objc_getAssociatedObject(self, @"PTShouldOverride") boolValue])
		return [_UILegibilityImageSet imageFromImage:[UIImage kitImageNamed:@"Pebbletooth-Shadow.png"] withShadowImage:[UIImage kitImageNamed:@"Pebbletooth.png"]];

	return %orig;
}

-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	BOOL result = %orig;
	%orig;

	[self getAndSetPebbletoothOverride];
	return result;
}
%end