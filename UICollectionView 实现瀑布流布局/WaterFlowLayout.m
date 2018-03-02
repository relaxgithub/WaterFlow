//
//  WaterFlowLayout.m
//  UICollectionView 实现瀑布流布局
//
//  Created by relax on 2018/2/28.
//  Copyright © 2018年 relax. All rights reserved.
//

#import "WaterFlowLayout.h"

#define kMargin 10

@implementation WaterFlowLayout {
    /** 自定义布局的配置数据，存储每一个 cell 的位置 frame */
    NSMutableArray<UICollectionViewLayoutAttributes *> *_attributeAttay;
}

- (void)prepareLayout {
    
    /**
     使用 UICollectionView 布局的根本核心就是在于自定义一个你希望布局成什么样子的 UICollectionViewFlowLayout 的布局类型。
     其核心之二是在自定义的 Layout 类型里重写 prepareLayout 方法。
     其核心之三的，在这个方法里，你需要需要怎么布局 cell，就自己手动的去计算每一个 cell 的 frame。
     对应到代码的级别就是，你需要计算每一个 cell 的 IndexPath 对应的下 UICollectionFlowLayoutAttributes.
     */
    
    [super prepareLayout];
    
    _attributeAttay = [NSMutableArray arrayWithCapacity:self.count];
    
    // 这个方法，就是 collectionView 在 "布局 cell 之前"会执行的方法。
    // 请注意，这儿就一个在【布局 cell】之前，说明步骤已经到达了 cell 的布局了。
    // 也侧向的说明，collectionView 的 frame 已经设定好了。
    // 在 OC 的布局步骤中，只有当父视图的 frame 计算好了，在能轮上子视图的布局。
    // 也就是说，我们在这个方法里可以拿到 collectionView 已经布局好的 frame。
    
    // NSLog(@"%@",NSStringFromCGRect(self.collectionView.frame)); // {{0, 0}, {375, 667}}
    
    /** 设置 collectionView 的基本布局属性 */
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.bounces = NO;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    // collectionView 的普通布局，本质上是根据滚动方向，先行后列的布局。
    // 但这种布局方式，并不满足流式布局的需求。所以，我们需要自定义每一个 cell 的 frame。
    // self.itemSize = CGSizeMake(100, 100);
    
    // 计算每一列的 cell 宽度
    CGFloat cellWidth = ([UIScreen mainScreen].bounds.size.width - kMargin * 3) * 0.5;
    
    /** 由于我们是计算每一个 cell 的 frame，而不是按照原来的默认布局方式，从左到右，从上到下。所以，我们需要使用一个数组，保存每一列的高度。每次都是把 cell 往比较矮的那一列追加的方式来计算它的 frame。所以，我们需要定义一个数组，来保存每一列的高度。 */
    /** 这里的数组为什么是2？因为在 iPhone 应用中，流式布局基本都是2列，屏幕宽度就那么大。 */
    CGFloat colHeight[2] = {self.sectionInset.top,self.sectionInset.top};
    /** 记录左右 cell 的个数 */
    NSUInteger cellSideCount[2] = {0,0};
    
    // 根据 model 的个数，来遍历的计算每一个 cell 的 frame。
    for (NSInteger i = 0; i < self.count; i++) {
        // 虽然 cell 是复用的，但是 indexPath 却是固定死的，每一个 indexPath 不会强绑定一个 cell，但是一定会强绑定整好和它对应上的 cell 的 frame。
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        // 计算 cell 的 frame，并不是直接 cell.frame 这么做的，况且这里也拿不到 cell，这里只是布局。
        // 所以，我们需要使用 UICollectionViewFlowLayoutAttribute 配合 indexPath 来间接的绑定每一个位置 cell 的 frame。
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        // 随机一个 cell 的高度。100 - 399 之前
        NSUInteger randHeight = arc4random() % 300 + 100;
        
        /** cell 的 frame，计算核心是，往短的那一列追加 frame */
        // 因为 cell 是根据 colHeight 左右摆布局的，所以，我们需要知道每一个 cell 的 x 的偏移量。
        // 是0个，还是第一个？
        NSUInteger xOffset = 0;
        if (colHeight[0] < colHeight[1]) {
            xOffset = 0;
            colHeight[0] = colHeight[0] + self.sectionInset.top + randHeight + self.minimumLineSpacing;
            cellSideCount[0]++;
            
        } else {
            xOffset = 1;
            colHeight[1] = colHeight[1] + self.sectionInset.top + randHeight + self.minimumLineSpacing;
            cellSideCount[1]++;
        }
        
        // 然后根据 xoffset & randHeight 来计算 cell 的 frame
        CGFloat x,y;
        x = self.sectionInset.left + (cellWidth + self.minimumInteritemSpacing) * xOffset;
        y = colHeight[xOffset] - randHeight - self.minimumLineSpacing;
        attributes.frame = CGRectMake(x, y, cellWidth, randHeight);
        
        [_attributeAttay addObject:attributes];
    }

    
    // 我们在设置布局的时候，会设置 itemSize,
    // itemSize 这个属性除了指定每一个 cell 的大小之外，还有一个非常重要的作用。
    // 那就是 collectionView 会里用 cell 的 itemSize 和 数据源的个数来计算它自身的 contentSize.
    // 具体做法是，我们需要找到高度长的那一列，计算 cell 的平均 itemSize 来达到计算 collectionView 的 contentSize 的目的。
    
    // 左边的列比较长
    if (colHeight[0] > colHeight[1]) {
        self.itemSize = CGSizeMake(cellWidth, (colHeight[0] - self.sectionInset.top - ((cellSideCount[0] - 1) * self.minimumInteritemSpacing)) / cellSideCount[0]);
    } else { // 右边列比较长，或者一样长
         self.itemSize = CGSizeMake(cellWidth, (colHeight[1] - self.sectionInset.top - ((cellSideCount[1] - 1) * self.minimumInteritemSpacing)) / cellSideCount[1]);
    }
    
    NSLog(@"left count %zd right count %zd",cellSideCount[0],cellSideCount[1]);
    
}

/** 在布局的这个方法里面，返回每一个 cell 通过自己计算的出来的 frame。 */
/** UICollectionViewLayoutAttributes 和 indexPath 绑定来绑定每一个 cell 的 frame。 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return _attributeAttay;
}

@end
