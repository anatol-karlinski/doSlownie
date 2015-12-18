//
//  ekranGryScena.m
//  ProjektW
//
//  Created by Anatol on 25/01/14.
//  Copyright (c) 2014 Anatol. All rights reserved.
//

#import "ekranGry.h"
#import "ekranWyboruPoziomu.h"
#import "managerSingleton.h"
#import "SKScene+SKMScene.h"

#define SZEROKOSC_EKRANU 768.0
#define WYSOKOSC_PANELU 148.0
#define SZEROKOSC_LITERY 112.0
#define WYSOKOSC_LITERY 96.0
#define GRANICA_DOTYKU_Y 248.0
#define ZAPISZ_BAZE_DANYCH [_defaults synchronize];

@interface ekranGry ()
{
    managerSingleton *theManager;
}

@property BOOL contentCreated;
@property BOOL resetPressed;
@property BOOL zatwierdzPressed;
@property BOOL ostatniPressed;

@property (nonatomic, strong) SKSpriteNode *wybranaNode;
@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic, strong) SKLabelNode *punkty;
@property (nonatomic, strong) NSMutableArray *dolnyPanel;
@property (nonatomic, strong) NSMutableArray *gornyPanel;
@property (nonatomic, strong) NSMutableArray *rozwiazania;
@property (nonatomic, strong) NSMutableArray *podaneOdpowiedzi;
@property (nonatomic, strong) NSString *ostatniaPodanaOdpowiedz;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSArray *listaLiter;

@end

@implementation ekranGry

@synthesize listaLiter;

CGPoint sprawdzenieCzyTap;
CGPoint wolneMiejsceNaGornymPanelu;
int indexWolnegoMiejsca;
float liczbaPunktow;
float pozostalePytania;
long liczbaPunktowNaPoczatku;
long liczbaPunktowNaKoncu;
float iloscPytan;

#pragma mark Budowa i dekonstrukcja sceny

