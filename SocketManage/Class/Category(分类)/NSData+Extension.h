//
//  NSData+Extension.h
//  SocketManage
//
//  Created by jefferson on 2018/7/3.
//  Copyright © 2018年 jefferson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Extension)

/**
  字符串转为16进制data数据
 */
+(NSMutableData *)dateChangeWithString:(NSString *)string;

@end
