//
//  YoutubeDetailViewController.h
//  Youtube
//
//  Created by Kevin McCafferty on 05/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

@interface YoutubeDetailViewController : UIViewController


@property (strong,nonatomic) VideoModel *video;
- (IBAction)showSemiModal:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UIButton *descriptionButton;
@property (strong,nonatomic) NSString *nextPageToken;

@end