-(void)didMoveToView:(SKView *)view {
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

-(void)createSceneContents
{
    self.scaleMode = SKSceneScaleModeFill;
    #if TARGET_OS_IPHONE
    self.view.multipleTouchEnabled = NO;
    #endif
    theManager = [managerSingleton sharedManager];
    _poziom = theManager.nazwaPoziomu;
    _defaults = [NSUserDefaults standardUserDefaults];
    NSString* sciezkaDB = [[NSBundle mainBundle] pathForResource:_poziom ofType:@"plist"];
    NSDictionary* db = [NSDictionary dictionaryWithContentsOfFile:sciezkaDB];
    NSArray *rozwiazania = [db valueForKeyPath:@"odpowiedzi"];
    listaLiter = [self remix: [[db valueForKeyPath:@"litery"] componentsSeparatedByString:@";"]];
    NSArray *odpowiedzi = [_defaults objectForKey:_poziom];
    pozostalePytania = (int)[rozwiazania count];
    _ostatniaPodanaOdpowiedz = @"";
    liczbaPunktow = 0;
    _podaneOdpowiedzi = [NSMutableArray array];
    _dolnyPanel = [[NSMutableArray alloc]init];
    _gornyPanel = [[NSMutableArray alloc]init];
    _rozwiazania = [NSMutableArray arrayWithArray:rozwiazania];
    
    SKTextureAtlas *atlas = [theManager.atlasContainer objectAtIndex:0];
    [self addChild:[self wroc:atlas]];
    [self addChild:[self background:[theManager.globalBackground objectAtIndex:1]]];
    [self addChild:[self guzikReset:atlas]];
    [self addChild:[self guzikZatwierdz:atlas]];
    [self addChild:[self guzikOstatnie:atlas]];
    [self addChild:[self topBar:atlas]];
    [self dodajLitery:atlas];
    [self addChild:[self tytolPoziomu]];
    [self dodajRozwiazania:_rozwiazania:atlas];
    
    if ([odpowiedzi count] != 0) for (NSString * odpowiedz in odpowiedzi) [self wyswietlenieOdpowiedzi:odpowiedz];
    
    liczbaPunktowNaPoczatku = [odpowiedzi count];
    NSString *defaultsOstatnieSlowo = [_poziom stringByAppendingString:@"_slowo"];
    _ostatniaPodanaOdpowiedz = [_defaults objectForKey:defaultsOstatnieSlowo];
}

-(NSArray *)remix :(NSArray *)array
{
    NSMutableArray *localArray = [NSMutableArray arrayWithArray:array];
    int count = (int)[localArray count];
    for(int i = 0; i < count; ++i) {
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [localArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return [NSArray arrayWithArray:localArray];
}
#if TARGET_OS_IPHONE
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [self destroySceneContents];
}
#endif
-(void)destroySceneContents
{
    [_defaults setObject:_podaneOdpowiedzi forKey:_poziom];
    NSString *defaultsPunktyZadania = [_poziom stringByAppendingString:@"_punkty"];
    float podaneOdpowiedzi = [_podaneOdpowiedzi count];
    float procentUkonczenia = podaneOdpowiedzi/pozostalePytania;
    NSString *punktyDoZapisu;
    
    if (procentUkonczenia == 0) punktyDoZapisu = @"0";
    else if (procentUkonczenia <= 0.50) punktyDoZapisu = @"1";
    else if (procentUkonczenia <= 0.75) punktyDoZapisu = @"2";
    else punktyDoZapisu = @"3";
    
    [_defaults setObject:punktyDoZapisu forKey:defaultsPunktyZadania];
    
    liczbaPunktowNaKoncu = [_podaneOdpowiedzi count];
    
    if (liczbaPunktowNaKoncu != liczbaPunktowNaPoczatku)
    {
        NSString *a0 = [theManager.nazwaZestawu stringByAppendingString:@"_punkty"];
        long a1 = (liczbaPunktowNaKoncu - liczbaPunktowNaPoczatku);
        long a2 = [[_defaults objectForKey:a0] integerValue];
        NSString *a4 = [NSString stringWithFormat:@"%li", a1+a2];
        [_defaults setObject:a4 forKey:a0];
    }
    
    NSString *defaultsOstatnieSlowo = [_poziom stringByAppendingString:@"_slowo"];
    [_defaults setObject:_ostatniaPodanaOdpowiedz forKey:defaultsOstatnieSlowo];
    
    ZAPISZ_BAZE_DANYCH
    
    _wybranaNode = nil;
    _background = nil;
    _punkty = nil;
    _dolnyPanel = nil;
    _gornyPanel = nil;
    _rozwiazania = nil;
}

#pragma mark Interakcja z użytkownikiem

-(void)screenInteractionStartedAtLocation:(CGPoint)location
{
    CGPoint pozycjaDotykuNaScenie = location;
    SKSpriteNode *dotknietaNode = (SKSpriteNode *)[self nodeAtPoint:pozycjaDotykuNaScenie];
    NSString *imieDotknietegoNode = dotknietaNode.name;
    NSArray* name = [dotknietaNode.name componentsSeparatedByString:@"_"];

    if ([imieDotknietegoNode isEqualToString:@"wroc"] || [imieDotknietegoNode isEqualToString:@"ekranWygranej"])
    {
        [self wyjdz];
    }
    else if ([[name objectAtIndex:0] isEqualToString:@"ruszalne"] || [[name objectAtIndex:0] isEqualToString:@"literka"])
    {
        dotknietaNode =  (SKSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"ruszalne_%@", [name objectAtIndex:1]]];
        if(dotknietaNode != nil){
        _wybranaNode = dotknietaNode;
        dotknietaNode.zPosition = 4;
        [dotknietaNode setScale:1.07];
        sprawdzenieCzyTap = _wybranaNode.position;
        if (dotknietaNode.position.y < WYSOKOSC_PANELU) [_dolnyPanel replaceObjectAtIndex:[_dolnyPanel indexOfObject:dotknietaNode] withObject:@"0"];
        else
        {
            indexWolnegoMiejsca = (int)[_gornyPanel indexOfObject:dotknietaNode];
            [_gornyPanel replaceObjectAtIndex:indexWolnegoMiejsca withObject:@"0"];
            wolneMiejsceNaGornymPanelu = CGPointMake(dotknietaNode.position.x, dotknietaNode.position.y);
        }
        }
    }
    else if([imieDotknietegoNode isEqualToString:@"reset"])
    {
        SKSpriteNode *reset = (SKSpriteNode *)[self childNodeWithName:@"reset"];
        _resetPressed = YES;
        [reset setTexture:[SKTexture textureWithImageNamed:@"wyczyscDown_gra"]];
        [self resetLiter];
        _wybranaNode = Nil;
    }
    else if([imieDotknietegoNode isEqualToString:@"zatwierdz"])
    {
        [self sprawdzenieOdpowiedzi:NO];
        _wybranaNode = Nil;
    }
    else if([imieDotknietegoNode isEqualToString:@"ostatnie"])
    {
        [self ostatniaOdpowiedz:NO];
        _wybranaNode = Nil;
    }
    else _wybranaNode = Nil;
}

-(void)screenInteractionDraggedToLocation:(CGPoint)location
{
    CGPoint pozycjaZlapanejNode = [_wybranaNode position];
    _wybranaNode.position = location;
    NSMutableArray *zlapaneNodes = [NSMutableArray arrayWithArray:[self nodesAtPoint:pozycjaZlapanejNode]];
    NSArray *name = [_wybranaNode.name componentsSeparatedByString:@"_"];
    if (zlapaneNodes.count >= 3 && [[name objectAtIndex:0] isEqualToString:@"ruszalne"])
    {
        [zlapaneNodes removeObject:_wybranaNode];
        [zlapaneNodes removeObject:_background];
        SKSpriteNode *testowanaNode = [zlapaneNodes objectAtIndex:0];
        NSArray *testowanaNodeName = [testowanaNode.name componentsSeparatedByString:@"_"];
        if (testowanaNode.position.y < WYSOKOSC_PANELU && [[testowanaNodeName objectAtIndex:0] isEqualToString:@"ruszalne"])
        {
            _wybranaNode.name = [NSString stringWithFormat:@"nieruszalne_%@", [name objectAtIndex:1]];
            [self przemiescLiteryNaDolnymPanelu:(int)[_dolnyPanel indexOfObject:testowanaNode]];
        }
        else if ([[testowanaNodeName objectAtIndex:0] isEqualToString:@"ruszalne"])
        {
            _wybranaNode.name = [NSString stringWithFormat:@"nieruszalne_%@", [name objectAtIndex:1]];
            indexWolnegoMiejsca = (int)[_gornyPanel indexOfObject:testowanaNode];
            wolneMiejsceNaGornymPanelu = CGPointMake(testowanaNode.position.x, testowanaNode.position.y);
            [self przemiescLiteryNaGornymPanelu:(int)[_gornyPanel indexOfObject:testowanaNode]];
        }
    }
}

-(void)screenInteractionEndedAtLocation:(CGPoint)location
{
    _wybranaNode.zPosition = 1;
    [_wybranaNode setScale:1.0];
    
    if (_wybranaNode.position.y <= WYSOKOSC_PANELU && _wybranaNode!=nil)[self umiescLiteryNaDolnymPanelu];
    else if (_wybranaNode!=nil)[self umiescLiteryNaGornymPanelu];
    
    if (_resetPressed==YES)
    {
        _resetPressed=NO;
        SKSpriteNode *reset = (SKSpriteNode *)[self childNodeWithName:@"reset"];
        [reset setTexture:[SKTexture textureWithImageNamed:@"wyczyscUp_gra"]];
    }
    else if (_zatwierdzPressed==YES)
    {
        _zatwierdzPressed=NO;
        SKSpriteNode *reset = (SKSpriteNode *)[self childNodeWithName:@"zatwierdz"];
        [reset setTexture:[SKTexture textureWithImageNamed:@"zatwierdzUp_gra"]];
    }
    else if (_ostatniPressed==YES)
    {
        _ostatniPressed=NO;
        SKSpriteNode *reset = (SKSpriteNode *)[self childNodeWithName:@"ostatnie"];
        [reset setTexture:[SKTexture textureWithImageNamed:@"ostatniUp_gra"]];
    }
}
#if !TARGET_OS_IPHONE
- (void)keyDown:(NSEvent *)event {
    NSString *characters = [event characters];
    if([characters isEqualToString:@"\r"])[self sprawdzenieOdpowiedzi:YES];
    else if([characters isEqualToString:@"\x7f"])[self resetLiter];
    else if([characters isEqualToString:@"="])[self ostatniaOdpowiedz:YES];
    else if([characters isEqualToString:@"\x1b"])[self wyjdz];
    else if([listaLiter containsObject:characters])
    {
        SKSpriteNode *node = (SKSpriteNode *)[self childNodeWithName:
                                              [NSString stringWithFormat:@"ruszalne_%@",characters]];
        if([_dolnyPanel containsObject:node]){
        [_dolnyPanel replaceObjectAtIndex:[_dolnyPanel indexOfObject:node] withObject:@"0"];
        _wybranaNode.zPosition = 4;
        int prawaGranica = self.frame.size.width/2 + (_gornyPanel.count) * SZEROKOSC_LITERY/2;
        SKAction *umiescLitere = [SKAction moveTo:CGPointMake(prawaGranica+56, 3*WYSOKOSC_PANELU/2) duration:0.1];
        [_gornyPanel addObject:node];
        [node runAction:umiescLitere completion:^(void)
         {
             node.zPosition = -1;
             [self wyrownajGornyPanel];
         }];
        }
    }
}
#endif
-(BOOL)jestTap
{
    if (sprawdzenieCzyTap.x == _wybranaNode.position.x) return YES;
    else return NO;
}

-(void)pokazEkranWygranej
{
    [self addChild:[self ekranWygranej]];
    SKNode *ekranWygranej = [self childNodeWithName:@"//ekranWygranej"];
    NSArray *elementyEkranuWygranej = [ekranWygranej children];
    int i = 0;
    for (SKNode* node in elementyEkranuWygranej)
    {
        if([node.name containsString:@"gwiazda"])
        {
            SKAction *powieksz = [SKAction scaleTo:2.2 duration:0.3];
            SKAction *zmniejsz = [SKAction scaleTo:2.0 duration:0.1];
            SKAction *delay = [SKAction waitForDuration:0.2*i];
            SKAction *pojawGwiazde = [SKAction sequence:@[delay, powieksz, zmniejsz]];
            [node runAction:pojawGwiazde];
            i++;
        }
    }
}

-(void)wyjdz
{
    ekranWyboruPoziomu *wyborPoziomu = [[ekranWyboruPoziomu alloc] initWithSize: self.frame.size];
    SKTransition *przejscie = [SKTransition pushWithDirection:SKTransitionDirectionRight duration:0.6];
    [self destroySceneContents];
    [self.scene.view presentScene:wyborPoziomu transition:przejscie];
}

#pragma mark Elementy interfejsu

-(void)dodajLitery:(SKTextureAtlas *)atlas
{
    for (int i=0; i<6; i++)
    {
        NSString *texturaLitery = [listaLiter objectAtIndex:i];
        SKSpriteNode *litera = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"gra_litera"]];
        NSString *name = [NSString stringWithFormat:@"ruszalne_%@", texturaLitery];
        [litera setName:name];
        //[litera setAccessibilityHint:@"ruszalne"];
        //[litera setAccessibilityLabel:texturaLitery];
        float pozycjaLitery = 48+i*112;
        [litera setPosition:CGPointMake(pozycjaLitery + SZEROKOSC_LITERY/2 , WYSOKOSC_PANELU/2)];
        [litera setZPosition:0];
        
        SKLabelNode *literka = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Medium"];
        [literka setText:[texturaLitery uppercaseString]];
        [literka setFontColor:[SKColor colorWithRed:0.2862 green:0.3215 blue:0.3490 alpha:1.0]];
        [literka setFontSize:34.0];
        name = [NSString stringWithFormat:@"literka_%@", texturaLitery];
        [literka setName:name];
        
        [litera addChild:literka];
        [literka setPosition:CGPointMake(0, -10.0)];
        [literka setZPosition:1];
        [self addChild:litera];
        
        [_dolnyPanel addObject:litera];
    }
}

