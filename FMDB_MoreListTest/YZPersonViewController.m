//
//  YZPersonViewController.m
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/10.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import "YZPersonViewController.h"
#import "YZNewCreatController.h"


@interface YZPersonViewController () <UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *personName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNo;
@property (weak, nonatomic) IBOutlet UITextField *age;
@property (weak, nonatomic) IBOutlet UITextField *companyName;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *persons;

@end

@implementation YZPersonViewController

- (UIPickerView *)pickerView {
    if (!_pickerView)
    {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.companyName.inputView = self.pickerView;
    
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    contentView.backgroundColor = [UIColor blueColor];
    [self.pickerView addSubview:contentView];
    
    [self reloadData];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"人员列表" style:UIBarButtonItemStylePlain target:self action:@selector(editorToSavePerson)];
}
- (void)editorToSavePerson
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)editorNewCompany
{
    [self newCompany:nil];
}
// 新建公司记录
- (IBAction)newCompany:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入公司名称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}
#pragma mark----------- UIAlertViewDelegate -------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *text = [alertView textFieldAtIndex:0].text;
    NSLog(@"zd = %zd", buttonIndex);
    NSLog(@"%@", text);
    
    if (buttonIndex == 0) {
        return;
    }
    [self.personName becomeFirstResponder];
    if (text.length == 0) {
        return;
    }
    [[YZDBTools sharedDBTools].queue inDatabase:^(FMDatabase *db) {
       
        [db executeUpdate:@"INSERT INTO T_Company(companyName) VALUES (?)", text];
        NSLog(@"保存成功");
        
        FMResultSet *rs = [db executeQuery:@"select companyId, companyName from t_company"];
        
        NSMutableArray *arrM = [NSMutableArray array];
        while ([rs next]) {
            YZCompany *companyModel = [[YZCompany alloc] init];
           
            companyModel.companyName = [rs stringForColumn:@"companyName"];
            companyModel.companyId = [rs intForColumn:@"companyId"];
            
            [arrM addObject:companyModel];
        }
        self.companies = arrM;
        [self.pickerView reloadAllComponents];
    }];
}
#pragma mark----------- UIPickerViewDataSource -------------------
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.companies.count;
}
#pragma mark----------- UIPickerViewDelegate -------------------
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    YZCompany *companyModel = self.companies[row];
    return companyModel.companyName;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    YZCompany *companyModel = self.companies[row];
    self.companyName.text = companyModel.companyName;
    self.companyName.tag = companyModel.companyId;
}
#pragma mark----------- 加载所有公司数据 -------------------
- (void)reloadData {
    [[YZDBTools sharedDBTools].queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select companyId, companyName from t_company"];
        
        NSMutableArray *arrM = [NSMutableArray array];
        while ([rs next]) {
            YZCompany *companyModel = [[YZCompany alloc] init];
            
            companyModel.companyName = [rs stringForColumn:@"companyName"];
            companyModel.companyId = [rs intForColumn:@"companyId"];
            
            [arrM addObject:companyModel];
        }
        self.companies = arrM;
//        for (YZCompany *companyModel in arrM) {
//            NSLog(@"%@,%ld", companyModel.companyName, (long)companyModel.companyId);
//        }
        [self.pickerView reloadAllComponents];
//        NSLog(@"==>>%@", self.companies);
    }];
}

// 保存个人记录
- (IBAction)savePerson
{
    if (self.personName.text.length == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"必须输入姓名" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    NSLog(@"%@",self.personName.text);
    [[YZDBTools sharedDBTools].queue inDatabase:^(FMDatabase *db) {
       
        NSInteger companyId = self.companyName.tag;
        
        NSNumber *companyNum = nil;
        if (companyId > 0) {
            companyNum = @(companyId);
        }
        [db executeUpdate:@"insert into t_person (personName, age, phoneNo, companyId) values (?, ?, ?, ?)", self.personName.text, self.age.text, self.phoneNo.text, companyNum];
        NSLog(@"保存个人数据成功");
    }];
    
    // b. 执行block
    if (self.savedPersonData) {
        self.savedPersonData();
    }
    
    // 3. 代理如果实现了方法 我就去让代理对象去调用方法
    if ([self.delegate respondsToSelector:@selector(personViewControllerDidSavedPersonData)]) {
        [self.delegate personViewControllerDidSavedPersonData];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
// 获取连线的控制器
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    YZNewCreatController *newVc = segue.destinationViewController;
    
    newVc.EditPerson = ^(NSArray * persons){
        
        NSLog(@"%@", persons);
        return persons;
    };
}

@end
