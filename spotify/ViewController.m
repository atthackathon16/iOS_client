//
//  ViewController.m
//  spotify
//
//  Created by Le Huy Cu on 6/3/16.
//  Copyright © 2016 Le Huy Cu. All rights reserved.
//

#import "ViewController.h"
#import <Spotify/Spotify.h>
#import <Spotify/SPTAudioStreamingController.h>
#import "AppDelegate.h"
#import <Spotify/SPTDiskCache.h>

@interface ViewController () <SPTAudioStreamingDelegate>
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (weak, nonatomic) IBOutlet UIImageView *coverArt;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) NSArray *sleepPlaylist;
@property (strong, nonatomic) NSArray *runningPlaylist;
@property (strong, nonatomic) NSString *activity;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }
    
    NSURL *sleep1 = [NSURL URLWithString:@"spotify:track:41Uz23jubhxB8YREUHvueV"];
    NSURL *sleep2 = [NSURL URLWithString:@"spotify:track:2esLJsWcEdtlV8camMnRk5"];
    NSURL *sleep3 = [NSURL URLWithString:@"spotify:track:0I2kwvXCLolYQ4nZQcF6EQ"];
    NSURL *sleep4 = [NSURL URLWithString:@"spotify:track:3aLof1zmaQ0GLcAc9YQ3Fq"];
    self.sleepPlaylist = [NSArray arrayWithObjects:sleep1, sleep2, sleep3, sleep4, nil];
    
    NSURL *run1 = [NSURL URLWithString:@"spotify:track:2fEqFPhM6dmRvDfzkh8xNt"];
    NSURL *run2 = [NSURL URLWithString:@"spotify:track:7n0AyA1r7ksz4JurZVP0Ah"];
    NSURL *run3 = [NSURL URLWithString:@"spotify:track:3fGfUXyf66606WEUFneuKv"];
    NSURL *run4 = [NSURL URLWithString:@"spotify:track:1vu8zEpTfoxLtpRFyRMEFn"];
    self.runningPlaylist = [NSArray arrayWithObjects:run1, run2, run3, run4, nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) update {
    SPTAuth *auth = [SPTAuth defaultInstance];
    [SPTTrack trackWithURI:self.player.currentTrackURI
                   session:auth.session
                  callback:^(NSError *error, SPTTrack *track) {
                      self.titleLabel.text = track.name;
                      SPTPartialArtist *artist = [track.artists objectAtIndex:0];
                      self.artistLabel.text = artist.name;
                      NSURL *imageURL = track.album.largestCover.imageURL;
                      if (imageURL == nil) {
                          self.coverArt.image = nil;
                          return;
                      }
                      UIImage *image = nil;
                      NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:0 error:&error];
                      
                      if (imageData != nil) {
                          image = [UIImage imageWithData:imageData];
                      }
                      self.coverArt.image = image;

    }];
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    [self update];
}

- (IBAction)playPause:(id)sender {
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
}

- (IBAction)playNext:(id)sender {
    [self.player skipNext:nil];
}

- (IBAction)playPrev:(id)sender {
    [self.player skipPrevious:nil];
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
        
        [self.player playURIs:self.runningPlaylist fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
    }];
}

@end