-(void)dodajRozwiazania:(NSArray *)rozwiazania :(SKTextureAtlas *)atlas
{
    CGPoint pounktPierwszegoTile = CGPointMake(50.0, self.size.height-114.0);
    for (int i=0; i<[rozwiazania count]; i++)
    {
        NSString *rozwiazanie  = [rozwiazania objectAtIndex:i];
        for (int j=0; j<rozwiazanie.length; j++)
        {
            CGPoint punktTile;
            if (i<10) punktTile = CGPointMake(pounktPierwszegoTile.x + 46.0*j, pounktPierwszegoTile.y - 54.0*i);
            else if (i<20) punktTile = CGPointMake(pounktPierwszegoTile.x + 195.0 + 46.0*j, pounktPierwszegoTile.y - 54.0*(i-10));
            else punktTile = CGPointMake(pounktPierwszegoTile.x + 440.0 + 46.0*j, pounktPierwszegoTile.y - 54.0*(i-20));
            
            SKSpriteNode *tile = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"gra_tile"]];
            [tile setPosition:punktTile];
            [tile setZPosition:0];
            [self addChild:tile];
            
            SKLabelNode *litera = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Medium"];
            [litera setFontColor:[SKColor blackColor]];
            [litera setText:[[rozwiazanie substringWithRange:NSMakeRange(j, 1)]uppercaseString]];
            [litera setFontSize:20.0];
            [litera setZPosition:1];
            
            NSString *nazwaNodeLitery = [rozwiazanie stringByAppendingString:[NSString stringWithFormat:@"_%i", j]];
            [litera setName:nazwaNodeLitery];
            [litera setAlpha:0.0];
            [self addChild:litera];
            [litera setPosition:CGPointMake(punktTile.x, punktTile.y-6.0)];
            
            if (j==0)
            {
                NSString *nazwaTexturyBG;
                switch (rozwiazanie.length)
                {
                    case 3:
                        nazwaTexturyBG = @"tileBg3_gra";
                        break;
                    case 4:
                        nazwaTexturyBG = @"tileBg4_gra";
                        break;
                    case 5:
                        nazwaTexturyBG = @"tileBg5_gra";
                        break;
                    case 6:
                        nazwaTexturyBG = @"tileBg6_gra";
                        break;
                    default:
                        break;
                }
                SKSpriteNode *BG = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:nazwaTexturyBG]];
                [tile addChild:BG];
                [BG setZPosition:-1];
                BG.anchorPoint = CGPointMake(0.0,0.0);
                [BG setPosition:CGPointMake(-25.0 , -24.0)];
            }
            
        }
    }
}

