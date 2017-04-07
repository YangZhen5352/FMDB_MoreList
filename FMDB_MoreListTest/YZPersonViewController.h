//
//  YZPersonViewController.h
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/10.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YZPersonViewController;
// a. 定义block 无参数 无返回值
//   （谁调用执行block，谁负责定义block。让准备代码块的去准备去吧！准备好了，我只负责调用就行了）
typedef void (^SavedPersonData)();

// 1. 定义代理方法
@protocol YZPersonViewControllerDelegte <NSObject>
- (void)personViewControllerDidSavedPersonData;
@end

@interface YZPersonViewController : UITableViewController

// 2. 定义代理对象
@property (nonatomic, weak) id<YZPersonViewControllerDelegte> delegate;
@property (nonatomic, strong) SavedPersonData savedPersonData;
@property (nonatomic, strong) NSArray *companies;
- (void)editorNewCompany;

@end
