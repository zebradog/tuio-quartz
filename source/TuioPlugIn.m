/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "TuioPlugIn.h"
#import "QuartzTuioClient.h"

#define	kQCPlugIn_Name				@"TuioClient"
#define	kQCPlugIn_Description		@"receives and interprets TUIO messages"

@implementation TuioPlugIn

/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic outputObjects, outputCursors;

+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
	if([key isEqualToString:@"outputObjects"])
	return [NSDictionary dictionaryWithObjectsAndKeys:@"TuioObjects", QCPortAttributeNameKey, nil];

	if([key isEqualToString:@"outputCursors"])
	return [NSDictionary dictionaryWithObjectsAndKeys:@"TuioCursors", QCPortAttributeNameKey, nil];
	
	return nil;
}

+ (QCPlugInExecutionMode) executionMode
{
	/* This plug-in is a provider (it provides data from an external source) */
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode
{
	/* This plug-in does not depend on the time (time parameter is completely ignored in the -execute:atTime:withArguments: method) */
	return kQCPlugInTimeModeIdle;
}

+ (NSArray*) plugInKeys
{
	/* Return the list of KVC keys corresponding to our internal settings */
	return [NSArray arrayWithObject:@"udpPort"];
}

- (void)addTuioObject:(int)s_id:(int)c_id:(float)xpos:(float)ypos:(float)angle
{	
	@synchronized(lockObjectList) {
		id POOL = [[NSAutoreleasePool alloc] init];
		[objectList setObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: s_id], @"s_id",
							[NSNumber numberWithInt: c_id], @"c_id",
							[NSNumber numberWithDouble: (xpos*2.0f-1.0f)], @"xpos",
							[NSNumber numberWithDouble: ratio*((1.0f-ypos)*2.0f-1.0f)], @"ypos",
							[NSNumber numberWithDouble: angle], @"angle",
						    [NSNumber numberWithDouble: 0.0f ], @"xspeed",
						    [NSNumber numberWithDouble: 0.0f], @"yspeed",
						    [NSNumber numberWithDouble: 0.0f], @"rspeed",
						    [NSNumber numberWithDouble: 0.0f], @"maccel",
						    [NSNumber numberWithDouble: 0.0f], @"raccel", nil] forKey:[NSNumber numberWithInt: s_id]];
		[POOL release];
	}
}

- (void)updateTuioObject:(int)s_id:(int)c_id:(float)xpos:(float)ypos:(float)angle:(float)xspeed:(float)yspeed:(float)rspeed:(float)maccel:(float)raccel
{
	@synchronized(lockObjectList) {
		id POOL = [[NSAutoreleasePool alloc] init];
		[objectList setObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: s_id], @"s_id",
							[NSNumber numberWithInt: c_id], @"c_id",
							[NSNumber numberWithDouble: (xpos*2.0f-1.0f)], @"xpos",
							[NSNumber numberWithDouble: ratio*((1.0f-ypos)*2.0f-1.0f)], @"ypos",
							[NSNumber numberWithDouble: angle], @"angle",
							[NSNumber numberWithDouble: xspeed], @"xspeed",
							[NSNumber numberWithDouble: yspeed], @"yspeed",
							[NSNumber numberWithDouble: rspeed], @"rspeed",
						    [NSNumber numberWithDouble: maccel], @"maccel",
							[NSNumber numberWithDouble: raccel], @"raccel", nil] forKey:[NSNumber numberWithInt: s_id]];
		[POOL release];
	}
}

- (void)removeTuioObject:(int)s_id:(int)c_id
{
    @synchronized(lockObjectList) {
		id POOL = [[NSAutoreleasePool alloc] init];
		[objectList removeObjectForKey:[NSNumber numberWithInt: s_id]];
		[POOL release];
	}
}

