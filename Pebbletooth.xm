#include "BluetoothManager.framework/BluetoothManager.h"

%hook BluetoothManager
-(void)_connectedStatusChanged{
	BOOL pebble = NO;
	for(id device in [self connectedDevices])
		if ([[device name] rangeOfString:@"Pebble"].location != NSNotFound)
			pebble = YES;

	NSLog(@"Pebbletooth: detected connection of Bluetooth device that %@ to be a Pebble (currently connected to: %@).", pebble?@"appears":@"does not appear", [[self connectedDevices] description]);

	[%c(SBStatusBarStateAggregator) _updateBluetoothItem];
	%orig;
}//end statuschanged
%end

%hook SBStatusBarStateAggregator
-(id)init{
	self = %orig;
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateBluetoothItem) name:nil object:nil];
	return self;
}

-(void)dealloc{
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	%orig;
}
%end

@interface UIStatusBarBluetoothItemView
-(id)contentsImage;
-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2;
@end

%hook UIStatusBarBluetoothItemView
-(id)contentsImage{
	NSLog(@"********* contents: %@", %orig);

	//@"/System/Library/Frameworks/UIKit.framework/Pebbletooth.png" 
	return %orig;
}

-(BOOL)updateForNewData:(id)arg1 actions:(int)arg2{
	NSLog(@"********* update: %@, %i, %@", arg1, arg2, %orig?@"YES":@"NO");
	return %orig;
}
%end