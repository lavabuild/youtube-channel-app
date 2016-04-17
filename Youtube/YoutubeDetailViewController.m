//
//  YoutubeDetailViewController.m
//  Youtube
//
//  Created by Kevin McCafferty on 05/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import "YoutubeDetailViewController.h"
#import "JSONModelLib.h"
#import "CommentsModel.h"
#import "CommentCell.h"
#import "YoutubeVideoCell.h"
#import "UIViewController+KNSemiModal.h"
#import "MBProgressHUD.h"
#import "NSDate+Relativity.h"
#import <QuartzCore/QuartzCore.h>

@interface YoutubeDetailViewController (){
    NSMutableArray *comments;
    NSArray *sortedComments;
    NSDictionary *authorName1;
    NSArray *authorName2;
    NSArray *comment1;
    NSArray *pdate1;
    NSMutableArray *appendedComments;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITableView *detailTable;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;


//- (void)configureView;
@end

CommentsModel *userComment;

@implementation YoutubeDetailViewController

#pragma mark - Managing the detail item

NSString *videoId;
int dindex;
_Block_H_ NSDictionary *json1;
CGFLOAT_TYPE height;
int long tempIndexPath;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _nextPageToken = @"";
    
    
    // Check if running on a 3.5 inch screen, if so, resize the webview
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == 480)
    {
        self.webView.frame = CGRectMake(0, 0, 320, 275);
    }

    
    self.descriptionButton.layer.borderColor = [UIColor colorWithRed:19/255.0 green:144/255.0 blue:255/255.0 alpha:1.0].CGColor;
    self.descriptionButton.layer.borderWidth = 1;
    self.descriptionButton.layer.cornerRadius = 5;
    
    //VideoLink* link = self.video.link[0];
    
    videoId = self.video.id;
    
    if (!videoId) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Video ID not found in video URL" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil]show];
        return;
    }
    
    
    // Below line solved problem of video no longer playing back in webview.
    [_webView setMediaPlaybackRequiresUserAction:NO];
    
    
    NSString *htmlString = [[NSString alloc] init];
    
    // Check size of iPhone
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // 3.5 inch
            htmlString = @"<html><head>\
            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 320\"/></head>\
            <body style=\"background:#000;margin-top:0px;margin-left:0px\">\
            <iframe id=\"ytplayer\" type=\"text/html\" width=\"320\" height=\"240\"\
            src=\"http://youtube.com/embed/%@?autoplay=1\"\
            frameborder=\"0\"/>\
            </body></html>";
        }
        else if(result.height == 568)
        {
            // 4 inch iPhone 5
            htmlString = @"<html><head>\
            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 320\"/></head>\
            <body style=\"background:#000;margin-top:0px;margin-left:0px\">\
            <iframe id=\"ytplayer\" type=\"text/html\" width=\"320\" height=\"240\"\
            src=\"http://youtube.com/embed/%@?autoplay=1\"\
            frameborder=\"0\"/>\
            </body></html>";
        }
        else if(result.height == 667)
        {
            // 4.7 inch iPhone 6
            htmlString = @"<html><head>\
            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 375\"/></head>\
            <body style=\"background:#000;margin-top:0px;margin-left:0px\">\
            <iframe id=\"ytplayer\" type=\"text/html\" width=\"375\" height=\"240\"\
            src=\"http://youtube.com/embed/%@?autoplay=1\"\
            frameborder=\"0\"/>\
            </body></html>";
        }
        else if(result.height == 736)
        {
            // 4.7 inch iPhone 6 +
            htmlString = @"<html><head>\
            <meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 414\"/></head>\
            <body style=\"background:#000;margin-top:0px;margin-left:0px\">\
            <iframe id=\"ytplayer\" type=\"text/html\" width=\"414\" height=\"240\"\
            src=\"http://youtube.com/embed/%@?autoplay=1\"\
            frameborder=\"0\"/>\
            </body></html>";
        }
    }
    
    
    
    
    htmlString = [NSString stringWithFormat:htmlString, videoId, videoId];
    
    
    [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://youtube.com"]];
    
    
    self.descriptionTextView.text = self.video.descript;
    
    [self getComments];
	// Do any additional setup after loading the view, typically from a nib.
    //[self configureView];
    
}





