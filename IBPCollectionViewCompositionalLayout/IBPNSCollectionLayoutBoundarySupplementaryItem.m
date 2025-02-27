#import "IBPNSCollectionLayoutBoundarySupplementaryItem.h"
#import "IBPNSCollectionLayoutSupplementaryItem_Private.h"
#import "IBPNSCollectionLayoutItem_Private.h"

@interface IBPNSCollectionLayoutBoundarySupplementaryItem()

@property (nonatomic, readwrite) NSRectAlignment alignment;
@property (nonatomic, readwrite) CGPoint offset;

@end

@implementation IBPNSCollectionLayoutBoundarySupplementaryItem

+ (instancetype)boundarySupplementaryItemWithLayoutSize:(IBPNSCollectionLayoutSize *)layoutSize
                                            elementKind:(NSString *)elementKind
                                              alignment:(NSRectAlignment)alignment {
    return [self boundarySupplementaryItemWithLayoutSize:layoutSize
                                             elementKind:elementKind
                                               alignment:alignment
                                          absoluteOffset:CGPointZero];
}

+ (instancetype)boundarySupplementaryItemWithLayoutSize:(IBPNSCollectionLayoutSize *)layoutSize
                                            elementKind:(NSString *)elementKind
                                              alignment:(NSRectAlignment)alignment
                                         absoluteOffset:(CGPoint)absoluteOffset {
    return [[self alloc] initWithLayoutSize:layoutSize
                                elementKind:elementKind
                                  alignment:alignment
                             absoluteOffset:absoluteOffset];
}

- (instancetype)initWithLayoutSize:(IBPNSCollectionLayoutSize *)layoutSize
                       elementKind:(NSString *)elementKind
                         alignment:(NSRectAlignment)alignment
                    absoluteOffset:(CGPoint)absoluteOffset {
    self = [super initWithLayoutSize:layoutSize supplementaryItems:@[]];
    if (self) {
        self.elementKind = elementKind;
        self.alignment = alignment;
        self.offset = absoluteOffset;
    }
    return self;
}

@end
