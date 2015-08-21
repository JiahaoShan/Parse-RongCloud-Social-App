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
@property NSMutableArray* buttons;
@property NSString* title;
@property NSString* message;
@property UIView* alertBody;
@property UITapGestureRecognizer* tap;

@property CGFloat alertWidth;
@property CGFloat alertHeight;//used when action sheet
@end

@implementation SOAlert
-(instancetype)initWithType:(SOAlertType)type title:(NSString*)title message:(NSString*)message actions:(NSArray*)actions didDismiss:(SOActionHandler)dismissAction{
    if (self=[super initWithFrame:CGRectMake(0, 0, [SOUICommons screenWidth], [SOUICommons screenHeight])]) {
        self.type = type;
        self.handlers = [NSMutableArray array];
        self.title = title;
        self.message = message;
        self.buttons = [NSMutableArray array];
        self.alertHeight=0;
        self.dismissAction = [dismissAction copy];
        self.alertBody = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.alertBody];
        [self.alertBody setBackgroundColor:[SOUICommons translucentWhite]];
        [[self.alertBody layer] setCornerRadius:5];
        [self.alertBody setClipsToBounds:true];
        
        if (self.type==SOAlertTypeActionSheet) {
            self.alertWidth = self.bounds.size.width;
        }else if (self.type==SOAlertTypeAlert){
            self.alertWidth = self.bounds.size.width*2/3;
        }
        
        if (title) {
            UITextView* titleL = [[UITextView alloc] initWithFrame:CGRectMake(self.alertWidth/4, self.alertHeight, 0, 0)];
            [titleL setShowsHorizontalScrollIndicator:false];
            [titleL setShowsVerticalScrollIndicator:false];
            [titleL setTextAlignment:NSTextAlignmentCenter];
            [titleL setText:title];
            [titleL setFont:[UIFont systemFontOfSize:16]];
            [titleL sizeToFit];
            [titleL setBackgroundColor:[UIColor clearColor]];
            [titleL setCenter:CGPointMake(self.alertWidth/2, titleL.center.y)];
            [titleL setTextColor:[SOUICommons primaryTintColor]];
            self.alertHeight+=CGRectGetHeight(titleL.frame);
            [[self alertBody] addSubview:titleL];
        }
        
        if (message) {
            UITextView* messageL = [[UITextView alloc] initWithFrame:CGRectZero];
            [messageL setShowsHorizontalScrollIndicator:false];
            [messageL setShowsVerticalScrollIndicator:false];
            [messageL setText:message];
            [messageL setTextColor:[SOUICommons primaryTintColor]];
            [messageL setBackgroundColor:[UIColor clearColor]];
            [messageL setUserInteractionEnabled:false];
            CGSize maxSize = CGSizeMake(self.alertWidth*2/3, CGFLOAT_MAX);
            CGSize requiredSize = [messageL sizeThatFits:maxSize];
            messageL.frame = CGRectMake(self.alertWidth/6, self.alertHeight, requiredSize.width, requiredSize.height);
            self.alertHeight+=requiredSize.height+6;
            [[self alertBody] addSubview:messageL];
        }
        
        if (self.type==SOAlertTypeActionSheet) {
            self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
            [self addGestureRecognizer:self.tap];
            [self createButtonsWithActions:actions vertical:true];
            [self.alertBody setFrame:CGRectMake(0, 0, self.alertWidth, self.alertHeight)];
        }else if (self.type==SOAlertTypeAlert){
            self.userInteractionEnabled = true;//block action to views behind it

            if (actions.count<=2) {
                [self createButtonsWithActions:actions vertical:false];
            }else{
                [self createButtonsWithActions:actions vertical:true];
            }
            [self.alertBody setFrame:CGRectMake(0, 0, self.alertWidth, self.alertHeight)];
        }
    }
    return self;
}

-(void)createButtonsWithActions:(NSArray*)actions vertical:(BOOL)vertical{
    if (vertical) {
        for (int i=0; i<actions.count; i++) {
            NSDictionary* dic = actions[i];
            id handler = [dic objectForKey:@"handler"];
            if (handler){
                [self.handlers addObject:[handler copy]];
            }else{
                [self.handlers addObject:[NSNull null]];
            }
            UIButton* button = [self buttonWithFrame:CGRectMake(0, self.alertHeight, self.alertWidth, 44) title:dic[@"title"] tag:i];
            self.alertHeight+=44;
            [self.alertBody addSubview:button];
        }
    }else{
        CGFloat curX=0;
        CGFloat perWidth = self.alertWidth/actions.count;
        for (int i=0; i<actions.count; i++) {
            NSDictionary* dic = actions[i];
            id handler = [dic objectForKey:@"handler"];
            if (handler){
                [self.handlers addObject:[handler copy]];
            }else{
                [self.handlers addObject:[NSNull null]];
            }
            UIButton* button = [self buttonWithFrame:CGRectMake(curX, self.alertHeight, perWidth, 44) title:dic[@"title"] tag:i];
            [self.alertBody addSubview:button];
            curX+=perWidth;
        }
        self.alertHeight+=44;
    }
}

-(UIButton*)buttonWithFrame:(CGRect)frame title:(NSString*)title tag:(NSInteger)tag{
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[SOUICommons primaryTintColor] forState:UIControlStateNormal];
    [button setTag:tag];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [[button layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[button layer] setBorderWidth:0.5];
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
+(id)SOActionTypeCancel{
    static dispatch_once_t onceToken;
    static NSObject* type = nil;
    dispatch_once(&onceToken,^{
        type = [[NSObject alloc] init];
    });
    return type;
}

@end
