#import <Quartz/Quartz.h>
#import <Foundation/NSHashTable.h>

@interface TuioPlugIn : QCPlugIn
{
	@private
	void *_client;
	
	NSMutableDictionary *objectList;
	NSMutableDictionary *cursorList;
	NSUInteger			_udpPort;
	NSNumber *lockObjectList;
	NSNumber *lockCursorList;
	float ratio;
}

- (void)addTuioObject:(int)s_id:(int)f_id:(float)xpos:(float)ypos:(float)angle;
- (void)updateTuioObject:(int)s_id:(int)f_id:(float)xpos:(float)ypos:(float)angle:(float)xspeed:(float)yspeed:(float)rspeed:(float)maccel:(float)raccel;
- (void)removeTuioObject:(int)s_id:(int)f_id;

- (void)addTuioCursor:(int)s_id:(int)f_id:(float)xpos:(float)ypos;
- (void)updateTuioCursor:(int)s_id:(int)f_id:(float)xpos:(float)ypos:(float)xspeed:(float)yspeed:(float)maccel;
- (void)removeTuioCursor:(int)s_id:(int)f_id;

@property(assign) NSArray* outputObjects;
@property(assign) NSArray* outputCursors;

@end
