//
//  VariableSizeCell.m
//  SO
//
//  Created by Guanqing Yan on 8/1/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "VariableSizeCell.h"

@interface VariableSizeCell()
@property (nonatomic) UITextView* content1;
@property (nonatomic) UITextView* content2;
@end

@implementation VariableSizeCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.content1 = [[UITextView alloc] init];
    [self.content1 setBackgroundColor:[UIColor redColor]];
    self.content2 = [[UITextView alloc] init];
    [self.content2 setBackgroundColor:[UIColor greenColor]];
    [self.content1 setUserInteractionEnabled:false];
    [self.content2 setUserInteractionEnabled:false];
    [[self contentView] addSubview:self.content1];
    [[self contentView] addSubview:self.content2];
    return self;
}

-(void)layoutSubviews{
    CGFloat screenWidth = 375;
    CGSize size1 = [self.content1 sizeThatFits:CGSizeMake(screenWidth,CGFLOAT_MAX)];
    [self.content1 setFrame:CGRectMake(0, 0, size1.width, size1.height)];
    CGSize size2 = [self.content2 sizeThatFits:CGSizeMake(screenWidth,CGFLOAT_MAX)];
    [self.content2 setFrame:CGRectMake(0, size1.height, self.bounds.size.width, size2.height)];
    CGRect frame = self.frame;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, screenWidth, size1.height+size2.height);
}

-(void)setContent1:(NSString*)content1 andContent2:(NSString*)content2{
    [self.content1 setText:content1];
    [self.content2 setText:content2];
}

@end
