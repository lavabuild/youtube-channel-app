//
//  FacebookViewController.h
//  Youtube
//
//  Created by Kevin McCafferty on 28/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIWebView *facebookWebView;


@end
