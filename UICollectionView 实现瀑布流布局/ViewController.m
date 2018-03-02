//
//  ViewController.m
//  UICollectionView 实现瀑布流布局
//
//  Created by relax on 2018/2/28.
//  Copyright © 2018年 relax. All rights reserved.
//

/**
 UICollectionView 实现瀑布流的核心思路：（一开始的初想法）
    1. 无非就是每一个 Cell 的高度不一样。
    2. 高度根据具体的内存来计算。
    3. 在 UICollectionView 的返回 itemSize 的代码方法里，返回每一个 cell 的高度，实现瀑布流.
    4. 这个返回 CGSize 的方法，并不是 collectionviewDelegate 的，而是 UICollectionViewFlowLayoutDelegate 的协议方法。
 
    ---- 上面想当然的方法是错误的 ---- 并不能完成流失布局。--每个 cell 的大小是可以随机，但是占据的位置仍然是固定的。
 
 正确的做法：
    1. 自定义一个布局的类，WaterFlowLayout : UICollctionViewFlowLayout.
    2. 在此类的方法中，计算每一个 cell 的 UICollectionViewLayoutAttributes 属性。(也就是计算每一个 cell 的 frame)，并添加一个存储了每个 cell 的 UICollectionViewLayoutAttributes 的数组中。
    3. 最后在实现 flowLayout 的方法，返回这个数组。- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
 
 */

#import "ViewController.h"
#import "WaterFlowLayout.h" // 瀑布式布局

@interface ViewController () // <UICollectionViewDelegateFlowLayout>

@end

/// cell 的重用标识符
static NSString *const reuserIdentifierID = @"cellid";

@implementation ViewController {
     WaterFlowLayout *_flowLayout;
//    UICollectionViewFlowLayout *_flowLayout;
    CGFloat _cellWidth;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    _flowLayout = [[WaterFlowLayout alloc] init];
    if (self = [super initWithCollectionViewLayout:_flowLayout]) {
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.minimumLineSpacing = 10;
        _flowLayout.minimumInteritemSpacing = 10;
       _flowLayout.count = 100;
        
//        _cellWidth = ([UIScreen mainScreen].bounds.size.width - 30) * 0.5;
//        _flowLayout.itemSize = CGSizeMake(_cellWidth, 200);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuserIdentifierID];
    self.collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 10, 0, 10);
}

#pragma mark DataSource & Delegate 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuserIdentifierID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1.0];
    return cell;
}

/** 之前曾尝试使用找到最后一个 cell 的 frame 的 Y 值，来计算 contentSize,能正确计算，也能正确的设置到 collectionView 的 contentSize ，但是在 UI 滑动的体现上是错的。最后还是老实的使用计算较长的那一列的 itemSize 平均值的方式。 */
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    self.collectionView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, _flowLayout.maxY);
//}

/** 使用这种方式布局，每个 cell 的大小的确是变了，但是占据的空间大小都是一样的，看起来比较死板。 */
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat randomHeight = arc4random_uniform(300);
//    return CGSizeMake(_cellWidth, randomHeight);
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
