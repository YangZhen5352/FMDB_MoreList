//
//  YZEditorViewController.m
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/21.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import "YZEditorViewController.h"
#import "YZDBTools.h"
#import "YZNewCreatController.h"
#define YZEditorPersonNameKey @"YZEditorPersonNameKey"
#define YZEditorPhoneNoKey @"YZEditorPhoneNoKey"
#define YZEditorAgeKey @"YZEditorAgeKey"
#define YZEditorCompanyNameKey @"YZEditorCompanyNameKey"
#define YZEditorPersonIdKey @"YZEditorPersonIdKey"

@interface YZEditorViewController ()

@property (weak, nonatomic) IBOutlet UITextField *personName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNo;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *companyName;

@property (nonatomic, strong) UIAlertAction *secureTextAlertAction;

@end

@implementation YZEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.phoneNo.text = _oldPerson.phoneNo;
    self.personName.text = _oldPerson.personName;
    self.companyName.text = _oldPerson.companyName;
    self.age.text = _oldPerson.age;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" 保 存" style:UIBarButtonItemStylePlain target:self action:@selector(editorToSavePerson)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCompany)];
    
    
    [self.tableView reloadData];
}

- (void)setOldPerson:(YZPerson *)oldPerson
{
    _oldPerson = oldPerson;
}
- (IBAction)savePerson:(id)sender {
    
}
- (void)addCompany
{
    [self editorNewCompany];
}
- (void)editorToSavePerson
{
    // 0. 退出键盘
    [self.view endEditing:YES];
    
    // 1. 查询 personId 的联系人
    [[YZDBTools sharedDBTools].queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM T_Person WHERE personId=\'%@\'", _oldPerson.personId];
        
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *arrM = [NSMutableArray array];
        while ([rs next]) {
            YZPerson *personModel = [[YZPerson alloc] init];
            personModel.personName = [rs stringForColumn:@"personName"];
            personModel.age = [rs stringForColumn:@"age"];
            personModel.phoneNo = [rs stringForColumn:@"phoneNo"];
            personModel.companyId = [rs stringForColumn:@"companyId"];
            
            [arrM addObject:personModel];
        }
        self.selectPerson = arrM;
    }];
    // 2. 查询 companyId 对应的公司名称
    YZPerson *personModel = (YZPerson *)self.selectPerson[0];
    
    [[YZDBTools sharedDBTools].queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT companyName FROM T_Company WHERE companyId=\'%@\'", personModel.companyId];
        
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *arrM = [NSMutableArray array];
        while ([rs next]) {
            YZCompany *companyModel = [[YZCompany alloc] init];
            companyModel.companyName = [rs stringForColumn:@"companyName"];
            [arrM addObject:companyModel];
        }
        self.companies = arrM;
    }];
    
    YZCompany *companyModel = (YZCompany *)self.companies[0];
    NSLog(@"%@-%@-%@-%@", personModel.personName, personModel.age, personModel.phoneNo, companyModel.companyName);
    
    // 3. 如果没有做任何修改，就直接返回到联系人列表
    if (self.personName.text == personModel.personName
        && self.age.text == personModel.age
        && self.phoneNo.text == personModel.phoneNo
        && self.companyName.text == companyModel.companyName
        ) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    // 4. 如果修改了联系人 提示用户是否真的要修改
    UIAlertController *alert = [[UIAlertController alloc] init];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        // 5. 使用通知进行传值 通知联系人页面更新数据
        [[NSNotificationCenter defaultCenter] postNotificationName:
         YZEditorToSavePerson object:nil userInfo:
         @{
           YZEditorPersonNameKey : self.personName.text,
           YZEditorCompanyNameKey : self.companyName.text,
           YZEditorPhoneNoKey : self.phoneNo.text,
           YZEditorAgeKey : self.age.text,
           YZEditorPersonIdKey: _oldPerson.personId,
           }];

        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
