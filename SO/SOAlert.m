//
//  SOActionSheetManager.m
//  SO
//
//  Created by Guanqing Yan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOAlert.h"

@interface SOAlert() <UIActionSheetDelegate>
@property SOAlertType type;
@property NSMutableArray* handlers;
@property (strong)SOActionHandler dismissAction;
@property NSString* title;
@property NSString* message;
@property UIView* alertBody;
@property UITapGestureRecognizer* tap;
@property int buttonCount;
@property CGFloat alertWidth;
@property CGFloat alertHeight;//used when action sheet
@end

@implementation SOAlert
-(instancetype)initWithType:(SOAlertType)type title:(NSString*)title message:(NSString*)message items:(NSArray*)items didDismiss:(SOActionHandler)dismissAction{
    if (self=[super initWithFrame:CGRectMake(0, 0, [SOUICommons screenWidth], [SOUICommons screenHeight])]) {
        self.type = type;
        self.handlers = [NSMutableArray array];
        self.title = title;
        self.message = message;
        self.alertHeight=0;
        self.dismissAction = [dismissAction copy];
        self.alertBody = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.alertBody];
        [self.alertBody setBackgroundColor:[SOUICommons lightBackgroundGray]];
        [self.alertBody setClipsToBounds:true];
        
        if (self.type==SOAlertTypeActionSheet) {
            self.alertWidth = self.bounds.size.width;
        }else if (self.type==SOAlertTypeAlert){
            self.alertWidth = self.bounds.size.width*2/3;
        }
        
        if (title) {
            UITextView* titleL = [[UITextView alloc] initWithFrame:CGRectMake(self.alertWidth/4, self.alertHeight+15, 0, 0)];
            [titleL setShowsHorizontalScrollIndicator:false];
            [titleL setShowsVerticalScrollIndicator:false];
            [titleL setTextAlignment:NSTextAlignmentCenter];
            [titleL setText:title];
            [titleL setFont:[UIFont systemFontOfSize:14]];
            [titleL sizeToFit];
            [titleL setBackgroundColor:[UIColor clearColor]];
            [titleL setUserInteractionEnabled:false];
            [titleL setCenter:CGPointMake(self.alertWidth/2, titleL.center.y)];
            [titleL setTextColor:[UIColor blackColor]];
            self.alertHeight+=CGRectGetHeight(titleL.frame) + 30;
            [[self alertBody] addSubview:titleL];
            
            if (!message) {
                UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, self.alertHeight, self.alertWidth, 1)];
                [sep setBackgroundColor:[SOUICommons lightBackgroundGray]];
                [self.alertBody addSubview:sep];
                self.alertHeight++;
            }
        }
        
        if (message) {
            UITextView* messageL = [[UITextView alloc] initWithFrame:CGRectZero];
            [messageL setShowsHorizontalScrollIndicator:false];
            [messageL setShowsVerticalScrollIndicator:false];
            [messageL setText:message];
            [messageL setFont:[UIFont systemFontOfSize:13]];
            [messageL setTextColor:[UIColor blackColor]];
            [messageL setBackgroundColor:[UIColor clearColor]];
            [messageL setUserInteractionEnabled:false];
            CGSize maxSize = CGSizeMake(self.alertWidth*2/3, CGFLOAT_MAX);
            CGSize requiredSize = [messageL sizeThatFits:maxSize];
            messageL.frame = CGRectMake(self.alertWidth/6, self.alertHeight, requiredSize.width, requiredSize.height+20);
            self.alertHeight+=requiredSize.height+20;
            [[self alertBody] addSubview:messageL];
            
            UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, self.alertHeight, self.alertWidth, 1)];
            [sep setBackgroundColor:[SOUICommons lightBackgroundGray]];
            [self.alertBody addSubview:sep];
            self.alertHeight++;
        }
        
        self.buttonCount=0;//count for non-seperator objects
        for (id item in items) {
            if (item!=[SOAlert SOActionItemSeperator]) {
                self.buttonCount++;
            }
        }
        
        if (self.type==SOAlertTypeActionSheet) {
            self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
            [self addGestureRecognizer:self.tap];
            [self createButtonsWithItems:items vertical:true];
            [self.alertBody setFrame:CGRectMake(0, 0, self.alertWidth, self.alertHeight)];
        }else if (self.type==SOAlertTypeAlert){
            NSAssert(self.buttonCount==items.count, @"alert cannot have seperator");
            [[self.alertBody layer] setCornerRadius:5];
            self.userInteractionEnabled = true;//block action to views behind it
            if (self.buttonCount<=2) {
                [self createButtonsWithItems:items vertical:false];
            }else{
                [self createButtonsWithItems:items vertical:true];
            }
            [self.alertBody setFrame:CGRectMake(0, 0, self.alertWidth, self.alertHeight)];
        }
    }
    return self;
}

