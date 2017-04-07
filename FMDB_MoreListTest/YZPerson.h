//
//  YZPerson.h
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/22.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 "personId integer PRIMARY KEY AUTOINCREMENT,"
 "personName text not null,"
 "age integer,"
 "phoneNo text,"
 "companyId integer,"
 */
@interface YZPerson : NSObject

@property (nonatomic, copy) NSString *personId;
@property (nonatomic, copy) NSString *personName;
@property (nonatomic, copy) NSString *phoneNo;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *companyName;
@property (nonatomic, copy) NSString *companyId;

@end
