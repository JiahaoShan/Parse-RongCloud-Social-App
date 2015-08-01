//
//  SOPlaygroundFeedCommentCell.h
//  SO
//
//  Created by Guanqing Yan on 8/1/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaygroundComment.h"

//一行窄的 没有人物头像 没有时间 详细的评论信息可以到DeatilView里面去看
//minimum height: 20px can be higher
@interface SOPlaygroundFeedCommentCell : UITableViewCell
+(CGFloat)heightForCommentCellForComment:(PlaygroundComment*)comment;
-(void)loadComment:(PlaygroundComment*)comment;
@end
