//
//  GQTestDataController.m
//  GQDataController
//
//  Created by 钱国强 on 14-7-31.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import "GQTestDataController.h"

@implementation GQTestDataController

- (NSArray *)requestURL
{
    return @[@"http://httpbin.org/ip"];
}

- (void)handleWithObject:(id)object
{
    self.ip = [object objectForKey:@"origin"];
}

@end
