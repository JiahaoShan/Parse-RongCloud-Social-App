//
//  SOPlaygroundFeedImageView.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedImageView.h"

@interface SOPlaygroundFeedImageView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) UIButton* singelImageButton;
@property (nonatomic) BOOL visible;
@property (nonatomic) NSArray* images;
@end

@implementation SOPlaygroundFeedImageView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setVisible:NO];
}

-(void)setImages:(NSArray*)urls{
    if (urls.count == 0) {
        [self setVisible:NO];
        return;
    }
    [self setVisible:true];
    CGRect frame = self.frame;
    frame.size.height = [self heightFromImageCount:urls.count];
    self.frame = frame;
    
    if(urls.count==1){
        self.collectionView.delegate = nil;
        self.collectionView.dataSource = nil;
        self.collectionView = nil;
        if(!self.singelImageButton){
            self.singelImageButton = [[UIButton alloc] initWithFrame:self.bounds];
        }
    }else{
        self.singelImageButton = nil;
        self.collectionView = [[UICollectionView alloc] init];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
    }
    
    self.images = urls;
}

//different from setHidden
//a hidden view will still occupy the frame,
//but a not visible view will have a height of 0
//if self is set to visible, then caller is still responsible for
//setting the height of the view
-(void)setVisible:(BOOL)visible{
    if (self.visible == visible) {
        return;
    }
    if(visible){
        self.hidden = false;
    }else{
        self.collectionView = nil;
        self.singelImageButton = nil;
        CGRect frame = self.frame;
        frame.size.height = 0;
        self.frame = frame;
        self.hidden = true;
    }
    _visible = visible;
}

-(CGFloat)heightFromImageCount:(NSUInteger)count{
    if (count==1) {
        return kPlaygroundSingleImageHeight;
    }else if(count>0){
        CGFloat width = self.bounds.size.width;
        CGFloat perRow = floor(width/kPlaygroundMultipleImageSize);
        int numRow = (int)ceil(count/perRow);
        return numRow * kPlaygroundMultipleImageSize;
    }
    return 0;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}

@end
