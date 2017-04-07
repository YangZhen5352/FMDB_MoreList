//
//  YZCompany.h
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/22.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 "companyId integer PRIMARY KEY AUTOINCREMENT,"
 "companyName text not null"
 */
@interface YZCompany : NSObject

@property (nonatomic, assign) NSInteger companyId;
@property (nonatomic, copy) NSString *companyName;

@end
