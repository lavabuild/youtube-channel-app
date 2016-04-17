//
//  YoutubeMasterViewController.m
//  Youtube
//
//  Created by Kevin McCafferty on 05/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import "YoutubeMasterViewController.h"

#import "YoutubeDetailViewController.h"
#import "VideoModel.h"
#import "JSONModelLib.h"
#import "YoutubeVideoCell.h"
#import "SWRevealViewController.h"
#import "MBProgressHUD.h"
#import "NSDate+Relativity.h"
#import "FTWCache.h"
#import "NSString+MD5.h"
#import "MyUtil.h"


@interface YoutubeMasterViewController () {
    NSMutableArray *appendedArray;
   }
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end


NSString *searchCall;
_Block_H_ BOOL finished = NO;
VideoModel *video;


@implementation YoutubeMasterViewController


- (void)awakeFromNib
{
    [super awakeFromNib];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _nextPageToken = @"";
    
	// Do any additional setup after loading the view, typically from a nib.
    finished = NO;
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    // Create refresh indicator
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithRed:19/255.0 green:144/255.0 blue:255/255.0 alpha:1.0];
    [refreshControl addTarget:self action:@selector(setSindex) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    // Get the first batch of videos
    [self getUserVideos];
    [self.tableView reloadData];
    
}



-(void)setSindex
{
    [appendedArray removeAllObjects];
    _nextPageToken = @"";
    [self getUserVideos];
}



-(void)getUserVideos
{
    
    self.loadButton.hidden = YES;
    
    if (! appendedArray) {
        appendedArray = [[NSMutableArray alloc] init];
    }

    // Search changed to work for new API v.3 for Youtube.
    searchCall = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=YourChannelIdHere&key=YourAPIKeyHere&maxResults=15&pageToken=%@", _nextPageToken];
    
    
    if (finished == NO) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
    
    if (finished == NO && _nextPageToken) {
        [JSONHTTPClient getJSONFromURLWithString:searchCall
                                      completion:^(NSDictionary *json , JSONModelError *err){
                                          // got JSON back
                                          
                                          if (err) {
                                              [[[UIAlertView alloc] initWithTitle:@"Error" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
                                              finished = YES;
                                              [self backgroundDone];
                                          }
                                          
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        // Changes made to use the new API v.3 for Youtube.
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                          
                                          NSMutableArray * items = [[NSMutableArray alloc] init];
                                          NSMutableArray * viewCountItems = [[NSMutableArray alloc] init];
                                          items = json[@"items"];
                                          
                                          _nextPageToken = json[@"nextPageToken"];
                                          
                                          NSMutableArray *videos = [[NSMutableArray alloc] init];
                                          NSMutableDictionary *snippetDict = [[NSMutableDictionary alloc] init];
                                          NSMutableDictionary *videoDetailsDict = [[NSMutableDictionary alloc] init];
                                          
                                          
                                          for (int i=0; i<items.count; i++) {
                                              VideoModel *vidModel = [[VideoModel alloc] init];
                                              
                                              // Get the snippet dictionary that contains the desired data.
                                              snippetDict = items[i][@"snippet"];
                                              
                                              // Create a new dictionary to store only the values we care about.
                                              videoDetailsDict[@"title"] = snippetDict[@"title"];
                                              videoDetailsDict[@"thumbnail"] = snippetDict[@"thumbnails"][@"high"][@"url"];
                                              videoDetailsDict[@"id"] = snippetDict[@"resourceId"][@"videoId"];
                                              videoDetailsDict[@"published"] = snippetDict[@"publishedAt"];
                                              videoDetailsDict[@"description"] = snippetDict[@"description"];
                                              
                                              vidModel.title = videoDetailsDict[@"title"];
                                              vidModel.thumbnail = videoDetailsDict[@"thumbnail"];
                                              vidModel.id = videoDetailsDict[@"id"];
                                              vidModel.published = videoDetailsDict[@"published"];
                                              vidModel.descript = videoDetailsDict[@"description"];
                                              
                                              
                                              // Get video view count ----------------------------------------------------------------
                                              NSString *viewCountCall = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?id=%@&key=YourAPIKeyHere&part=snippet,statistics", vidModel.id];
                                              
                                              NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:viewCountCall]];
                                              
                                              NSData *theData = [NSURLConnection sendSynchronousRequest:request
                                                                                      returningResponse:nil
                                                                                                  error:nil];
                                              
                                              NSDictionary *statisticsJSON = [NSJSONSerialization JSONObjectWithData:theData
                                                                                                      options:0
                                                                                                        error:nil];
                                              
                                              viewCountItems = statisticsJSON[@"items"];
                                              
                                              // Get the snippet dictionary that contains the desired data.
                                              snippetDict = viewCountItems[0][@"statistics"];
                                              vidModel.viewCount = snippetDict[@"viewCount"];
                                              // End of Get video view count ----------------------------------------------------------
                                              
                                              [videos addObject:vidModel];
                                          }
                                          
                                          
        //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                          
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (err) {
                                                  NSLog(@"error");
                                                  finished = YES;
                                                  [self.refreshControl endRefreshing];
                                              }
                                              [self backgroundDone];
                                              [self stopRefresh];
                                          });
                                          
                                          [appendedArray addObjectsFromArray:videos];
                                          [self.tableView reloadData];
                                      }];
    }else{
        [self backgroundDone];
        [self stopRefresh];
        finished=NO;
    }
}



-(void)backgroundDone
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.loadButton.hidden = NO;
}


- (void)stopRefresh

{
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appendedArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    YoutubeVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCell" forIndexPath:indexPath];

    if ([appendedArray count] > 0) {
        video = appendedArray[indexPath.row];
    }
    cell.videoTitleLabel.text = [video title];
    
    cell.viewCountLabel.text = [video viewCount];
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", video.thumbnail]];
    
    NSString *key = [url.absoluteString MD5Hash];
    NSData *data = [FTWCache objectForKey:key];
    if (data) {
        
        UIImage *myUIImageInstance = [UIImage imageWithData:data];
        
        UIImage *image = [MyUtil imageWithImage:myUIImageInstance scaledToSize:CGSizeMake(320, 150)];
        
        [cell.videoImage setImage:image];
    } else {
        cell.videoImage.image = [UIImage imageNamed:@"defaultImage"];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            NSData *data = [NSData dataWithContentsOfURL:url];
            [FTWCache setObject:data forKey:key];
            
            UIImage *myUIImageInstance = [UIImage imageWithData:data];
            
            UIImage *image = [MyUtil imageWithImage:myUIImageInstance scaledToSize:CGSizeMake(320, 150)];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.videoImage setImage:image];
                [cell setNeedsLayout];
            });
        });
    }
    

    NSString *dateString = video.published;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    NSString *ago = [NSString stringWithFormat:@"%@ ago", [[NSDate date] distanceOfTimeInWordsSinceDate:dateFromString]];
    
    cell.publishedLabel.text = ago;
    
    return cell;
                   
}




- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
         VideoModel *video = appendedArray[indexPath.row];
        
        YoutubeDetailViewController *dvc = segue.destinationViewController;
        dvc.video = video;
    }
}



- (IBAction)loadMoreVideos:(id)sender {
    [self getUserVideos];
}
@end
