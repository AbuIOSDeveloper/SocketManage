//
//  SocketManage.h
//  SocketManage
//
//  Created by jefferson on 2018/7/3.
//  Copyright © 2018年 jefferson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

static const int          AbuReadTimeOut = -1;
static const unsigned int AbuPostCode = 0x2b1;
static const unsigned int AbuEndCode = 0;
static const int          AbuServicePort1 = 8080; //  端口
static const int          AbuServicePort2 = 8080; //  端口
static NSString *const    AbuServiceIP = @"";//IP

@interface SocketManage : NSObject<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@property (nonatomic, assign, getter=isIgnoreFreeGift) BOOL ignoreFreeGift;

/**
 创建socket
 */
+ (SocketManage *)Socket;

/**
 socket连接服务器
 */
- (void)connectSocketWithParame:(NSString *)parame;

/**
 主动断开链接
 */
- (void)cutOff;

/**
 更换端口
 */
- (void)changeScoketPort:(NSInteger)port;

@end
