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
#import "User.h"
#import "SOUICommons.h"

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
@property (strong, nonatomic) IBOutlet SOCommunityContentView *contentView;
@property (strong, nonatomic) UIView* contentBackgroudView;
@property (strong,nonatomic) UIView* currentUserAvatarView;
@property (nonatomic) NSMutableArray* viewsArray;
@property (nonatomic) NSMutableArray* framesArray;
@property (nonatomic) NSArray* userArray;
@property (nonatomic) BOOL animating;
//datasource
@property (nonatomic) PFQuery* currentQuery;
@end

@implementation SOCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.contentView setDelegate:self];
    [self startQueryFriendsOfUser:[self currentUser] batch:0 completion:^(int batchIndex, NSArray *users) {
        self.userArray = users;
        [self initialize];
        [self generateFrames:(int)users.count];
        [self adjustFrames];
        //[self checkVisible:true];
        for (int i=0; i<users.count; i++) {
            User* user = users[i];
            PFFile* thumbnail = [user portraitThumbnail];
            [(SOPersonAvatarView*)self.viewsArray[i] setAvatar:thumbnail];
        }
        self.animating = false;
    }];
}

-(void)initialize{
    _viewsArray = [[NSMutableArray alloc] init];
    _framesArray = [[NSMutableArray alloc] init];
    if (!_contentBackgroudView) {
        _contentBackgroudView = [[UIView alloc] init];
        _contentBackgroudView.tag = 1;
        [self.contentView addSubview:self.contentBackgroudView];
        [self.contentBackgroudView setUserInteractionEnabled:false];
        [self.contentBackgroudView setBackgroundColor:[UIColor redColor]];
    }
    radius=0;
}

static CGFloat radius;
-(void)generateFrames:(int)count{
    
    CGFloat rd = (arc4random()%50 / 50.0f);
    CGPoint center = CGPointZero;
    int currCount = 1;
    while (currCount<count) {
        BOOL placed = false;
        CGRect newRect;
        int numStep = currCount>50?currCount/5:8;
        CGFloat step = M_PI / numStep;
        for (int j=0; j<numStep*2 && currCount<count; j++) {
            BOOL b = false;
            CGFloat angle = j * step + rd;
            CGFloat x = center.x + radius*cos(angle);
            CGFloat y = center.y + radius*sin(angle);
            newRect = CGRectWithCenterAndSize(CGPointMake(x, y), CGSizeMake(50, 80));
            for (UIView* v in self.viewsArray) {
                if (CGRectIntersectsRect(v.frame, newRect)) {
                    placed=false;
                    b = true;
                    break;
                }
            }
            if (!b) {
                placed=true;
                currCount++;
                [self addAvatarViewWithFrame:newRect User:[self.userArray objectAtIndex:currCount] toView:self.contentBackgroudView];
                [self.framesArray addObject:NSStringFromCGRect(newRect)];
            }
        }
        if (!placed) {
            radius+=15;
        }
    }
}

