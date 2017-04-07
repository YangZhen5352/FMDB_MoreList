//
//  YZNewCreatController.m
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/10.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import "YZNewCreatController.h"
#import "YZPersonViewController.h"
#import "YZEditorViewController.h"

@interface YZNewCreatController () <YZPersonViewControllerDelegte, UISearchBarDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *persons;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *companies;

@end

@implementation YZNewCreatController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPersonsWithSearchText:nil];
    [self setupTitle];
    
    // 接收修改联系人的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editorToSavePerson:) name:YZEditorToSavePerson object:nil];
    
}
- (void)editorToSavePerson:(NSNotification *)notification
{
    // 1. 接收通知：传过来的参数
    NSLog(@"%@", notification.userInfo);
    NSDictionary *dict = notification.userInfo;
    
    YZPerson *personModel = [[YZPerson alloc] init];
    personModel.age = dict[@"YZEditorAgeKey"];
    personModel.companyName = dict[@"YZEditorCompanyNameKey"];
    personModel.personId = dict[@"YZEditorPersonIdKey"];
    personModel.personName = dict[@"YZEditorPersonNameKey"];
    personModel.phoneNo = dict[@"YZEditorPhoneNoKey"];
    
    // 2. 根据公司名称，查询公司表中对应的companyId
    [[YZDBTools sharedDBTools].queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT companyId FROM T_Company WHERE companyName=\'%@\'", personModel.companyName];
        
        FMResultSet *rs = [db executeQuery:sql];
        NSMutableArray *arrM = [NSMutableArray array];
        while ([rs next]) {
            YZCompany *companyModel = [[YZCompany alloc] init];
            companyModel.companyId = [rs intForColumn:@"companyId"];
            [arrM addObject:companyModel];
        }
        self.companies = arrM;
    }];
    
    
    // 3. 修改联系人信息
    [[YZDBTools sharedDBTools].queue inDatabase:^(FMDatabase *db) {

        YZCompany *companyModel = (YZCompany *)self.companies[0];
        
        NSString *sql = [NSString stringWithFormat:@"UPDATE T_Person SET personName=\'%@\', age=\'%@\', phoneNo=\'%@\', companyId=\'%ld\' WHERE personId=\'%@\'", personModel.personName, personModel.age, personModel.phoneNo, (long)companyModel.companyId, personModel.personId];
        
        [db executeUpdate:sql];
        NSLog(@"更新个人数据成功");
    }];
    
    [self loadPersonsWithSearchText:nil];
    [self.tableView reloadData];
    [self setupTitle];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setupTitle {
    if (self.persons.count) {
        self.navigationItem.title = [NSString stringWithFormat:@"人员列表－%lu", (unsigned long)self.persons.count];
    } else {
        self.navigationItem.title = @"人员列表";
    }
}
// 获取连线的控制器
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    YZPersonViewController *pvc = segue.destinationViewController;

    // c. 准备代码块 等待调用执行
    __weak typeof(self) weakSelf = self;
    pvc.savedPersonData = ^{
        [weakSelf loadPersonsWithSearchText:nil];
        
        [weakSelf.tableView reloadData];
        [weakSelf setupTitle];
    };
    // 4. 设置代理对象
//    pvc.delegate = self;
}
#pragma mark----------- UIScrollViewDelegate -------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

#pragma mark----------- UISearchBarDelegate -------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // 根据用户输入的数据进行搜索
    // 查询结果集 只显示查询到的数据
    [self loadPersonsWithSearchText:searchText];
    
    // 刷新列表
    [self.tableView reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 搜索按钮点击的时候调用
//    NSLog(@"==>>%@", searchBar.text);
}

