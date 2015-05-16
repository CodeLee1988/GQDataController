//
//  GQDataControllerTests.m
//  GQDataControllerTests
//
//  Created by 钱国强 on 14-5-25.
//  Copyright (c) 2014年 Qian GuoQiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>

#import "GQTestDataController.h"

@interface GQDataControllerTests : XCTestCase <GQDataControllerDelegate>

@property (nonatomic, strong) NSMutableArray *autoVerifiedObjects;

@property (nonatomic, strong) XCTestExpectation *testExpectation;

@end

@implementation GQDataControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    if (self.autoVerifiedObjects == nil) {
        self.autoVerifiedObjects = [NSMutableArray array];
    }
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [self.autoVerifiedObjects makeObjectsPerformSelector:@selector(verify)];
    
    [self.autoVerifiedObjects removeAllObjects];
}

- (void)testSharedDataController
{
    GQDataController *controller1 = [GQDataController sharedDataController];
    GQDataController *controller2 = [GQDataController sharedDataController];
    
    XCTAssertEqualObjects(controller1, controller2, @"单例实现错误");
}

- (void)testRequest
{
    self.testExpectation = [self expectationWithDescription:@"test"];
    
    GQTestDataController *c = [[GQTestDataController alloc] init];
    c.delegate = self;
    
    [c request];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        // ...

    }];
}

- (void)loadingDataFinished:(GQTestDataController *)controller
{
    NSLog(@"My IP: %@", controller.ip);
    
    [self.testExpectation fulfill];
}

@end