-(void)createButtonsWithItems:(NSArray*)items vertical:(BOOL)vertical{
    if (vertical) {
        for (int i=0; i<items.count; i++) {
            id item = items[i];
            if (item==[SOAlert SOActionItemSeperator]) {
                UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, self.alertHeight, self.alertWidth, 6)];
                [sep setBackgroundColor:[SOUICommons lightBackgroundGray]];
                [self.alertBody addSubview:sep];
                self.alertHeight+=6;
                continue;
            }
            NSDictionary* dic = item;
            id handler = [dic objectForKey:@"handler"];
            if (handler){
                [self.handlers addObject:[handler copy]];
            }else{
                [self.handlers addObject:[NSNull null]];
            }
            UIButton* button = [self buttonWithType:dic[@"type"] frame:CGRectMake(0, self.alertHeight, self.alertWidth, 44) title:dic[@"title"] tag:self.handlers.count-1];
            [self.alertBody addSubview:button];
            self.alertHeight+=44;
            if (i!=items.count-1 && items[i+1]!=[SOAlert SOActionItemSeperator]) {
                UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, self.alertHeight, self.alertWidth, 1)];
                [sep setBackgroundColor:[SOUICommons lightBackgroundGray]];
                [self.alertBody addSubview:sep];
                self.alertHeight++;
            }
        }
    }else{
        CGFloat curX=0;
        CGFloat perWidth = (self.alertWidth-self.buttonCount+1)/items.count;
        for (int i=0; i<items.count; i++) {
            NSDictionary* dic = items[i];
            id handler = [dic objectForKey:@"handler"];
            if (handler){
                [self.handlers addObject:[handler copy]];
            }else{
                [self.handlers addObject:[NSNull null]];
            }
            UIButton* button = [self buttonWithType:dic[@"type"] frame:CGRectMake(curX, self.alertHeight, perWidth, 60) title:dic[@"title"] tag:i];
            [self.alertBody addSubview:button];
            curX+=perWidth;
            
            if (i!=items.count-1) {
                UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(curX, self.alertHeight, 1, 44)];
                [sep setBackgroundColor:[UIColor grayColor]];
                [self.alertBody addSubview:sep];
                curX++;
            }
        }
        self.alertHeight+=44;
    }
}

-(UIButton*)buttonWithType:(id)type frame:(CGRect)frame title:(NSString*)title tag:(NSInteger)tag{
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setBackgroundColor:[SOUICommons translucentWhite]];
    if (type==[SOAlert SOActionTypeDestructive]) {
        [button setTitleColor:[SOUICommons destructiveButtonColor] forState:UIControlStateNormal];
        [[button titleLabel] setFont:[UIFont systemFontOfSize:17]];
    }else{
        [button setTitleColor:[SOUICommons primaryTintColor] forState:UIControlStateNormal];
        [[button titleLabel] setFont:[UIFont systemFontOfSize:16]];
    }
    [button setTag:tag];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)buttonTapped:(UIButton*)button{
    id handler = self.handlers[button.tag];
    if (handler!=[NSNull null]) {
        ((SOActionHandler)handler)();
    }
    [self dismiss];
}

-(void)show{
    if (self.type==SOAlertTypeActionSheet) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self setBackgroundColor:[UIColor clearColor]];
        [self.alertBody setFrame:CGRectMake(0, [SOUICommons screenHeight], [SOUICommons screenWidth], self.alertHeight)];
        [UIView animateWithDuration:0.15 animations:^{
            [self setBackgroundColor:[SOUICommons unavailableMask]];
            [self.alertBody setFrame:CGRectMake(0, [SOUICommons screenHeight]-self.alertHeight, [SOUICommons screenWidth], self.alertHeight)];
        }];
    }else if (self.type==SOAlertTypeAlert){
        self.alertBody.center = self.center;
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
}

-(void)dismiss{
    if (self.dismissAction) {
        self.dismissAction();
    }
    if (self.type==SOAlertTypeActionSheet) {
        [UIView animateWithDuration:0.15 animations:^{
            [self.alertBody setFrame:CGRectMake(0, [SOUICommons screenHeight], [SOUICommons screenWidth], self.alertHeight)];
            [self setBackgroundColor:[UIColor clearColor]];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else if (self.type==SOAlertTypeAlert){
        [self removeFromSuperview];
    }
}

+(id)SOActionTypeDefault{
    static dispatch_once_t onceToken;
    static NSObject* type = nil;
    dispatch_once(&onceToken,^{
        type = [[NSObject alloc] init];
    });
    return type;
}
+(id)SOActionTypeDestructive{
    static dispatch_once_t onceToken;
    static NSObject* type = nil;
    dispatch_once(&onceToken,^{
        type = [[NSObject alloc] init];
    });
    return type;
}
+(id)SOActionItemSeperator{
    static dispatch_once_t onceToken;
    static NSObject* sep = nil;
    dispatch_once(&onceToken,^{
        sep = [[NSObject alloc] init];
    });
    return sep;
}

@end
