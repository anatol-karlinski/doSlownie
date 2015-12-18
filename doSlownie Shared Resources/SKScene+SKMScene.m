//
//  SKScene+SKMScene.m
//  doSlownie-Dev-2
//
//  Created by osx on 09/12/15.
//  Copyright © 2015 osx. All rights reserved.
//

#import "SKScene+SKMScene.h"
@interface MyScene : SKMScene
@end
@implementation SKScene (SKMScene)
#if TARGET_OS_IPHONE
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    [self screenInteractionStartedAtLocation:positionInScene];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    [self screenInteractionEndedAtLocation:positionInScene];
}

- (void)touchesCancelled:(NSSet *)touches
               withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    [self screenInteractionEndedAtLocation:positionInScene];
}

-(void)touchesMoved:(NSSet *)touches
          withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self];
    [self screenInteractionDraggedToLocation:positionInScene];
}
#else
-(void)mouseDown:(NSEvent *)theEvent {
    CGPoint positionInScene = [theEvent locationInNode:self];
    [self screenInteractionStartedAtLocation:positionInScene];
}

-(void)mouseUp:(NSEvent *)theEvent
{
    CGPoint positionInScene = [theEvent locationInNode:self];
    [self screenInteractionEndedAtLocation:positionInScene];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    CGPoint positionInScene = [theEvent locationInNode:self];
    [self screenInteractionDraggedToLocation:positionInScene];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    CGPoint positionInScene = [theEvent locationInNode:self];
    [self screenInteractionEndedAtLocation:positionInScene];
}


#endif
/*
-(void)setUserInteraction:(BOOL *)flag{
#if TARGET_OS_IPHONE
    self.view.multipleTouchEnabled = flag;
#else
    
#endif

}
*/
-(void)screenInteractionStartedAtLocation:(CGPoint)location {
    /* Overridden by Subclass */
}

-(void)screenInteractionDraggedToLocation:(CGPoint)location{
    /* Overridden by Subclass */
}

-(void)screenInteractionEndedAtLocation:(CGPoint)location {
    /* Overridden by Subclass */
}
@end
