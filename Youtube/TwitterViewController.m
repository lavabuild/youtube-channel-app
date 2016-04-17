//
//  TwitterViewController.m
//  Youtube
//
//  Created by Kevin McCafferty on 28/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import "TwitterViewController.h"
#import "SWRevealViewController.h"
#import "MBProgressHUD.h"

@interface TwitterViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *twitterWebView;

@end

@implementation TwitterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationItem.leftBarButtonItem = self.sidebarButton;
    
	// Do any additional setup after loading the view.
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Start loading indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_twitterWebView animated:YES];
    hud.labelText = @"Loading";
    
    // set our view to be the Webview's delegate
    _twitterWebView.delegate = self;
    
    // Request twitter page
    dispatch_queue_t myqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(myqueue, ^{
        NSURL *websiteUrl=[NSURL URLWithString:@"http://twitter.com/lavabuild"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
        [_twitterWebView loadRequest:urlRequest];
    });
}



- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:_twitterWebView animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
