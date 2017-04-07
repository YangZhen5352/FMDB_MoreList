//
//  YZDBTools.m
//  FMDB_MoreListTest
//
//  Created by 杨振 on 16/1/10.
//  Copyright © 2016年 yangzhen5352. All rights reserved.
//

#import "YZDBTools.h"

@implementation YZDBTools

// 1. 全局的单里
+ (instancetype)sharedDBTools {
    
    static YZDBTools *tools;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [[self alloc] init];
    });
    return tools;
}
// 2. 初始化数据库
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"readme.db"];
        
        NSLog(@"dbPath = %@", dbPath);
        
        self.queue = [[FMDatabaseQueue alloc] initWithPath:dbPath];
        [self createTables];
    }
    return self;
}
// 3. 创建数据表
- (void)createTables {
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
       
        BOOL result = NO;
        
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Person ("
                  
                  // PRIMARY KEY: 主键字段默认就包含了not null 和 unique 两个约束
                  "personId integer PRIMARY KEY AUTOINCREMENT,"
                  "personName text not null,"
                  "age integer,"
                  "phoneNo text,"
                  "companyId integer,"
                  "CREATE_DATE TIMESTAMP not null DEFAULT CURRENT_TIMESTAMP,"
                  // FOREIGN KEY：外键companyId 产考T_Company数据表中的(companyId)
                  // ON DELETE SET NULL：从属关系破裂，将从属数据的关联属性字段设置成NULL
                  "FOREIGN KEY (companyId) REFERENCES T_Company (companyId) ON DELETE SET NULL"// asc ->// 升序（默认）desc
                  ");"];
        
        // 设置数据表 事物回滚
        if (!result) {
            NSLog(@"创建数据表失败");
            *rollback = YES;
            return ;
        }
        // http://www.rishang.com/rishang/activity/query/82
        NSString *sqlT_Company = @"create table IF NOT EXISTS T_Company(                                                                              companyId    integer    not null,                                                      companyName    VARCHAR(50)    not null,                                                    CREATE_DATE    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,                                  primary key (companyId));                                                         create unique index SYSTEM_SYNC_LOG_PK on SYSTEM_SYNC_LOG ( companyId ASC);";
        sqlT_Company = @"CREATE TABLE IF NOT EXISTS T_Company ("
                         "companyId integer PRIMARY KEY AUTOINCREMENT,"
                         "companyName text not null"
                         ");";
        
        [db executeUpdate:sqlT_Company];
        
        [db executeUpdate:@"create table IF NOT EXISTS SYSTEM_SYNC_LOG(                                                                           PK_VAL    VARCHAR(50)        not null,                                                      T_NAME    VARCHAR(50)    not null,                                                    ACTION    VARCHAR(10)    not null,                                                 CREATE_DATE    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,                                  primary key (PK_VAL, T_NAME)                                                                                    );                                                                                   create unique index SYSTEM_SYNC_LOG_PK on SYSTEM_SYNC_LOG (  PK_VAL ASC, T_NAME  ASC );"];
//
////        // 触发器
        NSString *sql1 = @"CREATE TRIGGER IF NOT EXISTS [T_Person_INSERT] AFTER INSERT ON [T_Person] BEGIN INSERT INTO SYSTEM_SYNC_LOG VALUES(NEW.personId,'T_Person','C',CURRENT_TIMESTAMP); END;";
//
        NSString *sql2 = @"CREATE TRIGGER IF NOT EXISTS [T_Person_DELETE] AFTER DELETE ON [T_Person] BEGIN INSERT INTO SYSTEM_SYNC_LOG VALUES(NEW.personId,'T_Person','D',CURRENT_TIMESTAMP); END;";
//
        NSString *sql3 = @"CREATE TRIGGER IF NOT EXISTS [T_Person_UPDATE] AFTER UPDATE ON [T_Person] BEGIN INSERT INTO SYSTEM_SYNC_LOG VALUES(NEW.personId,'T_Person','U',CURRENT_TIMESTAMP); END;";
//
//        NSString *sql4 = @"CREATE TRIGGER IF NOT EXISTS [T_Company_INSERT] AFTER INSERT ON [T_Company] BEGIN INSERT INTO SYSTEM_SYNC_LOG VALUES(NEW.companyId,'T_Company','C',CURRENT_TIMESTAMP); END;";
//        NSString *sql5 = @"CREATE TRIGGER IF NOT EXISTS [T_Company_DELETE] AFTER DELETE ON [T_Company] BEGIN INSERT INTO SYSTEM_SYNC_LOG VALUES(NEW.companyId,'T_Company','D',CURRENT_TIMESTAMP); END;";
//        
//        NSString *sql6 = @"CREATE TRIGGER IF NOT EXISTS [T_Company_UPDATE] AFTER UPDATE ON [T_Company] BEGIN INSERT INTO SYSTEM_SYNC_LOG VALUES(NEW.companyId,'T_Company','U',CURRENT_TIMESTAMP); END;";
//        
        NSArray *arrLists = [NSArray arrayWithObjects:sql1, sql2, sql3,  nil];
        
        for (NSString *sql in arrLists) {
            [db executeUpdate:sql];
        }
        
        NSLog(@"创建数据表完成");
    }];
}

