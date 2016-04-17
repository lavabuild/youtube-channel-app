//
//  YoutubeMasterViewController.h
//  Youtube
//
//  Created by Kevin McCafferty on 05/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YoutubeMasterViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
- (IBAction)loadMoreVideos:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (strong,nonatomic) NSMutableArray *appendedImagesArray;
@property (strong,nonatomic) NSString *nextPageToken;
@end
