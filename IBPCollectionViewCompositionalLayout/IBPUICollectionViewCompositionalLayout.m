#import "IBPUICollectionViewCompositionalLayout.h"
#import "IBPUICollectionViewCompositionalLayoutConfiguration.h"
#import "IBPNSCollectionLayoutAnchor.h"
#import "IBPNSCollectionLayoutBoundarySupplementaryItem.h"
#import "IBPNSCollectionLayoutContainer.h"
#import "IBPNSCollectionLayoutSection_Private.h"
#import "IBPNSCollectionLayoutGroup_Private.h"
#import "IBPNSCollectionLayoutItem_Private.h"
#import "IBPNSCollectionLayoutSize.h"
#import "IBPNSCollectionLayoutSize_Private.h"
#import "IBPNSCollectionLayoutSpacing.h"
#import "IBPNSCollectionLayoutSupplementaryItem_Private.h"
#import "IBPNSCollectionLayoutDimension.h"
#import "IBPNSCollectionLayoutEnvironment.h"
#import "IBPCollectionViewLayoutBuilder.h"
#import "IBPCollectionViewOrthogonalScrollerEmbeddedScrollView.h"
#import "IBPCollectionViewOrthogonalScrollerSectionController.h"

@interface IBPUICollectionViewCompositionalLayout() {
    CGRect contentBounds;
    NSMutableDictionary<NSNumber *, UICollectionViewOrthogonalScrollerSectionController *> *orthogonalScrollerSectionControllers;
}

@property (nonatomic, copy) IBPNSCollectionLayoutSection *section;
@property (nonatomic) IBPUICollectionViewCompositionalLayoutSectionProvider sectionProvider;

@property (nonatomic) NSMutableArray<UICollectionViewLayoutAttributes *> *cachedAttributes;

@end

@implementation IBPUICollectionViewCompositionalLayout

- (instancetype)initWithSection:(IBPNSCollectionLayoutSection *)section {
    IBPUICollectionViewCompositionalLayoutConfiguration *configuration = [[IBPUICollectionViewCompositionalLayoutConfiguration alloc] init];
    return [self initWithSection:section configuration:configuration];
}

- (instancetype)initWithSection:(IBPNSCollectionLayoutSection *)section configuration:(IBPUICollectionViewCompositionalLayoutConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.section = section;
        self.configuration = configuration;
    }
    return self;
}

- (instancetype)initWithSectionProvider:(IBPUICollectionViewCompositionalLayoutSectionProvider)sectionProvider {
    IBPUICollectionViewCompositionalLayoutConfiguration *configuration = [[IBPUICollectionViewCompositionalLayoutConfiguration alloc] init];
    return [self initWithSectionProvider:sectionProvider configuration:configuration];
}