-(void)getComments
{
    
    if (! appendedComments) {
        appendedComments = [[NSMutableArray alloc] init];
    }
    
    
    NSString* commentCall = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=%@&key=YourAPIKeyHere&maxResults=30&pageToken=%@", videoId, _nextPageToken];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading Comments";
    
    
    if (![_nextPageToken isEqualToString:@""] || appendedComments.count == 0) {
        
        [JSONHTTPClient getJSONFromURLWithString:commentCall
                                      completion:^(NSDictionary *json1 , JSONModelError *err){
                                          // got JSON back
                                          
                                          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                          // Changes made to use the new API v.3 for Youtube.
                                          //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

                                          NSMutableArray * items = [[NSMutableArray alloc] init];
                                          
                                          items = json1[@"items"];
                                          
                                          _nextPageToken = json1[@"nextPageToken"];
                                          
                                          NSMutableArray *commentsArray = [[NSMutableArray alloc] init];
                                          NSMutableDictionary *snippetDict = [[NSMutableDictionary alloc] init];
                                          
                                          
                                          for (int i=0; i<items.count; i++) {
                                              CommentsModel *commModel = [[CommentsModel alloc] init];
                                              
                                              // Get the snippet dictionary that contains the desired data.
                                              snippetDict = items[i][@"snippet"];
                                              
                                              commModel.commentAuthor = snippetDict[@"topLevelComment"][@"snippet"][@"authorDisplayName"];
                                              commModel.published = snippetDict[@"topLevelComment"][@"snippet"][@"publishedAt"];
                                              commModel.commentText = snippetDict[@"topLevelComment"][@"snippet"][@"textDisplay"];
                                              
                                              [commentsArray addObject:commModel];
                                              
                                          }
                                          
                                          
                                          [appendedComments addObjectsFromArray:commentsArray];
                                          commentsArray = nil;
                                          
                                          // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                                          
                                          
                                          if (err) {
                                              [[[UIAlertView alloc] initWithTitle:@"Error" message:[err localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
                                          }
                                          
                                          
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          });
                                          
                                          if (commentsArray) NSLog(@"Loaded successfully models");
                                          [self.detailTable reloadData];
                                      }];
        
    } else {
        [hud removeFromSuperview];
    }
    
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [appendedComments count];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil)
    {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CommentCell"];
    }
    
    NSUInteger row = [indexPath row];
    
    userComment = [appendedComments objectAtIndex:row];
    
    cell.commName.text = userComment.commentAuthor;
    

    //NSString *dateString = [pdate1 objectAtIndex:row];
    NSString *dateString = userComment.published;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"]];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:dateString];
    NSString *ago = [NSString stringWithFormat:@"%@ ago", [[NSDate date] distanceOfTimeInWordsSinceDate:dateFromString]];

    cell.publishLabel.text = ago;
    
    // Format apostrophe properly.
    NSString *commentTemp = [[NSString alloc] initWithString:userComment.commentText];
    NSMutableString *commFormatted = [[NSMutableString alloc] initWithString:commentTemp];
    [commFormatted setString: [commFormatted stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"]];
    
    cell.commDetail.text = commFormatted;
    return cell;
    
}





-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row != tempIndexPath)
    {
       if ([indexPath isEqual:[NSIndexPath indexPathForRow:[self tableView:tableView numberOfRowsInSection:0]-1 inSection:0]])
       {
           tempIndexPath = indexPath.row;
           [self getComments];
       }
    }
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSString *text = [comment1 objectAtIndex:indexPath.row];;
    userComment = [appendedComments objectAtIndex:indexPath.row];
    NSString *text = userComment.commentText;
    CGFloat width = 294;
    UIFont *font = [UIFont fontWithName:@"Georgia" size:15];
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:text
     attributes:@
     {
     NSFontAttributeName: font
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    height = ceilf(size.height);
    return height+50;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showSemiModal:(id)sender {
    CGRect frame = CGRectMake(0,0,320,280);
    // You can present a simple UIImageView or any other UIView like this,
    // without needing to take care of dismiss action
    UITextView * descriptionView = [[UITextView alloc] initWithFrame:frame];
    
    // Set font
    [descriptionView setFont:[UIFont fontWithName:@"helvetica neue" size:14]];
    
    [descriptionView setBackgroundColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]];
    descriptionView.text = self.video.descript;
    descriptionView.dataDetectorTypes = UIDataDetectorTypeLink;
    descriptionView.editable = NO;
    UIImageView * bgimgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background1"]];
    //[self presentSemiView:descriptionView];
    [self presentSemiView:descriptionView withOptions:@{ KNSemiModalOptionKeys.backgroundView:bgimgv }];
}



@end