-(SKSpriteNode *)topBar:(SKTextureAtlas *)atlas
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"global_topBar"]];
    [node setAnchorPoint:CGPointMake(1.0, 1.0)];
    [node setPosition:CGPointMake(self.size.width, self.size.height-4.0)];
    return node;
}

-(SKSpriteNode *)background:(SKSpriteNode *)node
{
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithTexture:(SKTexture *)[node texture]];
    [bg setPosition:CGPointZero];
    [bg setAnchorPoint:CGPointMake(0.0, 0.0)];
    [bg setZPosition:-2];
    return bg;
}

-(SKSpriteNode *)guzikReset:(SKTextureAtlas *)atlas
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"wyczyscUp_gra"]];
    [node setPosition: CGPointMake(self.frame.size.width-121, 340.0)];
    [node setName: @"reset"];
    [node setZPosition: 0];
    return node;
}

-(SKSpriteNode *)guzikZatwierdz:(SKTextureAtlas *)atlas
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"zatwierdzUp_gra"]];
    [node setPosition: CGPointMake(121.0, 340.0)];
    [node setName: @"zatwierdz"];
    [node setZPosition: 0];
    return node;
}

-(SKSpriteNode *)guzikOstatnie:(SKTextureAtlas *)atlas
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"ostatniUp_gra"];
    [node setPosition: CGPointMake(self.frame.size.width/2, 340.0)];
    [node setName: @"ostatnie"];
    [node setZPosition: 0];
    return node;
}

-(SKLabelNode *)punkty
{
    _punkty = [SKLabelNode labelNodeWithFontNamed:@"SourceSansPro-Bold"];
    [_punkty setText:@"Pozostało: 15"];
    [_punkty setName:@"punkty"];
    [_punkty setVerticalAlignmentMode:1];
    [_punkty setZPosition:3];
    [_punkty setPosition:CGPointMake(self.frame.size.width/2, WYSOKOSC_PANELU*2 + 34.0)];
    [_punkty setFontColor:[SKColor colorWithRed:0.9955 green:0.6078 blue:0.3137 alpha:1.0]];
    [_punkty setFontSize:20.0];
    return _punkty;
}

-(SKLabelNode *)tytolPoziomu
{
    SKLabelNode *node = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Medium"];
    [node setFontColor:[SKColor colorWithRed:0.8078 green:0.8313 blue:0.8627 alpha:1.0]];
    [node setText:[NSString stringWithFormat:@"Poziom %li", (long)theManager.numerPoziomu]];
    [node setFontSize:26.0];
    [node setZPosition:4];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height-46.0)];
    return node;
}

