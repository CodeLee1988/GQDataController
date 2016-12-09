//
//  GQSQLiteProtocol.m
//  Pods
//
//  Created by QianGuoqiang on 16/8/2.
//
//

#import "GQSQLiteProtocol.h"
#import <sqlite3.h>

NSString * const GQSQLiteURLProtocolKey = @"gqsqlite";

@implementation GQSQLiteProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return [[[request URL] scheme] isEqualToString:GQSQLiteURLProtocolKey];
}

- (void)startLoading
{
    NSURLRequest *request = [self request];
    
    NSArray *resultArray = [self queryDBWithURL:request.URL];
    
    if (resultArray && [NSJSONSerialization isValidJSONObject:resultArray]) {
        
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request URL]
                                                                  statusCode:200
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:@{@"Content-Type":@"application/json"}];
        
        NSData *responseData = [NSJSONSerialization dataWithJSONObject:resultArray
                                                               options:0
                                                                 error:nil];
        
        [self.client URLProtocol:self
              didReceiveResponse:response
              cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        
        [self.client URLProtocol:self didLoadData:responseData];
        
        [self.client URLProtocolDidFinishLoading:self];
        
    } else {
        NSError *error = [NSError errorWithDomain:@"GQSQLiteProtocol"
                                             code:500
                                         userInfo:nil];
        
        [self.client URLProtocol:self didFailWithError:error];
    }
}

- (void)stopLoading
{
    
}

- (NSArray *)queryDBWithURL:(NSURL *)url
{
    NSString *sqlitePath = url.path;
    NSString *query = [url gq_sql];
    
    sqlite3 *sqlite3Database;
    
    BOOL openRel = sqlite3_open([sqlitePath UTF8String], &sqlite3Database);
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    if (openRel == SQLITE_OK) {
        
        sqlite3_stmt *stmt;
        
        BOOL prepareRel = sqlite3_prepare_v2(sqlite3Database, [query UTF8String], -1, &stmt, NULL);
        
        if (prepareRel != SQLITE_OK) {
            return nil;
        }
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            NSMutableDictionary *rowDictionary = [NSMutableDictionary dictionary];
            
            int totalColumns = sqlite3_column_count(stmt);
            
            for (int i = 0; i < totalColumns; i++) {
                
                // 获取column的名字
                const char *columnName = sqlite3_column_name(stmt, i);
                
                NSString *keyName = [NSString stringWithUTF8String:columnName];
                
                id value = nil;
                
                // 获取column的类型
                int type = sqlite3_column_type(stmt, i);
                
                if (type == SQLITE_INTEGER) {
                    long columnInt64 = (long)sqlite3_column_int64(stmt, i);
                    
                    value = [NSNumber numberWithLong:columnInt64];
                    
                } else if (type == SQLITE_FLOAT) {
                    double columnDouble = sqlite3_column_double(stmt, i);
                    
                    value = [NSNumber numberWithDouble:columnDouble];
                    
                } else if (type == SQLITE3_TEXT) {
                    const char *columnText = (const char *)sqlite3_column_text(stmt, i);
                    
                    if (columnText) {
                        value = [NSString stringWithUTF8String:columnText];
                    } else {
                        value = @"";
                    }
                }
                
                if (keyName && value) {
                    [rowDictionary setObject:value forKey:keyName];
                }
            }
            
            [resultArray addObject:rowDictionary];
        }
        
        sqlite3_finalize(stmt);
    }
    
    sqlite3_close(sqlite3Database);
    
    return resultArray;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

@end

NSString * const GQSQLiteURLQueryKey = @"gqsql";

@implementation NSString (GQSQLiteProtocol)

+ (instancetype)sqliteURLStringWithDatabaseName:(NSString *)databaseName sql:(NSString *)sql
{
    NSString *databaseFilePath = [[NSBundle mainBundle] pathForResource:[databaseName stringByDeletingPathExtension]
                                                                 ofType:[databaseName pathExtension]];
    
    NSString *encodingSql = [sql stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    return [NSString stringWithFormat:@"%@://%@?%@=%@", GQSQLiteURLProtocolKey, databaseFilePath, GQSQLiteURLQueryKey, encodingSql];
}

+ (instancetype)sqliteURLWithDatabaseFile:(NSString *)databaseFile sql:(NSString *)sql
{
    NSString *encodingSql = [sql stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    return [NSString stringWithFormat:@"%@://%@?%@=%@", GQSQLiteURLProtocolKey, databaseFile, GQSQLiteURLQueryKey, encodingSql];
}


- (NSString *)stringByBindSQLiteWithParams:(NSDictionary *)params
{
    if ([self hasPrefix:GQSQLiteURLProtocolKey]) {
        
        __block NSString *newString = [self stringByRemovingPercentEncoding];
        
        [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            newString = [newString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{{%@}}", key]
                                                             withString:obj];
        }];
        
        return [newString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else {
        return self;
    }
}

@end


@implementation NSURL (GQSQLiteProtocol)

+ (instancetype)sqliteURLWithDatabaseName:(NSString *)databaseName sql:(NSString *)sql
{
    NSString *urlString = [NSString sqliteURLStringWithDatabaseName:databaseName sql:sql];
    
    return  [NSURL URLWithString:urlString];
}

- (NSString *)gq_sql
{
    NSArray<NSString *> *queryItems = [[self.query stringByRemovingPercentEncoding] componentsSeparatedByString:@"&"];
    
    __block NSString *sql = nil;
    
    [queryItems enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:GQSQLiteURLQueryKey]) {
            
            sql = [obj stringByReplacingOccurrencesOfString:[GQSQLiteURLQueryKey stringByAppendingString:@"="]
                                                 withString:@""];
            
            *stop = YES;
        }
    }];
    
    return sql;
    
}

@end
