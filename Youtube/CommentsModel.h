//
//  CommentsModel.h
//  Youtube
//
//  Created by Kevin McCafferty on 06/02/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import "JSONModel.h"

@interface CommentsModel : JSONModel

@property (strong,nonatomic) NSString *commentAuthor;
@property (strong, nonatomic) NSString *published;
@property (strong, nonatomic) NSString *commentText;

@end