-(void)adjustFrames{
    [self.contentBackgroudView setFrame:CGRectMake(radius, radius, 0, 0)];
    [self.contentView setContentSize:CGSizeMake(radius*2, radius*2)];
    if (radius < [SOUICommons screenWidth]/2) {
        CGFloat heightPad = [SOUICommons screenHeight]/2-radius;
        CGFloat widthPad = [SOUICommons screenWidth]/2-radius;
        [self.contentView setContentInset:UIEdgeInsetsMake(heightPad, widthPad, heightPad, widthPad)];
    }else{
        [self.contentView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    [self.contentView setContentOffset:centerRectUpperLeftPoint(self.contentView.contentSize, self.contentView.bounds.size)];
    [self.contentView setContentRadius:radius];
    self.contentView.communityViewDelegate=self;
}

//if show is true, then view is added to contentBackgroundView, nil will be returned
//if show is false, views will not be added, and will be returned in an array
//-(NSArray*)checkVisible:(BOOL)show{
//    NSMutableArray* visible = [[NSMutableArray alloc] init];
//    CGRect visibleRect = {self.contentView.contentOffset,self.view.bounds.size};
//    visibleRect = [self.contentBackgroudView convertRect:visibleRect fromView:self.contentView];
//    for (NSInteger i = self.hiddenFramesArray.count-1;i>=0;i--) {
//        NSString* value = self.hiddenFramesArray[i];
//        CGRect rect = CGRectFromString(value);
//        if (CGRectIntersectsRect(visibleRect, rect)) {
//            [self.hiddenFramesArray removeObjectAtIndex:i];
//            if (show) {
//                [self addAvatarViewWithFrame:rect User:[self.userArray objectAtIndex:i] toView:self.contentBackgroudView];
//            }else{
//                [visible addObject:NSStringFromCGRect(rect)];
//            }
//        }
//    }
//    for (NSInteger i = self.viewsArray.count-1;i>=0;i--) {
//        UIView* v = self.viewsArray[i];
//        if (!CGRectIntersectsRect(visibleRect, v.frame)) {
//            [v removeFromSuperview];
//            [self.viewsArray removeObjectAtIndex:i];
//            [self.hiddenFramesArray addObject:NSStringFromCGRect(v.frame)];
//        }
//    }
//    if (show) {
//        return nil;
//    }else{
//        return visible;
//    }
//}
-(void)didDoubleTapViewAtIndex:(NSInteger)index{
    [self.contentView setContentOffset:centerRectUpperLeftPoint(self.contentView.contentSize, self.contentView.bounds.size) animated:true];
    self.animating = true;
    [self.contentView setScrollEnabled:NO];
    [UIView animateWithDuration:0.2 animations:^{
        for (UIView* v in self.viewsArray) {
            [v setCenter:CGPointZero];
        }
    } completion:^(BOOL finished) {
        for (UIView* v in self.viewsArray) {
            [v removeFromSuperview];
        }
        [self startQueryFriendsOfUser:[self currentUser] batch:0 completion:^(int batchIndex, NSArray *users) {
            self.userArray = users;
            [self initialize];
            [self generateFrames:(int)users.count];
            //[self checkVisible:true];
            for (int i=0; i<users.count; i++) {
                [self addAvatarViewWithFrame:CGRectMake(-25,-40,50,80) User:users[i] toView:self.contentBackgroudView];
            }
            [UIView animateWithDuration:0.2 animations:^{
                for (int i=0;i<users.count; i++) {
                    [[self.viewsArray objectAtIndex:i] setFrame:CGRectFromString(self.framesArray[i])];
                }
            } completion:^(BOOL finished) {
                [self.contentView setScrollEnabled:YES];
                //[self checkVisible:true];
                self.animating = false;
            }];
        }];
    }];
}

-(SOPersonAvatarView*)addAvatarViewWithFrame:(CGRect)frame User:(User*)user toView:(UIView*)view{
    SOPersonAvatarView* newView = [[SOPersonAvatarView alloc] initWithFrame:CGRectZero];
    [newView setTranslatesAutoresizingMaskIntoConstraints:true];
    newView.frame = frame;
    [newView setName:[user username]];
    [newView setAvatar:[user portraitThumbnail]];
    [self.contentBackgroudView addSubview:newView];
    [self.viewsArray addObject:newView];
    return newView;
}

#pragma mark UISCROLLVIEWDELEGATE
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.animating) {
        //[self checkVisible:true];
    }
    [self.contentView setNeedsDisplay];//necessary
    NSLog(@"didScroll");
}

#pragma mark datasource
-(User*)currentUser{
    return [User currentUser];
}

-(void)startQueryFriendsOfUser:(User*)user batch:(int)batch completion:(void(^)(int batchIndex, NSArray* users))completion{
    NSLog(@"%@",self.currentQuery);
    if (self.currentQuery) {
        [self.currentQuery cancel];
    }
        self.currentQuery = [User query];
        [self.currentQuery findObjectsInBackgroundWithBlock:^(NSArray *PF_NULLABLE_S objects, NSError *PF_NULLABLE_S error){
            if(error){
                NSLog(@"error: %@", [error localizedDescription]);
                NSAssert(!error, @"eror");
            }
            if (completion) {
                completion(0,objects);
            }
        }];
}

@end
