#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import <Spotify/SPTAudioStreamingController.h>
#import "ViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[SPTAuth defaultInstance] setClientID:@"635133c72fbe47de851e7d002173469a"];
    [[SPTAuth defaultInstance] setRedirectURL:[NSURL URLWithString:@"phyji://callback"]];
    [[SPTAuth defaultInstance] setRequestedScopes:@[SPTAuthStreamingScope]];
    
    // Construct a login URL and open it
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];
    
    // Opening a URL in Safari close to application launch may trigger
    // an iOS bug, so we wait a bit before doing so.
    [application performSelector:@selector(openURL:)
                      withObject:loginURL afterDelay:0.1];
    
    return YES;
}

// Handle auth callback
-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    
    // Ask SPTAuth if the URL given is a Spotify authentication callback
    if ([[SPTAuth defaultInstance] canHandleURL:url]) {
        [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url callback:^(NSError *error, SPTSession *session) {
            
            if (error != nil) {
                NSLog(@"*** Auth error: %@", error);
                return;
            }
            
            // Call the -playUsingSession: method to play a track
            //[self playUsingSession:session];
            //SPTAuth *auth = [SPTAuth defaultInstance];
            //auth.session = session;
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            ViewController *vc = (ViewController*)window.rootViewController;
            [vc playUsingSession:session];
        }];
        return YES;
    }
    
    return NO;
}

-(void)playUsingSession:(SPTSession *)session {
    
    // Create a new player if needed
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    
    [self.player loginWithSession:session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }
        
        NSURL *song1 = [NSURL URLWithString:@"spotify:track:2bKhIGdMdcqCqQ2ZhSv5nE"];
        NSURL *song2 = [NSURL URLWithString:@"spotify:track:0s7zwTaaSvP6b7paLliVRH"];
        NSArray *songs = [NSArray arrayWithObjects:song1, song2, nil];
        [self.player playURIs:songs fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    }];
}
@end
