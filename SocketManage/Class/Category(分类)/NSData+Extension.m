//
//  NSData+Extension.m
//  SocketManage
//
//  Created by jefferson on 2018/7/3.
//  Copyright © 2018年 jefferson. All rights reserved.
//

#import "NSData+Extension.h"

@implementation NSData (Extension)

+ (NSMutableData *)dateChangeWithString:(NSString *)string
{
    NSData *date = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[date bytes];
    //下面是Byte 转换为16进制。
    NSString *resultString=@"";
    for(int i = 0 ; i < [date length]; i++){
        
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            resultString = [NSString stringWithFormat:@"%@0%@",resultString,newHexStr];
        else
            resultString = [NSString stringWithFormat:@"%@%@",resultString,newHexStr];
    }
    NSString *command = [resultString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *resultData= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i = 0; i < [command length] / 2; i++) {
        
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [resultData appendBytes:&whole_byte length:1];
    }
    return resultData;
}

@end
