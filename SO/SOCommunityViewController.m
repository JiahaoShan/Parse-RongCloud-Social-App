//
//  SOCommunityViewController.m
//  SO
//
//  Created by Guanqing Yan on 7/21/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOCommunityViewController.h"
#import "SOCommunityContentView.h"
#import "SOPersonAvatarView.h"

static CGRect CGRectWithCenterAndSize(CGPoint p, CGSize s){
    return CGRectMake(p.x-s.width/2, p.y-s.height/2, s.width, s.height);
}
static CGRect centerRect(CGSize contentSize,CGSize visibleSize){
    return CGRectMake((contentSize.width-visibleSize.width)/2, (contentSize.height-visibleSize.height)/2, visibleSize.width, visibleSize.height);
}
static CGPoint centerRectUpperLeftPoint(CGSize contentSize, CGSize visibleSize){
    return CGPointMake((contentSize.width-visibleSize.width)/2, (contentSize.height-visibleSize.height)/2);
}

@interface SOCommunityViewController ()<UIScrollViewDelegate,SOCommunityContentViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *viewCountLabel;
@property (weak, nonatomic) IBOutlet SOCommunityContentView *contentView;
@property (strong, nonatomic) UIView* contentBackgroudView;
@property (nonatomic) NSMutableArray* viewsArray;
@property (nonatomic) NSMutableArray* hiddenFramesArray;
@property (nonatomic) BOOL animating;
@end

@implementation SOCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self.contentView setContentSize:CGSizeMake(3000, 3000)];
    [self.contentView setDelegate:self];
    [self generateFrames];
    [self checkVisible:true];
    self.animating = false;
}

-(void)generateFrames{
    _viewsArray = [[NSMutableArray alloc] init];
    _hiddenFramesArray = [[NSMutableArray alloc] init];
    if (!_contentBackgroudView) {
        _contentBackgroudView = [[UIView alloc] init];
        _contentBackgroudView.tag = 1;
        [self.contentView addSubview:self.contentBackgroudView];
        [self.contentBackgroudView setUserInteractionEnabled:false];
    }
    radius=0;
    int num = arc4random()%200;
        [self addRandomFrame:num];
    
    [self.contentBackgroudView setFrame:CGRectMake(radius, radius, 2*radius, 2*radius)];
    [self.contentView setContentSize:self.contentBackgroudView.frame.size];
    [self.contentView setContentRadius:radius];
    self.contentView.communityViewDelegate=self;
}

static int count=0;
-(void)incrementCount{
    count++;
    [self.viewCountLabel setText:[NSString stringWithFormat:@"%d",count]];
}

-(void)decrementCount{
    count--;
    [self.viewCountLabel setText:[NSString stringWithFormat:@"%d",count]];
}

-(NSArray*)checkVisible:(BOOL)show{
    NSMutableArray* visible = [[NSMutableArray alloc] init];
    CGRect visibleRect = {self.contentView.contentOffset,self.view.bounds.size};
    visibleRect = [self.contentBackgroudView convertRect:visibleRect fromView:self.contentView];
    for (NSInteger i = self.hiddenFramesArray.count-1;i>=0;i--) {
        NSString* value = self.hiddenFramesArray[i];
        CGRect rect = CGRectFromString(value);
        if (CGRectIntersectsRect(visibleRect, rect)) {
            [self.hiddenFramesArray removeObjectAtIndex:i];
            if (show) {
                [self addViewWithFrame:rect];
            }else{
                [visible addObject:NSStringFromCGRect(rect)];
            }
            [self incrementCount];
        }
    }
    for (NSInteger i = self.viewsArray.count-1;i>=0;i--) {
        UIView* v = self.viewsArray[i];
        if (!CGRectIntersectsRect(visibleRect, v.frame)) {
            [v removeFromSuperview];
            [self.viewsArray removeObjectAtIndex:i];
            [self.hiddenFramesArray addObject:NSStringFromCGRect(v.frame)];
            [self decrementCount];
        }
    }
    if (show) {
        return nil;
    }else{
        return visible;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.animating) {
        [self checkVisible:true];
    }
    [self.contentView setNeedsDisplay];//necessary
}