#pragma mark----------- Table view data source -------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.persons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"PersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    YZPerson *personModel = self.persons[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ （电话：%@）", personModel.personName, personModel.phoneNo];
    cell.detailTextLabel.text = personModel.companyName;
    
    return cell;
}
// 5. 实现代理方法
#pragma mark----------- YZPersonViewControllerDelegte -------------------
- (void)personViewControllerDidSavedPersonData {
    [self loadPersonsWithSearchText:nil];
    
    [self.tableView reloadData];
    [self setupTitle];
}
- (void)loadPersonsWithSearchText:(NSString *)searchText {
    [[YZDBTools sharedDBTools].queue inDatabase:^(FMDatabase *db) {
       
        // 1.对三个属性进行模糊查询工作
        NSString *sql = @"SELECT p.companyId, p.personId, p.age, p.phoneNo, p.personName, c.companyName FROM T_Person p LEFT JOIN T_Company c ON c.companyId = p.companyId";
        // 2.模糊查询 设置查询条件where
        if (searchText.length) {
            NSString *str = [NSString stringWithFormat:@"'%%%@%%'",searchText];
            sql = [sql stringByAppendingFormat:@" where p.personName like %@ or p.phoneNo like %@ or c.companyName like %@ ", str, str, str];
        }
        // 3.拼接sql语句
        sql = [sql stringByAppendingString:@" ORDER BY p.personName"];
        NSLog(@"sql = %@", sql);
        
        // 4.将查询到的结果集 保存到persons数组中
        FMResultSet *rs = [db executeQuery:sql];
        
        NSMutableArray *arrM = [NSMutableArray array];
        while ([rs next]) {
            YZPerson * personModel = [[YZPerson alloc] init];
            
            personModel.personId = [rs stringForColumn:@"personId"];
            personModel.personName = [rs stringForColumn:@"personName"];
            personModel.companyName = [rs stringForColumn:@"companyName"];
            personModel.phoneNo = [rs stringForColumn:@"phoneNo"];
            personModel.age = [rs stringForColumn:@"age"];
            personModel.companyId = [rs stringForColumn:@"companyId"];
            
            if (personModel.companyName == nil) {
                personModel.companyName = @"";
            }
            [arrM addObject:personModel];
        }
        self.persons = arrM;
    }];
}
#pragma mark----------- UITableViewDelegate -------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"111");
    NSInteger row = tableView.indexPathForSelectedRow.row;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Editor" bundle:nil];
    YZEditorViewController *editorVc = sb.instantiateInitialViewController;
    editorVc.oldPerson = self.persons[row];
    
    [self.navigationController pushViewController:editorVc animated:YES];
    [self.tableView reloadData];
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        // 1. 获取当前cell的数据模型
        YZPerson *personModel = self.persons[indexPath.row];
        NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.persons];
        // 2. 将此条数据从人员数组中移除
        [arrM removeObject:personModel];
        self.persons = arrM;
        
        // 3. 更新数据库，删除此条数据
        [[YZDBTools sharedDBTools].queue inDatabase:^(FMDatabase *db) {
           
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM SYSTEM_SYNC_LOG where PK_VAL = %@", personModel.personId];
            [db executeUpdate:sql];
            NSString *sql1 = [NSString stringWithFormat:@"DELETE FROM T_Person where personId = %@", personModel.personId];
            [db executeUpdate:sql1];
        }];
        // 4. 刷新列表
        [self.tableView reloadData];
    }];
    return @[action];
}

// ASI上传数据到服务器
- (IBAction)postData:(id)sender {
    
    // 查询所有的系统日志
    NSMutableArray *systemArr = [[YZDBTools sharedDBTools] searchAllSYSTEM_SYNC_LOG];
    
    NSLog(@"systemArr = %@-%lu", systemArr, (unsigned long)systemArr.count);
    
    [self showToast:@"7天退出成功！"];
    
//    NSURL *url = [NSURL URLWithString:@""];
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:systemArr options:NSJSONWritingPrettyPrinted error:&error];
//    NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
//    
//    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:url];
//
//    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
//    [request addRequestHeader:@"Accept" value:@"application/json"];
//    [request setRequestMethod:@"POST"];
//    [request setUploadProgressDelegate:self];
//    
//    [request setPostBody:tempJsonData];
//    request.delegate = self;
//    
//    [request setCompletionBlock:^{
//        
//        NSData* responseData = [request responseData];
//        NSDictionary *dict = (NSDictionary *)[responseData mutableObjectFromJSONData];
//       
//        NSString* status = [dict objectForKey:@"Result"];
//        if ([request.responseString isEqualToString:@"4008"]) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZYPopToLogin" object:nil];
//            return;
//        }
//        if ([status isEqualToString:@"success"] ) {
//            [[YZDBTools sharedDBTools] deleteAllSYSTEM_SYNC_LOG];
//            [self goOut];
//        }
//        else {
//            if (self.uploadState == UploadStateLogout) {
//                [self showToast:@"数据上传失败"];
//            }else if(self.uploadState == UploadStateUpdate){
//                [self showToast:@"服务器异常"];
//            }else if (self.uploadState == UploadStateWeeklyLogout){
//                [self showToast:@"7天退出成功！"];
//            }
//        }
//    }];
//    
//    [request setFailedBlock:^{
//        
//    }];
//    
//    if (systemArr.count) {
//        [request startSynchronous];
//    }
//    else {
//        [[YZDBTools sharedDBTools] deleteAllSYSTEM_SYNC_LOG];
//        [self goOut];
//    }
//    
    
}
- (void)goOut
{
    
}

- (void)showToast:(NSString *)txt
{
    [SVProgressHUD
     setBackgroundColor:[[UIColor shareHexColor] colorWithHex:@"00000099"]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD showInfoWithStatus:txt];
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}
@end
