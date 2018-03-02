//
//  WaterFlowLayout.h
//  UICollectionView 实现瀑布流布局
//
//  Created by relax on 2018/2/28.
//  Copyright © 2018年 relax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterFlowLayout : UICollectionViewFlowLayout

/// 需要布局的元素个数。本质上就是 cell 的个数
@property (nonatomic,assign) NSInteger count;

@property (nonatomic,assign) CGFloat maxY;

@end
