//
//  YZNewCreatController.h
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/10.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import <UIKit/UIKit.h>
//typedef NSArray * (^EditPerson)(NSArray * persons);

typedef NS_ENUM(NSInteger, upState) {
    UploadStateLogout       = 0,
    UploadStateWeeklyLogout = 1,
    UploadStateUpdate       = 2,
};

@interface YZNewCreatController : UITableViewController

@property (nonatomic, assign) NSInteger uploadState;

@property (nonatomic, strong) NSArray * (^EditPerson)(NSArray * persons);
@end