- (instancetype)initWithSectionProvider:(IBPUICollectionViewCompositionalLayoutSectionProvider)sectionProvider configuration:(IBPUICollectionViewCompositionalLayoutConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.sectionProvider = sectionProvider;
        self.configuration = configuration;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];

    if (!self.collectionView) {
        return;
    }
    if (CGRectIsEmpty(self.collectionView.bounds)) {
        return;
    }

    if (!self.cachedAttributes) {
        self.cachedAttributes = [[NSMutableArray alloc] init];
    }
    [self.cachedAttributes removeAllObjects];

    if (!orthogonalScrollerSectionControllers) {
        orthogonalScrollerSectionControllers = [[NSMutableDictionary alloc] init];
    }
    [[orthogonalScrollerSectionControllers allValues] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [orthogonalScrollerSectionControllers removeAllObjects];

    UIEdgeInsets collectionContentInset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        collectionContentInset = self.collectionView.safeAreaInsets;
    }

    CGRect collectionViewBounds = self.collectionView.bounds;
    contentBounds = CGRectMake(0, 0, collectionViewBounds.size.width, collectionViewBounds.size.height);

    IBPNSCollectionLayoutContainer *collectionContainer = [[IBPNSCollectionLayoutContainer alloc] initWithContentSize:collectionViewBounds.size
                                                                                                  contentInsets:NSDirectionalEdgeInsetsMake(0, collectionContentInset.left, 0, collectionContentInset.right)];
    IBPNSCollectionLayoutEnvironment *environment = [[IBPNSCollectionLayoutEnvironment alloc] init];
    environment.container = collectionContainer;
    environment.traitCollection = self.collectionView.traitCollection;

    NSInteger numberOfSections = [self.collectionView numberOfSections];

    CGRect layoutFrame = CGRectZero;
    layoutFrame.origin.x += collectionContainer.effectiveContentInsets.leading;
    layoutFrame.origin.y += collectionContainer.effectiveContentInsets.top;

    for (NSInteger sectionIndex = 0; sectionIndex < numberOfSections; sectionIndex++) {
        CGRect sectionFrame = CGRectZero;
        sectionFrame.origin.x = layoutFrame.origin.x;
        sectionFrame.origin.y = CGRectGetMaxY(layoutFrame);

        IBPNSCollectionLayoutSection *section = self.sectionProvider ? self.sectionProvider(sectionIndex, environment) : self.section;

        NSArray<IBPNSCollectionLayoutBoundarySupplementaryItem *> *boundarySupplementaryItems = section.boundarySupplementaryItems;
        for (IBPNSCollectionLayoutBoundarySupplementaryItem *boundarySupplementaryItem in boundarySupplementaryItems) {
            UICollectionViewLayoutAttributes *boundarySupplementaryViewAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:boundarySupplementaryItem.elementKind
                                                                                                                                                   withIndexPath:[NSIndexPath indexPathForItem:0 inSection:sectionIndex]];
            CGRect boundarySupplementaryViewFrame = layoutFrame;

            IBPNSCollectionLayoutSize *boundarySupplementaryItemLayoutSize = boundarySupplementaryItem.layoutSize;

            CGSize boundarySupplementaryItemEffectiveSize = [boundarySupplementaryItemLayoutSize effectiveSizeForContainer:collectionContainer ignoringInsets:NO];
            boundarySupplementaryViewFrame.size = boundarySupplementaryItemEffectiveSize;

            NSRectAlignment alignment = boundarySupplementaryItem.alignment;
            if (alignment == NSRectAlignmentTop) {
                boundarySupplementaryViewFrame.origin.y = CGRectGetMinY(layoutFrame);
                boundarySupplementaryViewFrame.origin.x += sectionFrame.origin.x;
                boundarySupplementaryViewFrame.origin.y += sectionFrame.origin.y;

                sectionFrame.origin.y += boundarySupplementaryItemEffectiveSize.height;

                boundarySupplementaryViewAttributes.frame = boundarySupplementaryViewFrame;
                [self.cachedAttributes addObject:boundarySupplementaryViewAttributes];

                contentBounds = CGRectUnion(contentBounds, boundarySupplementaryViewFrame);
                layoutFrame = CGRectUnion(layoutFrame, boundarySupplementaryViewFrame);
            }
            if (alignment == NSRectAlignmentTopLeading) {
                // Not implemented yet
            }
            if (alignment == NSRectAlignmentLeading) {
                // Not implemented yet
            }
            if (alignment == NSRectAlignmentBottomLeading) {
                // Not implemented yet
            }
            if (alignment == NSRectAlignmentBottom) {
                // Not implemented yet
            }
            if (alignment == NSRectAlignmentBottomTrailing) {
                // Not implemented yet
            }
            if (alignment == NSRectAlignmentTrailing) {
                // Not implemented yet
            }
            if (alignment == NSRectAlignmentTopTrailing) {
                // Not implemented yet
            }
        }

        IBPCollectionViewLayoutBuilder *builder = [[IBPCollectionViewLayoutBuilder alloc] initWithLayoutSection:section configuration:self.configuration];
        [builder buildLayoutForContainer:collectionContainer traitCollection:environment.traitCollection];

        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:sectionIndex];
        for (NSInteger itemIndex = 0; itemIndex < numberOfItems; itemIndex++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            UICollectionViewLayoutAttributes *cellAttributes = [builder layoutAttributesForItemAtIndexPath:indexPath];

            CGRect cellFrame = cellAttributes.frame;
            cellFrame.origin.x += sectionFrame.origin.x;
            cellFrame.origin.y += sectionFrame.origin.y;

            cellAttributes.frame = cellFrame;
            if (!section.scrollsOrthogonally) {
                [self.cachedAttributes addObject:cellAttributes];
            }

            IBPNSCollectionLayoutItem *layoutItem = [builder layoutItemAtIndexPath:indexPath];
            [layoutItem enumerateSupplementaryItemsWithHandler:^(IBPNSCollectionLayoutSupplementaryItem * _Nonnull supplementaryItem, BOOL * _Nonnull stop) {
                UICollectionViewLayoutAttributes *supplementaryViewAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:supplementaryItem.elementKind withIndexPath:indexPath];
                supplementaryViewAttributes.frame = [supplementaryItem frameInContainerFrame:cellFrame];
                [self.cachedAttributes addObject:supplementaryViewAttributes];
            }];

            if (section.scrollsOrthogonally) {
                CGRect frame = CGRectZero;
                switch (self.configuration.scrollDirection) {
                    case UICollectionViewScrollDirectionVertical:
                        frame.origin.x = 0;
                        frame.origin.y = cellFrame.origin.y;
                        frame.size.width = collectionContainer.contentSize.width;
                        frame.size.height = cellFrame.size.height;
                        break;
                    case UICollectionViewScrollDirectionHorizontal:
                        frame.origin.x = cellFrame.origin.x;
                        frame.origin.y = 0;
                        frame.size.width = cellFrame.size.width;
                        frame.size.height = collectionContainer.contentSize.height;
                        break;
                }

                contentBounds = CGRectUnion(contentBounds, frame);
                layoutFrame = CGRectUnion(layoutFrame, frame);
            } else {
                contentBounds = CGRectUnion(contentBounds, cellFrame);
                layoutFrame = CGRectUnion(layoutFrame, cellFrame);
            }
        }

        if (section.scrollsOrthogonally) {
            UICollectionViewOrthogonalScrollerSectionController *controller = orthogonalScrollerSectionControllers[@(sectionIndex)];
            if (!controller) {
                CGRect scrollViewFrame = builder.containerFrame;
                scrollViewFrame.origin = sectionFrame.origin;
                scrollViewFrame.size.width = collectionContainer.contentSize.width;

                IBPUICollectionViewCompositionalLayoutConfiguration *configuration = [[IBPUICollectionViewCompositionalLayoutConfiguration alloc] init];
                configuration.scrollDirection = self.configuration.scrollDirection == UICollectionViewScrollDirectionVertical ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical;

                IBPNSCollectionLayoutSection *orthogonalSection = section.copy;
                orthogonalSection.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorNone;
                IBPNSCollectionLayoutSize *orthogonalGroupSize = section.group.layoutSize;
                orthogonalSection.group.layoutSize = [IBPNSCollectionLayoutSize sizeWithWidthDimension:self.configuration.scrollDirection == UICollectionViewScrollDirectionVertical ? orthogonalGroupSize.widthDimension : [IBPNSCollectionLayoutDimension fractionalWidthDimension:MAX(1, orthogonalGroupSize.widthDimension.dimension)]
                                                                                    heightDimension:self.configuration.scrollDirection == UICollectionViewScrollDirectionVertical ? [IBPNSCollectionLayoutDimension fractionalHeightDimension:MAX(1, orthogonalGroupSize.heightDimension.dimension)] : orthogonalGroupSize.heightDimension];
                IBPUICollectionViewCompositionalLayout *orthogonalScrollViewCollectionViewLayout = [[IBPUICollectionViewCompositionalLayout alloc] initWithSection:orthogonalSection configuration:configuration];

                IBPCollectionViewOrthogonalScrollerEmbeddedScrollView *scrollView = [[IBPCollectionViewOrthogonalScrollerEmbeddedScrollView alloc] initWithFrame:scrollViewFrame collectionViewLayout:orthogonalScrollViewCollectionViewLayout];
                scrollView.backgroundColor = [UIColor clearColor];
                scrollView.directionalLockEnabled = YES;
                scrollView.showsHorizontalScrollIndicator = NO;
                scrollView.showsVerticalScrollIndicator = NO;
                // FIXME
                if (section.orthogonalScrollingBehavior == UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuous ||
                    section.orthogonalScrollingBehavior == UICollectionLayoutSectionOrthogonalScrollingBehaviorContinuousGroupLeadingBoundary) {
                    scrollView.pagingEnabled = NO;
                }
                if (section.orthogonalScrollingBehavior == UICollectionLayoutSectionOrthogonalScrollingBehaviorPaging ||
                    section.orthogonalScrollingBehavior == UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPaging ||
                    section.orthogonalScrollingBehavior == UICollectionLayoutSectionOrthogonalScrollingBehaviorGroupPagingCentered) {
                    scrollView.pagingEnabled = YES;
                }
                controller = [[UICollectionViewOrthogonalScrollerSectionController alloc] initWithSectionIndex:sectionIndex collectionView:self.collectionView scrollView:scrollView];

                [self.collectionView addSubview:scrollView];
            }
            orthogonalScrollerSectionControllers[@(sectionIndex)] = controller;
        }

        for (IBPNSCollectionLayoutBoundarySupplementaryItem *boundarySupplementaryItem in boundarySupplementaryItems) {
            UICollectionViewLayoutAttributes *boundarySupplementaryViewAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:boundarySupplementaryItem.elementKind
                                                                                                                                                   withIndexPath:[NSIndexPath indexPathForItem:0 inSection:sectionIndex]];
            CGRect boundarySupplementaryViewFrame = layoutFrame;

            IBPNSCollectionLayoutSize *boundarySupplementaryItemLayoutSize = boundarySupplementaryItem.layoutSize;

            CGSize boundarySupplementaryItemEffectiveSize = [boundarySupplementaryItemLayoutSize effectiveSizeForContainer:collectionContainer ignoringInsets:NO];
            boundarySupplementaryViewFrame.size = boundarySupplementaryItemEffectiveSize;

            NSRectAlignment alignment = boundarySupplementaryItem.alignment;
            if (alignment == NSRectAlignmentBottom) {
                boundarySupplementaryViewFrame.origin.y = CGRectGetMaxY(layoutFrame);
                boundarySupplementaryViewFrame.origin.x += sectionFrame.origin.x;

                sectionFrame.origin.y += boundarySupplementaryItemEffectiveSize.height;

                boundarySupplementaryViewAttributes.frame = boundarySupplementaryViewFrame;
                [self.cachedAttributes addObject:boundarySupplementaryViewAttributes];

                contentBounds = CGRectUnion(contentBounds, boundarySupplementaryViewFrame);
                layoutFrame = CGRectUnion(layoutFrame, boundarySupplementaryViewFrame);
            }
        }
    }
}

- (CGSize)collectionViewContentSize {
    return contentBounds.size;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.cachedAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (!self.collectionView) {
        return NO;
    }

    return !CGSizeEqualToSize(newBounds.size, self.collectionView.bounds.size);
}

@end
