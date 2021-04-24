//
//  ALViewController.m
//  ALNetworking
//
//  Created by Arclin on 11/21/2018.

//

#import "ALViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <ALNetworking.h>
#import <ALNetworkingConfig.h>

#import "ALSecondViewController.h"

#import <coobjc.h>
#import "ALNetworking+Coobjc.h"
#import "COPromise+ALNetworking.h"
#import "TestModel.h"

@interface ALViewController ()

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, copy) NSString *size;

@end

@implementation ALViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.page = 2;
    self.size = @"20";
    // 示例 请求 https://tcc.taobao.com/cc/json/mobile_tel_segment.htm?tel=15919758637
    
#pragma mark - 公共配置
    /** 公共配置 建议App启动的时候配置 */
    ALNetworkingConfig *config = [ALNetworkingConfig defaultConfig];
    
    config.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
        return @{@"page":@"23333"};
    };
    
    config.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
        return @{@"headerPage":@"45555"};
    };
    
    // 以下全是可选配置
    config.defaultPrefixUrl = @"https://tcc.taobao.com/"; // 公共前缀配置
    config.defaultParams = @{@"size":@"1"}; // 公共请求体，每次请求都会添加上
    config.defaultHeader = @{@"test_header":@"1"}; // 公共请求头，每次请求都会添加上
    config.defaultCacheStrategy = ALCacheStrategyNetworkOnly; // 默认的缓存策略
    config.timeoutInterval = 30; // 超时时间
    
    [config setParams:@{@"size":@"1",@"tel":@"110"} responseObj:@"hahahaha" forUrl:@"https://tcc.taobao.com/cc/json/mobile_tel_segment.htm"];
    
    /** 公共配置结束 */
    
#pragma mark - 私有配置
    /** 私有配置 建议每个控制器/ViewModel实例化一个并持有，子类可以直接使用*/
    
    ALNetworking *networking = [[ALNetworking alloc] init];
//    networking.prefixUrl = @""; // 接口前缀，会覆盖掉公有配置的接口前缀
    networking.defaultParams = @{}; // 公共参数，会添加到公有配置的公共参数里面，如果键名一样直接覆盖
    networking.ignoreDefaultParams = NO; // YES的时候会忽略公有配置的公共参数
    
    networking.defaultHeader = @{}; // 公共头部，会添加到公有配置的公共头部里面，如果键名一样直接覆盖
    networking.ignoreDefaultHeader = NO; // YES的时候忽略公有配置的公共头部
    
    // 每次请求前都会走一遍，把里面的返回值作为新增参数，默认都会加，如果某个接口不想要，那么在请求链上加上disableDynamicParams
    @weakify(self);
    networking.dynamicParamsConfig = ^NSDictionary *(ALNetworkRequest *request) {
        @strongify(self);
        self.page++;
        return @{@"page":@(self.page)};
    };

    networking.dynamicHeaderConfig = ^NSDictionary *(ALNetworkRequest *request) {
        return @{@"networkingHeader":@"66666"};
    };

    // 判断是否是业务接口异常
    networking.handleResponse = ^NSError *(ALNetworkResponse *response, ALNetworkRequest *request) {
/*
        // 这里的code是后端约定好的判断异常处理的
        if ([response.rawData[@"code"] isEqual:@200]) { // 正常数据，返回空表示不处理
            return nil;
        } else if ([response.rawData[@"code"] isEqual:@1007]) { // 没登录，返回弹窗提示未登录，但是要弹出登录界面
            
            // 一般情况下在ViewModel中是拿不到self.navigationController的，所以这里你们自己想办法处理业务逻辑了23333
            UIViewController *loginViewController = [[UIViewController alloc] init];
            [self.navigationController pushViewController:loginViewController animated:YES];
            
            return [NSError errorWithDomain:@"test.domain" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"未登录"}];
        } else { // 其他异常
            return [NSError errorWithDomain:@"test.domain" code:-1 userInfo:@{NSLocalizedDescriptionKey:response.rawData[@"msg"]}]; // 这里的msg是后端约定好的错误提示
        }
 */
        return nil;
    };
    
    // 这里可能设计上需要改进（或者改改block名字？），这里只会返回网络链路上的问题（没网，超时，服务器异常500），业务接口异常不会走这里，这里你可以判断弹出系统设置页之类的
    networking.handleError = ^(ALNetworkRequest *request, ALNetworkResponse *response, NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络连接失败，请检查网络设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           if (@available(iOS 10.0, *)) {
               NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
               }];
           } else {
               // Fallback on earlier versions
           }
        }];
        [alert addAction:action];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    };

    // 请求之前如果你还要改参数，请求体，等等请求相关的东西，就趁现在了，这是最后的机会
    networking.handleRequest = ^ALNetworkRequest *(ALNetworkRequest *request) {
        NSLog(@"Hanle Request 请求接口：%@ 参数：%@ 请求头：%@",request.req_urlStr,request.req_params,request.req_header);
        return request;
    };
    
    // 一般用不着，这里用来改AF的请求体
//    [networking handleRequestSerialization:^AFHTTPRequestSerializer *(AFHTTPRequestSerializer *serializer) {
//        return serializer;
//    }];
    
    /** 私有配置结束 */
    
