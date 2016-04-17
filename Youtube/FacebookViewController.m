//
//  FacebookViewController.m
//  Youtube
//
//  Created by Kevin McCafferty on 28/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import "FacebookViewController.h"
#import "SWRevealViewController.h"
#import "MBProgressHUD.h"

@interface FacebookViewController ()

@end

@implementation FacebookViewController



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
	// Do any additional setup after loading the view.
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    // Start the loading indicator
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_facebookWebView animated:YES];
    hud.labelText = @"Loading";
    
    // set our view to be the Webview's delegate
    _facebookWebView.delegate = self;
    
    // Request facebook page
    dispatch_queue_t myqueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(myqueue, ^{
        NSURL *websiteUrl=[NSURL URLWithString:@"http://www.facebook.com/lavabuild"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
        [_facebookWebView loadRequest:urlRequest];
    });
}



- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:_facebookWebView animated:YES];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
