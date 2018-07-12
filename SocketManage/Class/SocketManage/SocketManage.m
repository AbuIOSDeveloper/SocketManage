//
//  SocketManage.m
//  SocketManage
//
//  Created by jefferson on 2018/7/3.
//  Copyright © 2018年 jefferson. All rights reserved.
//

#import "SocketManage.h"
#import "NSData+Extension.h"
#import "Reachability.h"

//通知中心
#define AbuNotificationCenter [NSNotificationCenter defaultCenter]

@interface SocketManage()
/**
 * 发送心跳包
 */
@property (nonatomic, strong) NSTimer  *      heartbeatTimer;
/**
 * 向服务器传参
 */
@property (nonatomic, strong) NSString *      parame;
/**
 * 服务器连接状态
 */
@property (nonatomic, assign) BOOL            serviceConnected;
/**
 * 重新连接服务器状态
 */
@property (nonatomic, assign) BOOL            roomConnected;
/**
 * 返回数据整理拼接
 */
@property (nonatomic, strong) NSMutableData * contentData;
/**
 * 更换socket端口
 */
@property (nonatomic, assign) NSInteger       port;

@property (nonatomic, assign) BOOL            isReachable;

@end

@implementation SocketManage
static  SocketManage * Socket = nil;

+ (SocketManage *)Socket
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (Socket == nil) {
            Socket = [[self alloc] init];
            Socket.socket = [[GCDAsyncSocket alloc] initWithDelegate:Socket delegateQueue:dispatch_get_main_queue()];
        }
    });
    return Socket;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (Socket == nil) {
            Socket = [super allocWithZone:zone];
        }
    });
    return Socket;
}

- (id)copy{
    return self;
}

- (id)mutableCopy{
    return self;
}


#pragma mark -------------------------- socket连接服务器
- (void)connectSocketWithParame:(NSString *)parame
{
    _parame = parame;
    if (self.socket.isConnected) {//如果服务器正在连接中，则断开先
        [self cutOff];//主动断开服务器
    }
    //连接服务器
    NSError * error = nil;
    BOOL result = [self.socket connectToHost:AbuServiceIP onPort:AbuServicePort1 error:&error];
    //是否连接成功
    if (result) {
        NSLog(@"socket连接成功");
         [AbuNotificationCenter addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];//网络变更情况处理
        self.serviceConnected = YES;//记录服务器连接状态
        [self connect];//连接
        [self startHeartbeat];
    }
    else
    {
        NSLog(@"客户端连接服务器失败");
        
        self.serviceConnected = NO;
    }
}


#pragma mark -------------------------- 主动断开服务器
- (void)cutOff
{
    self.port = 0;
    [self.socket writeData:nil withTimeout:AbuReadTimeOut tag:1];
    [self.heartbeatTimer invalidate];
    [self.socket disconnect];
}

#pragma mark -------------------------- 更换端口
- (void)changeScoketPort:(NSInteger)port
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (port == self.port) {
            return ;
        }
        self.port = port;
        // 1. 与服务器的socket链接起来
        NSError *error = nil;
        NSInteger servicePort = self.port == 1 ? AbuServicePort1 : AbuServicePort2;
        BOOL result = [self.socket connectToHost:AbuServiceIP onPort:servicePort error:&error];
        if (result) {
            NSLog(@"客户端连接服务器成功");
            //记录服务器连接状态
            self.serviceConnected = YES;
            //连接服务器
            [self connect];
        }
        else
        {
           NSLog(@"客户端连接服务器失败");
           self.serviceConnected = NO;
        }
    });
}


#pragma mark -------------------------- 处理网络状态变化
- (void)reachabilityChanged:(NSNotification *)notification{
    Reachability * reach = [notification object];
    if ([reach isKindOfClass:[Reachability class]]) {
        NetworkStatus  status = [reach currentReachabilityStatus];
        if (status == NotReachable) {//未连接网络
            self.isReachable = NO;
        }
        else if (status == ReachableViaWiFi || status == ReachableViaWWAN)
        {
            NSInteger port = self.port;
            self.port = 999;
            [self changeScoketPort:port];
            self.isReachable = YES;
        }
    }
    
}


#pragma mark -------------------------- 连接
- (void)connect
{
    NSLog(@"连接服务器");
    
    [self.socket writeData:nil withTimeout:AbuReadTimeOut tag:1];
}

#pragma mark -------------------------- 开始发送心跳消息
- (void)startHeartbeat{
    
    [_heartbeatTimer invalidate];
    _heartbeatTimer = nil;
    
    _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_heartbeatTimer forMode:NSRunLoopCommonModes];
    
    [_heartbeatTimer fire];
}


- (void)heartBeat{
  
    [self.socket writeData:nil withTimeout:AbuReadTimeOut tag:1];
}
#pragma mark -------------------------- 发送请求
- (void)sendMessage{
    
    [self.socket writeData:nil withTimeout:AbuReadTimeOut tag:1];
}


#pragma mark -------------------------- GCDAsyncSocketDelegate

#pragma mark -------------------------- 连接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接服务器成功");
    SocketManage * socket = [SocketManage Socket];
    socket.socket = self.socket;
}

#pragma mark -------------------------- 断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if (err) {
        NSLog(@"连接失败");
        if ([err.description containsString:@"7"]) {//服务器认为心跳包问题断开, 重连
            [self connectSocketWithParame:self.parame];
        }
    }
}

#pragma mark -------------------------- 读取数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
   
    if (data.length != 0){

        [self sendMessage];
        [self startHeartbeat];
    }
    [self.socket readDataWithTimeout:AbuReadTimeOut tag:0];
}

#pragma mark -------------------------- 数据发送成功
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //发送完数据手动读取，-1不设置超时
    [sock readDataWithTimeout:AbuReadTimeOut tag:tag];
}



@end