-(SKSpriteNode *)wroc:(SKTextureAtlas *)atlas
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"global_backButton"]];
    [node setAnchorPoint:CGPointMake(0.0, 1.0)];
    [node setPosition:CGPointMake(16.0, self.frame.size.height-16.0)];
    [node setName:@"wroc"];
    [node setZPosition:3];
    return node;
}

-(SKSpriteNode *)ekranWygranej
{
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:0.08 alpha:0.85] size: self.scene.size];
    [background setAnchorPoint: CGPointMake(0.0, 0.0)];
    [background setZPosition:6];
    [background setName:@"ekranWygranej"];
    for (int i = 0; i<3; i++)
    {
        SKSpriteNode *gwiazda = [SKSpriteNode spriteNodeWithImageNamed:@"zestawy_starIn"];
        [gwiazda setScale:0.0];
        [gwiazda setPosition:CGPointMake(self.scene.size.width/2 - 102.0 + 102.0*i, self.scene.size.height/2+50.0)];
        [gwiazda setName:@"gwiazda"];
        [background addChild:gwiazda];
    }
    SKLabelNode *gratulacje = [SKLabelNode labelNodeWithFontNamed:@"STHeitiTC-Medium"];
    [gratulacje setFontSize:70.0];
    [gratulacje setFontColor:[SKColor whiteColor]];
    [gratulacje setPosition:CGPointMake(self.scene.size.width/2, self.scene.size.height/2 + 180.0)];
    [gratulacje setText:@"Gratulacje!"];
    [background addChild:gratulacje];
    
    SKLabelNode *ukonczono = [SKLabelNode labelNodeWithFontNamed:@"STHeitiTC-Medium"];
    [ukonczono setFontSize:18.0];
    [ukonczono setFontColor:[SKColor whiteColor]];
    [ukonczono setPosition:CGPointMake(self.scene.size.width/2, self.scene.size.height/2+ 125.0)];
    [ukonczono setText:@"WSZYSTKIE ODPOWIEDZI ODNALEZIONE"];
    [background addChild:ukonczono];
    
    return background;
}

#pragma mark Panel liter: poruszanie

-(void)przemiescLiteryNaDolnymPanelu:(int)pozycjaDotknietegoNode
{
    int pozycjaZera = 0;
    for (int i=0; i<6; i++)
    {
        if (i<(6 - pozycjaDotknietegoNode) && [[_dolnyPanel objectAtIndex:pozycjaDotknietegoNode + i] isEqual:@"0"])
        {
            pozycjaZera = pozycjaDotknietegoNode + i;
            i=7;
        };
        if (i<pozycjaDotknietegoNode && [[_dolnyPanel objectAtIndex:pozycjaDotknietegoNode -i] isEqual:@"0"])
        {
            pozycjaZera = pozycjaDotknietegoNode - i;
            i=7;
        };
    }
    if (pozycjaZera > pozycjaDotknietegoNode)
    {
        for (int i=0; i<pozycjaZera - pozycjaDotknietegoNode; i++)
        {
            SKAction *ruszLitere = [SKAction moveByX:SZEROKOSC_LITERY y:0 duration:0.1];
            SKSpriteNode *literaDoRuszenia = [_dolnyPanel objectAtIndex:pozycjaZera - i - 1];
            [_dolnyPanel exchangeObjectAtIndex:pozycjaZera - i - 1 withObjectAtIndex:pozycjaZera - i];
            [literaDoRuszenia runAction:ruszLitere];
        }
    }
    else
    {
        for (int i=0; i<pozycjaDotknietegoNode - pozycjaZera; i++)
        {
            SKAction *ruszLitere = [SKAction moveByX:-SZEROKOSC_LITERY y:0 duration:0.1];
            SKSpriteNode *literaDoRuszenia = [_dolnyPanel objectAtIndex:pozycjaZera + i + 1];
            [_dolnyPanel exchangeObjectAtIndex:pozycjaZera + i + 1 withObjectAtIndex:pozycjaZera + i];
            [literaDoRuszenia runAction:ruszLitere];
        }
    }
    [self zakonczAnimacje:NO :NO: 0.1];
}