#pragma mark - 使用
    /** 使用 */

    // 以下三种方式是等价的
    // 因为前缀配好了，所以这里只要写路径
    
    // A
    networking.url(@"/cc/json/mobile_tel_segment.htm").method(ALNetworkRequestMethodGET).params(@{@"tel":@"15919758637"});
    // B
    networking.get(@"/cc/json/mobile_tel_segment.htm").params(@{@"tel":@"15919758637"});
    // C
    NSString *tel = @"15919758634";
    networking.GET(@"/cc/json/mobile_tel_segment.htm",tel);
    
    // 接下来使用第三种方式展开
    [networking.get(@"https://stest.ggwan.com/image/test/b2dc3418152cad-690x240.png").responseType(ALNetworkResponseTypeImage) setExecuteRequest:^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
        NSLog(@"%@",response.rawData);
    }];
    
    
    // 普通方式
    [networking
    .get(@"https://www.v2ex.com/api/topics/hot.json")
//    .header(@{@"headerPage":@"000"})
     .minRepeatInterval(10)
     .params(@{@"size":@"1",@"tel":@"110"})                         //会覆盖掉dynamicParamsConfig配置的参数
//     .mockData(@{@"xxxxx":@""},YES)
//    .responseType(ALNetworkResponseTypeHTTP)            // 一般情况下不用写这个，因为我这个接口比较特殊，返回体不是JSON格式
    .paramsType(ALNetworkRequestParamsTypeDictionary)   // 默认是这个，所以也可以不用写，有些情况需要使用JSON请求的话，那么就改成ALNetworkRequestParamsTypeJSON
    .cacheStrategy(ALCacheStrategyNetworkOnly)          // 默认是NetworkOnly，公共配置可以改默认策略，选用这个的时候也可以不用写，具体看枚举的注释，
    .name(@"唯一标识符")                                   //自己给他起个名字，到时候取消请求的时候直接用这个标识符
//     .disableDynamicParams                             // 不启用dynamicParamsConfig动态参数配置 这里我想用，就注释掉了
     setExecuteRequest:^(ALNetworkResponse *response, ALNetworkRequest *request, NSError *error) {
//        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//        if ([response.rawData isKindOfClass:NSData.class]) {
//            NSLog(@"普通方式--响应：%@",[[NSString alloc] initWithData: response.rawData encoding:enc]);
//        } else {
            NSLog(@"普通方式--响应：%@", response.rawData);
//        }
//        NSLog(@"普通方式--响应来自：%@",response.isCache ? @"缓存" : @"网络");
//        NSLog(@"普通方式--请求链接：%@",request.urlStr);
//        NSLog(@"普通方式--请求头：%@",request.header);
//        NSLog(@"普通方式--请求参数：%@",request.params);
//        NSLog(@"普通方式--错误：%@",error); // 这里的错误包括网络链路错误和业务接口异常
    }];
    
//    [networking.url(@"https://media-yd.ggwan.com/audio/nuanxin/concentration.mp4").downloadDestPath([NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Video"]).progress(^(float progress){
//        NSLog(@"下载进度%f",progress);
//    }).executeDownloadSignal subscribeNext:^(id  _Nullable x) {
//        NSLog(@"x = %@",x);
//    } error:^(NSError * _Nullable error) {
//        NSLog(@"error = %@",error);
//    }];
//
    // 协程
//    co_launch_onqueue(dispatch_get_main_queue(), ^{
//
//        NSArray<TestModel *> *models =  await(networking.get(@"https://www.v2ex.com/api/topics/hot.json").cacheStrategy(ALCacheStrategyNetworkOnly).name(@"唯一标识符").co_executeRequest.array_with(@"",TestModel));
//        [models enumerateObjectsUsingBlock:^(TestModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSLog(@"%@",model.url);
//            NSLog(@"%@",model.title);
//        }];
//    });
//    NSLog(@"============================================");
    
    // RAC方式，上面说过的就忽略不写了
//    RACSignal *signal = networking.GET(@"/cc/json/mobile_tel_segment.htm",tel).responseType(ALNetworkResponseTypeHTTP).executeSignal;
//
//    [signal subscribeNext:^(RACTuple *tuple) {
//        ALNetworkResponse *resp = tuple.first;
//        ALNetworkRequest *req = tuple.second;
//        NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//        NSLog(@"RAC方式--响应：%@", [[NSString alloc] initWithData: resp.rawData encoding:enc]);
//        NSLog(@"RAC方式--请求链接：%@",req.urlStr);
//    } error:^(NSError * _Nullable error) {
//        NSLog(@"RAC方式--错误：%@",error); // 这里的错误包括网络链路错误和业务接口异常
//    }];

    // 下面是RAC基础操作
//    [[RACSignal merge:@[signal1,signal2,signal3]] subscribeError:^(NSError * _Nullable error) {
//
//    }];
//
//    [[RACSignal zip:@[]] subscribeNext:^(RACTuple * _Nullable x) {
//
//    }];
//
//    [[RACSignal concat:@[]] subscribeNext:^(RACTuple * _Nullable x) {
//
//    }];
//
//    RACSignal *flattenSignal = [signal1 flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
//        id test = value[@"xxx"];
//        return networking.GET(@"http://myip.ipip.net",test).responseType(ALNetworkResponseTypeHTTP).executeSignal;
//    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    ALSecondViewController *vc = [[ALSecondViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