- (void)addTuioCursor:(int)s_id:(int)c_id:(float)xpos:(float)ypos
{
	@synchronized(lockCursorList) {
		id POOL = [[NSAutoreleasePool alloc] init];
		[cursorList setObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: s_id], @"s_id",
						   [NSNumber numberWithInt: c_id], @"c_id",
						   [NSNumber numberWithDouble: (xpos*2.0f-1.0f)], @"xpos",
						   [NSNumber numberWithDouble: ratio*((1.0f-ypos)*2.0f-1.0f)], @"ypos", 
						   [NSNumber numberWithDouble: 0.0f], @"xspeed",
						   [NSNumber numberWithDouble: 0.0f], @"yspeed",
						   [NSNumber numberWithDouble: 0.0f], @"maccel", nil] forKey:[NSNumber numberWithInt: s_id]];
		[POOL release];
    }
}

- (void)updateTuioCursor:(int)s_id:(int)c_id:(float)xpos:(float)ypos:(float)xspeed:(float)yspeed:(float)maccel
{
	@synchronized(lockCursorList) {
		id POOL = [[NSAutoreleasePool alloc] init];	
		[cursorList setObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt: s_id], @"s_id",
							[NSNumber numberWithInt: c_id], @"c_id",
							[NSNumber numberWithDouble: (xpos*2.0f-1.0f)], @"xpos",
							[NSNumber numberWithDouble: ratio*((1.0f-ypos)*2.0f-1.0f)], @"ypos", 
							[NSNumber numberWithDouble: xspeed], @"xspeed",
							[NSNumber numberWithDouble: yspeed], @"yspeed",
							[NSNumber numberWithDouble: maccel], @"maccel", nil] forKey:[NSNumber numberWithInt: s_id]];
		[POOL release];
	}
}

- (void)removeTuioCursor:(int)s_id:(int)c_id
{
	@synchronized(lockCursorList) {
		id POOL = [[NSAutoreleasePool alloc] init];
		[cursorList removeObjectForKey:[NSNumber numberWithInt: s_id]];
		[POOL release];
	}
}

- (QCPlugInViewController*) createViewController
{
	/* Create a QCPlugInViewController to handle the user-interface to edit the our internal settings */
	return [[QCPlugInViewController alloc] initWithPlugIn:self viewNibName:@"TuioClientSettings"];
}

- (BOOL) validateUdpPort:(id*)ioValue error:(NSError**)outError
{
	/* Make sure the "udpPort" new value is valid */
	if([(NSNumber*)*ioValue integerValue] < 1024)
		*ioValue = [NSNumber numberWithUnsignedInteger:3333];
	
	return YES;
}

- (void) setUdpPort:(NSUInteger)newPort
{
	_udpPort = newPort;
}

- (NSUInteger) udpPort
{
	return _udpPort;
}

@end

@implementation TuioPlugIn (Execution)


- (BOOL) startExecution:(id<QCPlugInContext>)context
{
	ratio = 1.0f;	
	objectList = [[NSMutableDictionary alloc] init];
	cursorList = [[NSMutableDictionary alloc] init];
    lockObjectList=[NSNumber numberWithInt: 1];
	lockCursorList=[NSNumber numberWithInt: 1];
		
	_client = [[QuartzTuioClient alloc] init:_udpPort];
	[(QuartzTuioClient*)_client addTuioListener:self];
	[(QuartzTuioClient*)_client start];
	return YES;
}

- (BOOL) execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments
{
	/* This method is called by Quartz Composer whenever the plug-in needs to recompute its result: retrieve the input string and compute the output string */

	NSRect dim = [context bounds];
	ratio = (float)dim.size.height/(float)dim.size.width;

	@synchronized(lockObjectList) {
		self.outputObjects = [objectList allValues];
	}
	@synchronized(lockCursorList){
		self.outputCursors = [cursorList allValues];
	}
	    
	return YES;
}

- (void) stopExecution:(id<QCPlugInContext>)context
{
	[(QuartzTuioClient*)_client stop];
	[(QuartzTuioClient*)_client removeTuioListener];
	[(QuartzTuioClient*)_client dealloc];

	[objectList dealloc];
	[cursorList dealloc];
}

@end
