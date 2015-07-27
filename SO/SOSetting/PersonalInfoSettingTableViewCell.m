//
//  PersonalInfoSettingTableViewCell.m
//  SO
//
//  Created by Jiahao Shan on 7/26/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "PersonalInfoSettingTableViewCell.h"

@interface PersonalInfoSettingTableViewCell()

@end

@implementation PersonalInfoSettingTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.attributeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 15.0)];;
        self.attributeLabel.textColor = [UIColor blackColor];
        self.attributeLabel.font = [UIFont systemFontOfSize:12.0f];
        self.attributeLabel.textAlignment = NSTextAlignmentLeft;
        self.attributeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.attributeLabel];
        
        self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 20.0, self.frame.size.width, 25.0)];
        self.valueLabel.textColor = [UIColor blackColor];
        self.valueLabel.font = [UIFont systemFontOfSize:18.0f];
        self.valueLabel.textAlignment = NSTextAlignmentRight;
        self.valueLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        
        [self addSubview:self.valueLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
