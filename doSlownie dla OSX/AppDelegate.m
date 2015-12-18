//
//  AppDelegate.m
//  doSlownie dla OSX
//
//  Created by osx on 18/12/15.
//  Copyright (c) 2015 Anatol Karlinski. All rights reserved.
//

#import "AppDelegate.h"
#import "ekranMenu.h"
#import "managerSingleton.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ekranMenu *scene = [[ekranMenu alloc] initWithSize:CGSizeMake(768.0, 1024.0)];
    
    scene.scaleMode = SKSceneScaleModeFill;
    
    self.skView.showsFPS = NO;
    self.skView.showsNodeCount = NO;
    
    [self preloadTextures];
    
    [self.skView presentScene:scene];
    
}

-(void)preloadTextures
{
    managerSingleton *theManager = [managerSingleton sharedManager];
    [theManager.atlasContainer addObject:[SKTextureAtlas atlasNamed:@"Textury"]];
    [theManager.globalBackground addObject:[SKSpriteNode spriteNodeWithImageNamed:@"global_mainBackground"]];
    [theManager.globalBackground addObject:[SKSpriteNode spriteNodeWithImageNamed:@"game_background"]];
    for (int i=1;i<=4;i++)[theManager.guideDisplays addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"guide_%d", i]]];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
