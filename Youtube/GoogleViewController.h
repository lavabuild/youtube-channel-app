//
//  GoogleViewController.h
//  Youtube
//
//  Created by Kevin McCafferty on 04/03/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIWebView *googleWebView;

@end
