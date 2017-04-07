//
//  YZDBTools.h
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/10.
//  Copyright © 2016年 yangzhen5352. All rights reserved.

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "FMDatabaseQueue.h"

@interface YZDBTools : NSObject

@property (nonatomic, strong) FMDatabaseQueue *queue;

+ (instancetype)sharedDBTools;

// 查询日志信息
- (NSMutableArray *)searchAllSYSTEM_SYNC_LOG;

// 删除日志数据表
- (void)deleteAllSYSTEM_SYNC_LOG;
@end