static CGFloat radius = 20;
-(void)addRandomFrame:(int)count{
    //    BOOL collide = false;
    //    CGRect temp;
    //    do {
    //        CGFloat x = (CGFloat)(arc4random()%1000);
    //        CGFloat y = (CGFloat)(arc4random()%1000);
    //        temp = CGRectMake(x, y, 50, 80);
    //        BOOL b = false;
    //        for (NSValue* v in self.hiddenFramesArray) {
    //            if (CGRectIntersectsRect([v CGRectValue], temp)) {
    //                collide=true;
    //                b=true;
    //                break;
    //            }
    //        }
    //        if (!b) {
    //            collide = false;
    //        }
    //    } while (collide);
    //
    //    [self.hiddenFramesArray addObject:[NSValue valueWithCGRect:temp]];
    CGFloat rd = (arc4random()%50 / 50.0f);
    CGSize size = self.contentBackgroudView.bounds.size;
    //CGPoint center = CGPointMake(size.width/2, size.height/2);
    CGPoint center = CGPointZero;
    [self.hiddenFramesArray addObject:NSStringFromCGRect(CGRectWithCenterAndSize(center, CGSizeMake(50, 80)))];
    int currCount = 1;
    while (currCount<count) {
        BOOL placed = false;
        CGRect newRect;
        int numStep = currCount>50?currCount/5:8;
        CGFloat step = M_PI / numStep;
            for (int j=0; j<numStep*2 && currCount<count; j++) {
                //CGFloat angle = (arc4random()%1000)/500.0f * M_PI;
                BOOL b = false;
                CGFloat angle = j * step + rd;
                CGFloat x = center.x + radius*cos(angle);
                CGFloat y = center.y + radius*sin(angle);
                newRect = CGRectWithCenterAndSize(CGPointMake(x, y), CGSizeMake(50, 80));
                for (NSString* v in self.hiddenFramesArray) {
                    if (CGRectIntersectsRect(CGRectFromString(v), newRect)) {
                        placed=false;
                        b = true;
                        break;
                    }
                }
                if (!b) {
                    placed=true;
                    currCount++;
                    [self.hiddenFramesArray addObject:NSStringFromCGRect(newRect)];
                }
            }
        if (!placed) {
            radius+=15;
        }
    }
}

-(void)addViewWithFrame:(CGRect)frame{
//    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"SOPersonAvatarView"
//                                                         owner:self
//                                                       options:nil];
//    SOPersonAvatarView *newView = [nibContents objectAtIndex:0];
     SOPersonAvatarView *newView = [[SOPersonAvatarView alloc]init];

    [newView setTranslatesAutoresizingMaskIntoConstraints:true];
    newView.frame = frame;
    [newView setName:@"me"];
    [newView setAvatar:nil];
    [self.contentBackgroudView addSubview:newView];
    [self.viewsArray addObject:newView];
    
}
-(void)didDoubleTapViewAtIndex:(NSInteger)index{
    [self.contentView setContentOffset:centerRectUpperLeftPoint(self.contentView.contentSize, self.contentView.bounds.size) animated:true];
    NSLog(@"%f",CFAbsoluteTimeGetCurrent());
    self.animating = true;
    [UIView animateWithDuration:0.2 animations:^{
        NSLog(@"%f",CFAbsoluteTimeGetCurrent());
        for (UIView* v in self.viewsArray) {
            [v setCenter:CGPointZero];
        }
        NSLog(@"%f",CFAbsoluteTimeGetCurrent());
    } completion:^(BOOL finished) {
        NSLog(@"%f",CFAbsoluteTimeGetCurrent());
        for (UIView* v in self.viewsArray) {
            [v removeFromSuperview];
        }
        NSLog(@"%f",CFAbsoluteTimeGetCurrent());
        [self generateFrames];
        NSLog(@"%f",CFAbsoluteTimeGetCurrent());
        NSArray* arr = [self checkVisible:false];
        NSLog(@"%f",CFAbsoluteTimeGetCurrent());
        for (NSString* str in arr) {
            //NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"SOPersonAvatarView"
                                //                                 owner:self
                                 //                              options:nil];
            //SOPersonAvatarView *newView = [nibContents objectAtIndex:0];
            SOPersonAvatarView* newView = [[SOPersonAvatarView alloc] initWithFrame:CGRectZero];
            [newView setTranslatesAutoresizingMaskIntoConstraints:true];
            [newView setCenter:CGPointZero];
            //[newView setFrame:CGRectWithCenterAndSize(CGPointZero,CGSizeMake(50, 80))];
            [newView setName:@"me"];
            [newView setAvatar:nil];
            [self.contentBackgroudView addSubview:newView];
            [self.viewsArray addObject:newView];
        }
        NSLog(@"%f",CFAbsoluteTimeGetCurrent());
        [UIView animateWithDuration:0.2 animations:^{
            for (int i=0;i<arr.count; i++) {
                [[self.viewsArray objectAtIndex:i] setFrame:CGRectFromString(arr[i])];
            }
            [self.contentView setContentOffset:centerRectUpperLeftPoint(self.contentView.contentSize, self.contentView.bounds.size) animated:false];
        } completion:^(BOOL finished) {
            self.animating = false;
            [self checkVisible:true];
            //[self.contentView setContentOffset:centerRectUpperLeftPoint(self.contentView.contentSize, self.contentView.bounds.size) animated:true];
        }];
    }];
}

@end
