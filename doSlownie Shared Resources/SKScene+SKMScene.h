@import SpriteKit;

@interface SKMScene : SKScene

//Screen Interactions
-(void)screenInteractionStartedAtLocation:(CGPoint)location;
-(void)screenInteractionEndedAtLocation:(CGPoint)location;

@end