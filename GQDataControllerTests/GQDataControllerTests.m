//
//  GQDataControllerTests.m
//  GQDataControllerTests
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GQDataController.h"

@interface GQDataControllerTests : XCTestCase

@end

@implementation GQDataControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSharedDataController
{
    GQDataController *controller1 = [GQDataController sharedDataController];
    GQDataController *controller2 = [GQDataController sharedDataController];
    
    XCTAssertEqualObjects(controller1, controller2, @"单例实现错误");
}

@end