//
//  ViewController.m
//  kTest
//
//  Created by kim on 2018/6/17.
//  Copyright © 2018年 kedc. All rights reserved.
//

#import "ViewController.h"

#import <objc/runtime.h>

#import "User.h"
#import "SuperUser.h"
#import "KVBox.h"

@interface ViewController () {
    int _time;
    NSTimer *_timer;

    KVBox *_box;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self loadTest];
    
//    [self addScroll];
//    [self setTimer];

    _box = [[KVBox alloc] init];

    NSLog(@"Adding observer...");

    [_box addObserver:self
           forKeyPath:@"color"
              options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
              context:@"color of box"];

    NSLog(@"Changing value by setValue forKey...");
    [_box setValue:[UIColor blueColor] forKey:@"color"]; // KVC

    NSLog(@"Changing value by setValue forKeyPath......");
    [_box setValue:@"kim" forKeyPath:@"maker.makerName"]; // KVC

    NSLog(@"maker name: %@", [[_box valueForKey:@"maker"] valueForKey:@"makerName"]);
}

# pragma mark - 验证 load & initialize
- (void)loadTest {
    User *user = [[User alloc] init]; // 在使用的时候才会被加载
    User *user2 = [[User alloc] init]; // 第二次使用不会被加载
//    SuperUser *superUser = [[SuperUser alloc] init];
}

# pragma mark - 验证 RunLoop 因为滑动导致 NSTimer 的停顿
- (void)addScroll {
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.backgroundColor = [UIColor redColor];
    scroll.frame = CGRectMake(0, 200, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 400);
    scroll.contentSize = self.view.bounds.size;
    [self.view addSubview:scroll];

    CGFloat labelHeight = 50;
    int count = ceil(self.view.bounds.size.height / labelHeight);
    for(int i = 0; i < count; i++){
        UILabel *tmpLabel = [[UILabel alloc] init];
        tmpLabel.frame = CGRectMake(0, i * labelHeight, 100, labelHeight);
        tmpLabel.text = [NSString stringWithFormat:@"yoyo: %d", i];
        [scroll addSubview:tmpLabel];
    }
}

- (void)setTimer {
    _time = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timePrint) userInfo:nil repeats:true];

    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes]; // 如果不加这一句的话在滑动 scrollView 的时候会导致打印台不打印
}

- (void)timePrint {
    NSLog(@"Timer print: %d", _time);
    _time++;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    UIColor *old = change[NSKeyValueChangeOldKey];
    UIColor *new = change[NSKeyValueChangeNewKey];
    NSLog(@"%@ has changed. old: %@, new: %@", keyPath, old, new);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_box removeObserver:self forKeyPath:@"color"];
}

@end