-(void)przemiescLiteryNaGornymPanelu:(int)pozycjaDotknietegoNode
{
    int pozycjaZera=0;
    bool jestZero = NO;
    if ([_gornyPanel containsObject:@"0"])
    {
        pozycjaZera = (int)[_gornyPanel indexOfObject:@"0"];
        jestZero = YES;
    }
    if (jestZero == NO)
    {
        if (pozycjaDotknietegoNode <  _gornyPanel.count - pozycjaDotknietegoNode )
        {
            for (int i = 0; i < pozycjaDotknietegoNode+1; i++)
            {
                SKSpriteNode *nodeDoRuszenia = [_gornyPanel objectAtIndex:i];
                SKAction *ruszNode = [SKAction moveByX:-SZEROKOSC_LITERY y:0 duration:0.1];
                [nodeDoRuszenia runAction:ruszNode];
            };
            [_gornyPanel insertObject:@"0" atIndex:pozycjaDotknietegoNode+1];
            indexWolnegoMiejsca++;
        }
        else
        {
            for (int i = 0; i < _gornyPanel.count - pozycjaDotknietegoNode; i++)
            {
                SKSpriteNode *nodeDoRuszenia = [_gornyPanel objectAtIndex:_gornyPanel.count - 1 - i];
                SKAction *ruszNode = [SKAction moveByX:SZEROKOSC_LITERY y:0 duration:0.1];
                [nodeDoRuszenia runAction:ruszNode];
            }
            [_gornyPanel insertObject:@"0" atIndex:pozycjaDotknietegoNode];
        }
    }
    else if (pozycjaZera > pozycjaDotknietegoNode)
    {
        for (int i=0; i<pozycjaZera - pozycjaDotknietegoNode; i++)
        {
            SKAction *ruszLitere = [SKAction moveByX:SZEROKOSC_LITERY y:0 duration:0.1];
            SKSpriteNode *literaDoRuszenia = [_gornyPanel objectAtIndex:pozycjaZera - 1 - i];
            [literaDoRuszenia runAction:ruszLitere];
        }
        [_gornyPanel removeObjectAtIndex:pozycjaZera];
        [_gornyPanel insertObject:@"0" atIndex:pozycjaDotknietegoNode];
        
    }
    else
    {
        for (int i=0; i<pozycjaDotknietegoNode - pozycjaZera; i++)
        {
            SKAction *ruszLitere = [SKAction moveByX:-SZEROKOSC_LITERY y:0 duration:0.1];
            SKSpriteNode *literaDoRuszenia = [_gornyPanel objectAtIndex:pozycjaZera + 1 + i];
            [literaDoRuszenia runAction:ruszLitere];
        }
        [_gornyPanel removeObjectAtIndex:pozycjaZera];
        [_gornyPanel insertObject:@"0" atIndex:pozycjaDotknietegoNode];
    }
    [self zakonczAnimacje:NO :NO: 0.1];
}

#pragma mark Panel liter: dokowanie

-(void)umiescLiteryNaDolnymPanelu
{
#if TARGET_OS_IPHONE
    self.view.userInteractionEnabled = NO;
#else
    self.userInteractionEnabled = NO;
#endif
    if ([self jestTap])
    {
        _wybranaNode.zPosition = 4;
        int prawaGranica = self.frame.size.width/2 + (_gornyPanel.count) * SZEROKOSC_LITERY/2;
        SKAction *umiescLitere = [SKAction moveTo:CGPointMake(prawaGranica+56, 3*WYSOKOSC_PANELU/2) duration:0.1];
        [_gornyPanel addObject:_wybranaNode];
        [_wybranaNode runAction:umiescLitere completion:^(void)
         {
             _wybranaNode.zPosition = -1;
         }];
    }
    else
    {
        SKAction *dokujLitere = [SKAction moveTo:CGPointMake([self konwertujPozycjeNaPrzedzial:(int)_wybranaNode.position.x], WYSOKOSC_PANELU/2) duration:0.1];
        int docelowyIndex = [self konwertujPozycjeNaIndex:(int)_wybranaNode.position.x];
        
        if ([[_dolnyPanel objectAtIndex:docelowyIndex]isEqual:@"0"]) [_dolnyPanel replaceObjectAtIndex:docelowyIndex withObject:_wybranaNode];
        else
        {
            [self przemiescLiteryNaDolnymPanelu:docelowyIndex];
            [_dolnyPanel replaceObjectAtIndex:docelowyIndex withObject:_wybranaNode];
        }
        
        [_wybranaNode runAction:dokujLitere];
    }
    
    [self zakonczAnimacje:NO :YES :0.1];
    [self wyrownajGornyPanel];
}

-(void)umiescLiteryNaGornymPanelu
{
#if TARGET_OS_IPHONE
    self.view.userInteractionEnabled = NO;
#else
    self.userInteractionEnabled = NO;
#endif
    if ([self jestTap])
    {
        _wybranaNode.zPosition = 4;
        int docelowyIndex = (int)[_dolnyPanel indexOfObject:@"0"];
        SKAction *dokujLitere=[SKAction moveTo:CGPointMake([self konwertujIndexNaPozycje:docelowyIndex], WYSOKOSC_PANELU/2) duration:0.1];
        [_dolnyPanel replaceObjectAtIndex:docelowyIndex withObject:_wybranaNode];
        [_wybranaNode runAction:dokujLitere completion:^(void)
         {
             _wybranaNode.zPosition = 1;
         }];
    }
    else
    {
        int lewaGranica = self.frame.size.width/2 - (_gornyPanel.count) * SZEROKOSC_LITERY/2;
        int prawaGranica = self.frame.size.width/2 + (_gornyPanel.count) * SZEROKOSC_LITERY/2;
        
        if (_gornyPanel.count == 0)
        {
            SKAction *umiescLitere = [SKAction moveTo:CGPointMake(self.frame.size.width/2, 3*WYSOKOSC_PANELU/2) duration:0.1];
            [_gornyPanel addObject:_wybranaNode];
            [_wybranaNode runAction:umiescLitere];
        }
        
        else if (_wybranaNode.position.x < lewaGranica)
        {
#if TARGET_OS_IPHONE
            self.view.userInteractionEnabled = NO;
#else
            self.userInteractionEnabled = NO;
#endif
            SKAction *umiescLitere = [SKAction moveTo:CGPointMake(lewaGranica-56, 3*WYSOKOSC_PANELU/2) duration:0.1];
            [_gornyPanel insertObject:_wybranaNode atIndex:0];
            [_wybranaNode runAction:umiescLitere];
        }
        else if (_wybranaNode.position.x > prawaGranica)
        {
            SKAction *umiescLitere = [SKAction moveTo:CGPointMake(prawaGranica+56, 3*WYSOKOSC_PANELU/2) duration:0.1];
            [_gornyPanel addObject:_wybranaNode];
            [_wybranaNode runAction:umiescLitere];
        }
        else if ([_gornyPanel containsObject:@"0"])
        {
            SKAction *umiescLitere = [SKAction moveTo:wolneMiejsceNaGornymPanelu duration:0.1];
            [_gornyPanel replaceObjectAtIndex:indexWolnegoMiejsca withObject:_wybranaNode];
            [_wybranaNode runAction:umiescLitere];
        }
        else
        {
            SKSpriteNode *ostatniaLitera = [_gornyPanel lastObject];
            wolneMiejsceNaGornymPanelu = CGPointMake(ostatniaLitera.position.x+56, ostatniaLitera.position.y);
            indexWolnegoMiejsca = (int)_gornyPanel.count-1;
            SKAction *umiescLitere = [SKAction moveTo:wolneMiejsceNaGornymPanelu duration:0.1];
            [_gornyPanel addObject:_wybranaNode];
            [_wybranaNode runAction:umiescLitere];
        }
    }
    [self zakonczAnimacje:NO :YES :0.1];
    [self wyrownajGornyPanel];
}


