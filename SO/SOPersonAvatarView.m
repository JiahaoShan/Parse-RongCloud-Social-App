//
//  SOPersonAvatarView.m
//  SO
//
//  Created by Guanqing Yan on 7/21/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPersonAvatarView.h"
#import <ParseUI/ParseUI.h>

@interface SOPersonAvatarView()
@property (strong, nonatomic) IBOutlet PFImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation SOPersonAvatarView
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    self.imageView = [[PFImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.imageView.layer.cornerRadius = 25;
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 50, 20)];
    [self addSubview:self.imageView];
    [self addSubview:self.nameLabel];
    return self;
}
//-(void)layoutSubviews{
//    [super layoutSubviews];
//    self.imageView.layer.cornerRadius = self.imageView.frame.size.height/2;
//}
static UIImage* image = nil;
-(void)setAvatar:(PFFile*)file{
    if (!image) {
        image = [UIImage imageNamed:@"placeholderImage"];
    }
    [self.imageView setImage:image];
    [self.imageView loadInBackground];
    //[self setBackgroundColor:[UIColor yellowColor]];
}
-(void)setName:(NSString*)name{
    [self.nameLabel setText:name];
}
-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return CGRectContainsPoint(self.bounds, point)?self:nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
