//
//  GQModelAdapter.h
//  GQDataController
//
//  Created by QianGuoqiang on 16/7/13.
//  Copyright (c) 2016年 Qian GuoQiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GQModelAdapter <NSObject>

- (instancetype)initWithJSONObject:(id)jsonObject modelClass:(Class)modelClass;

- (id)modelObject;

- (NSArray *)modelObjectList;

@optional

- (NSError *)error;

@end

