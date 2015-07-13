//
//  SOPlaygroundFeedImageView.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedImageView.h"
#import "UIImageView+AFNetworking.h"
#import "SOPlaygroundFeedImageViewCell.h"

@interface SOPlaygroundFeedImageView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) BOOL visible;
@property (nonatomic) NSArray* images;
@end

@implementation SOPlaygroundFeedImageView

-(void)awakeFromNib{
    [super awakeFromNib];
   // [self setVisible:NO];
}

-(void)setImages:(NSArray*)urls{
    if (urls.count == 0) {
        [self setVisible:NO];
        return;
    }
    [self setVisible:true];
    //CGRect frame = self.frame;
    //frame.size.height = [self heightFromImageCount:urls.count];
    //self.frame = frame;
    self.frame = self.superview.bounds;
    
    if (!self.collectionView) {
        UICollectionViewFlowLayout* fl = [[UICollectionViewFlowLayout alloc] init];
        [fl setItemSize:CGSizeMake(kPlaygroundMultipleImageSize, kPlaygroundMultipleImageSize)];
        [fl setScrollDirection:UICollectionViewScrollDirectionVertical];
        [fl setMinimumInteritemSpacing:1];
        [fl setEstimatedItemSize:CGSizeMake(kPlaygroundMultipleImageSize, kPlaygroundMultipleImageSize)];
        [fl setMinimumLineSpacing:0];
        fl.sectionInset = UIEdgeInsetsMake(0, 24, 0, 24);
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:fl];
        [self.collectionView registerClass:[SOPlaygroundFeedImageViewCell class] forCellWithReuseIdentifier:@"cell"];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];
    }
    
    _images = urls;
    //dispatch_async(dispatch_get_main_queue(), ^ {
        [self.collectionView reloadData];
    //});
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

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SOPlaygroundFeedImageViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor yellowColor]];
    UIImageView* iv = [cell imageView];
    [iv setImageWithURL:[NSURL URLWithString:self.images[indexPath.row]] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    return cell;
}

@end
