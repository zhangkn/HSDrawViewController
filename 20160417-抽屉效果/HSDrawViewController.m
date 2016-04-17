//
//  HSDrawViewController.m
//  20160417-抽屉效果
//
//  Created by devzkn on 4/17/16.
//  Copyright © 2016 hisun. All rights reserved.
//

#import "HSDrawViewController.h"
#define HSMaxY 60
#define HSScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)
#define HSScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)

@interface HSDrawViewController ()

@property (nonatomic,weak) UIView *leftView;
@property (nonatomic,weak) UIView *rightView;
@property (nonatomic,weak) UIView *mainView;
@property (nonatomic,assign) BOOL isDraging;//是否正在拖动，用于判读是否可以复位


@end

@implementation HSDrawViewController

- (UIView *)leftView{
    if (nil == _leftView) {
        UIView *tmpView = [[UIView alloc]initWithFrame:self.view.bounds];
        _leftView = tmpView;
        [self.view addSubview:_leftView];
    }
    return _leftView;
}
- (UIView *)rightView{
    if (nil == _rightView) {
        UIView *tmpView = [[UIView alloc]initWithFrame:self.view.bounds];
        _rightView = tmpView;
        [self.view addSubview:_rightView];
    }
    return _rightView;
}
- (UIView *)mainView{
    if (nil == _mainView) {
        UIView *tmpView = [[UIView alloc]initWithFrame:self.view.bounds];
        _mainView = tmpView;
        [self.view addSubview:_mainView];
    }
    return _mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //1.添加子控件
    [self addChildView];
    //2添加观察者--监听对象属性(通知)
    /*
     anObserver
     The object to register for KVO notifications. The observer must implement the key-value observing method observeValueForKeyPath:ofObject:change:context:.
     keyPath
     The key path, relative to the receiver, of the property to observe. This value must not be nil.
     options
     A combination of the NSKeyValueObservingOptions values that specifies what is included in observation notifications. For possible values, see NSKeyValueObservingOptions.
     context
     Arbitrary data that is passed to anObserver in observeValueForKeyPath:ofObject:change:context:.
     
     */
    [self.mainView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)addChildView{
    [self.leftView setBackgroundColor:[UIColor greenColor]];
    [self.rightView setBackgroundColor:[UIColor blueColor]];
    [self.mainView setBackgroundColor:[UIColor redColor]];
    
}

#pragma mark - touches
#define HSRightTarget 250
#define HSLeftTarget -220

/**
 抽屉效果的定位
 当minx >0.5HSScreenWidth 定位到右侧
 当Max <0.5HSScreenWidth 定位到左侧

 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //1、复位
    if (self.isDraging == NO && self.mainView.frame.origin.x != 0) {
        [UIView animateWithDuration:0.25 animations:^{
            //复位
            [self.mainView setFrame:self.view.bounds];
        }];
    }
    //2定位
    CGFloat target = 0;
    if (self.mainView.frame.origin.x >0.5*HSScreenWidth) {
        //定位到右侧
        target = HSRightTarget;
    }else if (CGRectGetMaxX(self.mainView.frame) < 0.5*HSScreenWidth ){
        target = HSLeftTarget;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        //复位、定位
        if (target) {//不为0 才需要定位
            CGFloat offsetX = target - self.mainView.frame.origin.x;
            //需要定位
            [self.mainView setFrame:[self getCurrentFrameWithOffsetX:offsetX]];
        }else{
            // 复位
            [self.mainView setFrame:self.view.bounds];
        }
    }];
    [self setIsDraging:NO];//停止拖动
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //就算偏移量

    
    UITouch *touch = [touches anyObject];
    CGPoint current = [touch locationInView:self.mainView];
    CGPoint pre = [touch previousLocationInView:self.mainView];
    //x的偏移量
    CGFloat offsetX = current.x - pre.x;
    [self.mainView setFrame:[self getCurrentFrameWithOffsetX:offsetX]];
    self.isDraging = YES;
  
}

/*
 根据x的便宜量计算frame
 
 */

- (CGRect)getCurrentFrameWithOffsetX:(CGFloat) offsetX{
    //y的偏移量
    CGFloat offsetY;
    if (self.mainView.frame.origin.x<0) {
        offsetY = HSMaxY*offsetX/HSScreenWidth*-1;//保证正数，即保证currentHeight 小于screenHeight
        
    }else{
        offsetY = HSMaxY*offsetX/HSScreenWidth;//保证正数，即保证currentHeight 小于screenHeight
    }
    CGFloat currentHeight = HSScreenHeight-2*offsetY;//当前的高度
    CGFloat scale =(currentHeight)/HSScreenHeight;//比例
    CGRect mainFrame = self.mainView.frame;
    mainFrame.origin.x += offsetX;
    mainFrame.size.height *= scale;
    mainFrame.size.width *= scale;
    mainFrame.origin.y = (HSScreenHeight- mainFrame.size.height)*0.5;
    return mainFrame;
}

#pragma  mark -  The observer must implement the key-value observing method observeValueForKeyPath:ofObject:change:context:.
/*
 keyPath: The key path, relative to object, to the value that has changed.
 object: The source object of the key path keyPath.
 change: A dictionary that describes the changes that have been made to the value of the property at the key path keyPath relative to object. Entries are described in Change Dictionary Keys.
 context: The value that was provided when the receiver was registered to receive key-value observation notifications.
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (self.mainView.frame.origin.x < 0) {
        [self.leftView setHidden:YES];//显示右边视图
        [self.rightView setHidden:NO];
    }else if (self.mainView.frame.origin.x >0){//往右移动
        [self.rightView setHidden:YES];
        [self.leftView setHidden:NO];
    }
}



@end