// 查询所有的系统日志
- (NSMutableArray *)searchAllSYSTEM_SYNC_LOG
{
    NSMutableArray *arrM = [NSMutableArray array];
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *sql1 = @"SELECT * FROM 'SYSTEM_SYNC_LOG' JOIN 'T_Person' ON SYSTEM_SYNC_LOG.PK_VAL = T_Person.personId";
        FMResultSet *rs = [db executeQuery:sql1];
        while ([rs next]) {
            
            int personId = [rs intForColumn:@"personId"];
            NSString *personName = [rs stringForColumn:@"personName"];
            int age = [rs intForColumn:@"age"];
            NSString *phoneNo = [rs stringForColumn:@"phoneNo"];
            int companyId = [rs intForColumn:@"companyId"];
            NSString * createDate = [rs stringForColumn:@"CREATE_DATE"];
            
            if ([phoneNo isEqualToString:@""] || [phoneNo isEqualToString:@"(null)"]) {
                phoneNo = @"0";
            }
            if ([personName isEqualToString:@""] || [personName isEqualToString:@"(null)"]) {
                personName = @"0";
            }
            if ([[NSString stringWithFormat:@"%d", age] isEqualToString:@""] || [[NSString stringWithFormat:@"%d", age] isEqualToString:@"(null)"]) {
                age = 0;
            }
            
            NSDictionary *dict = @{@"personId" : @(personId),
                                   @"personName" : personName,
                                   @"age" : @(age),
                                   @"phoneNo" : phoneNo,
                                   @"companyId" : @(companyId),
                                   @"createDate" : createDate
                                   };
            [arrM addObject:dict];
        }
        
        
        NSString *sql2 = @"SELECT * FROM 'SYSTEM_SYNC_LOG' WHERE ACTION = 'D'";
        FMResultSet *rs1 = [db executeQuery:sql2];
        while ([rs1 next]) {
            NSString * t_name = [rs1 stringForColumn:@"T_NAME"];
            
            NSString * action = [rs1 stringForColumn:@"ACTION"];
            
            NSString * namelistId = [rs1 stringForColumn:@"PK_VAL"];
            
            NSString * createDate = [rs1 stringForColumn:@"CREATE_DATE"];
            
            NSDictionary * dict=@{
                                  @"tableName":t_name
                                  ,@"action":action
                                  ,@"namelistId":namelistId
                                  ,@"createDate":createDate
                                  };
            [arrM addObject:dict];
        }
        
        
        NSString *sql3 = @"SELECT * FROM 'SYSTEM_SYNC_LOG' JOIN 'T_Company' ON SYSTEM_SYNC_LOG.PK_VAL = T_Company.companyId";
        FMResultSet *rs3 = [db executeQuery:sql3];
        while ([rs3 next]) {
            
            int companyId = [rs3 intForColumn:@"companyId"];
            NSString *companyName = [rs3 stringForColumn:@"companyName"];
            NSString * createDate = [rs3 stringForColumn:@"CREATE_DATE"];
            
            NSDictionary *dict = @{@"companyId" : @(companyId),
                                   @"companyName" : companyName,
                                   @"createDate" : createDate
                                   };
            [arrM addObject:dict];
        }
    }];
    
    return arrM;
}

//删除日志表
- (void)deleteAllSYSTEM_SYNC_LOG
{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        [db executeUpdate:@"DELETE FROM SYSTEM_SYNC_LOG"];
    }];
    
}
@end
