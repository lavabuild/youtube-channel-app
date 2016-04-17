//
//  VideoModel.h
//  YTBrowser
//
//  Created by Kevin McCafferty on 31/01/2014.
//  Copyright (c) 2014 Kevin McCafferty. All rights reserved.
//

#import "JSONModel.h"

@interface VideoModel : JSONModel

@property (strong, nonatomic) NSString *published;
@property (strong, nonatomic) NSString *viewCount;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *thumbnail;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *descript;


@end
