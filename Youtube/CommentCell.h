//
//  CommentCell.h
//  Youtube
//
//  Created by Kevin McCafferty on 11/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *commName;
@property (weak, nonatomic) IBOutlet UILabel *commDetail;



@property (weak, nonatomic) IBOutlet UILabel *publishLabel;


@end