-(void)przemiescLitere:(CGPoint)pozycjaDotykuNaScenie :(CGPoint)staraPozycjaDotyku :(CGPoint)pozycjaZlapanejNode
{
    CGPoint przesuniecieDotyku = CGPointMake(pozycjaDotykuNaScenie.x - staraPozycjaDotyku.x, pozycjaDotykuNaScenie.y - staraPozycjaDotyku.y);
    double przesX = pozycjaZlapanejNode.x + przesuniecieDotyku.x;
    double przesY = 0;
    przesY = (pozycjaZlapanejNode.y + przesuniecieDotyku.y);
    [_wybranaNode setPosition:CGPointMake(przesX, przesY)];
}


#pragma mark Panel liter: funkcje rozne

-(void)resetLiter
{
    int iloscLiter = (int)_gornyPanel.count;
    for (int i = 0; i < iloscLiter; i++)
    {
        SKSpriteNode *literaDoRuszenia = [_gornyPanel objectAtIndex:0];
        indexWolnegoMiejsca = (int)[_dolnyPanel indexOfObject:@"0"];
        wolneMiejsceNaGornymPanelu = CGPointMake([self konwertujIndexNaPozycje:indexWolnegoMiejsca], WYSOKOSC_PANELU/2);
        SKAction* ruszLitere = [SKAction moveTo:wolneMiejsceNaGornymPanelu duration:0.1];
        [_gornyPanel removeObject:literaDoRuszenia];
        [_dolnyPanel replaceObjectAtIndex:indexWolnegoMiejsca withObject:literaDoRuszenia];
        literaDoRuszenia.zPosition = 4;
        [literaDoRuszenia runAction:ruszLitere];
    }
}

-(void)sprawdzenieOdpowiedzi:(BOOL)zKlawiatury
{
    if(!zKlawiatury)
    {
    SKSpriteNode *zatwierdz = (SKSpriteNode *)[self childNodeWithName:@"zatwierdz"];
    [zatwierdz setTexture:[SKTexture textureWithImageNamed:@"zatwierdzDown_gra"]];
    }
    _zatwierdzPressed = YES;
    NSString *odpowiedz = @"";
    NSArray *name;
    for (int i = 0; i<_gornyPanel.count; i++)
    {
        SKSpriteNode *litera = [_gornyPanel objectAtIndex:i];
        name = [litera.name componentsSeparatedByString:@"_"];
        odpowiedz = [odpowiedz stringByAppendingString:[name objectAtIndex:1]];
    }
    if([_rozwiazania containsObject:odpowiedz])
    {
        [self wyswietlenieOdpowiedzi:odpowiedz];
        [self resetLiter];
        _ostatniaPodanaOdpowiedz = odpowiedz;
        if (_rozwiazania.count == 0) [self pokazEkranWygranej];
    }
    else [self blednaOdpowiedz];
}

-(void)ostatniaOdpowiedz:(BOOL)zKlawaitory
{
    if(!zKlawaitory)
    {
    SKSpriteNode *ostatniaNode = (SKSpriteNode *)[self childNodeWithName:@"ostatnie"];
    [ostatniaNode setTexture:[SKTexture textureWithImageNamed:@"ostatniDown_gra"]];
    }
    _ostatniPressed = YES;
    
    [self resetLiter];
    NSInteger dlogosOstatniejOdpowiedz = _ostatniaPodanaOdpowiedz.length;
    int zmiennaOrientacyjna;
    
    for (int i=0; i<dlogosOstatniejOdpowiedz; i++)
    {
        NSString *literaString = [_ostatniaPodanaOdpowiedz substringWithRange:NSMakeRange(i, 1)];
        SKSpriteNode *litera = (SKSpriteNode *)[self childNodeWithName:[NSString stringWithFormat:@"ruszalne_%@", literaString]];
        [_dolnyPanel replaceObjectAtIndex:[_dolnyPanel indexOfObject:litera] withObject:@"0"];
        [_gornyPanel addObject:litera];
        
        if (dlogosOstatniejOdpowiedz % 2) zmiennaOrientacyjna = self.frame.size.width/2 - (dlogosOstatniejOdpowiedz/2)*112;
        else zmiennaOrientacyjna = self.frame.size.width/2 - (dlogosOstatniejOdpowiedz/2)*112 + 56;
        
        SKAction *wyrownaj = [SKAction moveTo:CGPointMake(zmiennaOrientacyjna + 112*i, 3*WYSOKOSC_PANELU/2) duration:0.1];
        [litera runAction:wyrownaj];
    }
}

