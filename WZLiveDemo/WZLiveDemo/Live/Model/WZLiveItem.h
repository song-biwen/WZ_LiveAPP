//
//  WZLiveItem.h
//  WZLiveDemo
//
//  Created by songbiwen on 2016/10/20.
//  Copyright © 2016年 songbiwen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WZCreatorItem;

@interface WZLiveItem : NSObject
/** 直播流地址 */
@property (nonatomic, copy) NSString *stream_addr;
/** 关注人 */
@property (nonatomic, assign) NSUInteger online_users;
/** 城市 */
@property (nonatomic, copy) NSString *city;
/** 主播 */
@property (nonatomic, strong) WZCreatorItem *creator;

@end
