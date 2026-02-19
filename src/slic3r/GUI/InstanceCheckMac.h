#ifndef SLIC3R_GUI_INSTANCECHECKMAC_H
#define SLIC3R_GUI_INSTANCECHECKMAC_H

#import <Cocoa/Cocoa.h>

@interface OtherInstanceMessageHandlerMac : NSObject

-(instancetype) init;
-(void) add_observer:(NSString *)version;
-(void) message_update:(NSNotification *)note;
-(void) closing_update:(NSNotification *)note;
-(void) bring_forward;
@end

#endif // SLIC3R_GUI_INSTANCECHECKMAC_H