-(void)wyswietlenieOdpowiedzi:(NSString *)odpowiedz{
    
    for (int i=0; i<[odpowiedz length]; i++)
    {
        NSString *nazwaNodeLitery = [odpowiedz stringByAppendingString:[NSString stringWithFormat:@"_%i", i]];
        SKSpriteNode *nodeOdpowiedz = (SKSpriteNode *)[self childNodeWithName:nazwaNodeLitery];
        [nodeOdpowiedz setAlpha:1.0];
    }
    [_rozwiazania removeObject:odpowiedz];
    [_podaneOdpowiedzi addObject:odpowiedz];
    liczbaPunktow++;
}

-(void)blednaOdpowiedz
{
#if TARGET_OS_IPHONE
    self.view.userInteractionEnabled = NO;
#else
    self.userInteractionEnabled = NO;
#endif
    for (int i = 0; i < _gornyPanel.count; i++)
    {
        SKSpriteNode *litera = [_gornyPanel objectAtIndex:i];
        SKAction *wLewo = [SKAction moveByX:-5.0 y:0 duration:0.05];
        SKAction *wPrawo = [SKAction moveByX:5.0 y:0 duration:0.05];
        SKAction *drganie = [SKAction sequence:@[wPrawo, wLewo, wPrawo, wLewo]];
        [litera runAction:drganie];
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
#if TARGET_OS_IPHONE
                       self.view.userInteractionEnabled = YES;
#else
                       self.userInteractionEnabled = YES;
#endif
                   });
}

-(void)wyrownajGornyPanel
{
    int zmiennaOrientacyjna;
    [_gornyPanel removeObjectIdenticalTo:@"0"];
    
    if (_gornyPanel.count % 2) zmiennaOrientacyjna = self.frame.size.width/2 - (_gornyPanel.count/2)*112;
    else zmiennaOrientacyjna = self.frame.size.width/2 - (_gornyPanel.count/2)*112 + 56;
    
    for (int i=0; i<_gornyPanel.count; i++)
    {
        if (![[_gornyPanel objectAtIndex:i] isEqual:@"0"])
        {
            SKAction *wyrownaj = [SKAction moveTo:CGPointMake(zmiennaOrientacyjna + 112*i, 3*WYSOKOSC_PANELU/2) duration:0.1];
            SKSpriteNode *literaDoRuszenia = [_gornyPanel objectAtIndex:i];
            [literaDoRuszenia runAction:wyrownaj];
        }
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
#if TARGET_OS_IPHONE
                       self.view.userInteractionEnabled = YES;
#else
                       self.userInteractionEnabled = YES;
#endif
                   });
}

-(void)zakonczAnimacje:(BOOL)zWylaczeniemInterakcji :(BOOL)zResetemLitery :(double)zOpoznieniem
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(zOpoznieniem * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       if (zWylaczeniemInterakcji)
                       {
#if TARGET_OS_IPHONE
                           self.view.userInteractionEnabled = YES;
#else
                           self.userInteractionEnabled = YES;
#endif
                   }
                       NSArray *name = [_wybranaNode.name componentsSeparatedByString:@"_"];
                       _wybranaNode.name = [NSString stringWithFormat:@"ruszalne_%@", [name objectAtIndex:1]];
                       if (zResetemLitery) _wybranaNode = nil;
                   });
}

-(int)konwertujPozycjeNaPrzedzial:(int)pozycjaX
{
    if (pozycjaX < 160) return 104;
    else if (pozycjaX >= 160 && pozycjaX < 272 ) return 216;
    else if (pozycjaX >= 272 && pozycjaX < 384 ) return 328;
    else if (pozycjaX >= 384 && pozycjaX < 496 ) return 440;
    else if (pozycjaX >= 496 && pozycjaX < 608 ) return 552;
    else if (pozycjaX >= 608) return 664;
    return 664;
}

-(int)konwertujPozycjeNaIndex:(int)pozycjaX
{
    if (pozycjaX < 160) return 0;
    else if (pozycjaX >= 160 && pozycjaX < 272 ) return 1;
    else if (pozycjaX >= 272 && pozycjaX < 384 ) return 2;
    else if (pozycjaX >= 384 && pozycjaX < 496 ) return 3;
    else if (pozycjaX >= 496 && pozycjaX < 608 ) return 4;
    else if (pozycjaX >= 608) return 5;
    return 5;
}

-(int)konwertujIndexNaPozycje:(int)index
{
    int doReturn = 0;
    
    switch (index)
    {
        case 0:
            doReturn = 104;
            break;
        case 1:
            doReturn = 216;
            break;
        case 2:
            doReturn = 328;
            break;
        case 3:
            doReturn = 440;
            break;
        case 4:
            doReturn = 552;
            break;
        case 5:
            doReturn = 664;
            break;
        default:
            return 664;
            break;
    }
    return doReturn;
}

@end