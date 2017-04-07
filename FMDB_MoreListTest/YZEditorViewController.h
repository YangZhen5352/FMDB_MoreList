//
//  YZEditorViewController.h
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/21.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZPersonViewController.h"

#define YZEditorToSavePerson @"YZEditorToSavePerson"

typedef void (^SavedPersonData)();

@interface YZEditorViewController : YZPersonViewController

@property (nonatomic, strong) YZPerson *oldPerson;
@property (nonatomic, strong) NSArray *selectPerson;

//@property (nonatomic, strong) SavedPersonData editorSavedPersonData;

@end
