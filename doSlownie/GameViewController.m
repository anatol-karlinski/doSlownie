//
//  GameViewController.m
//  doSlownie
//
//  Created by osx on 18/12/15.
//  Copyright (c) 2015 Anatol Karlinski. All rights reserved.
//

#import "GameViewController.h"
#import "ekranMenu.h"
#import "managerSingleton.h"

@interface GameViewController ()
{
    managerSingleton *theManager;
}

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self preloadTextures];
    
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    ekranMenu *scene = [[ekranMenu alloc] initWithSize: self.view.frame.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [skView presentScene:scene];
}

-(void)preloadTextures
{
    theManager = [managerSingleton sharedManager];
    [theManager.atlasContainer addObject:[SKTextureAtlas atlasNamed:@"Textury"]];
    [theManager.globalBackground addObject:[SKSpriteNode spriteNodeWithImageNamed:@"global_mainBackground"]];
    [theManager.globalBackground addObject:[SKSpriteNode spriteNodeWithImageNamed:@"game_background"]];
    for (int i=1;i<=4;i++)[theManager.guideDisplays addObject:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"guide_%d", i]]];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
