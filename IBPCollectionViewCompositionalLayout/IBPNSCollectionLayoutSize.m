#import "IBPNSCollectionLayoutSize_Private.h"
#import "IBPNSCollectionLayoutDimension.h"
#import "IBPNSCollectionLayoutContainer.h"

@interface IBPNSCollectionLayoutSize()

@property (nonatomic, readwrite) IBPNSCollectionLayoutDimension *widthDimension;
@property (nonatomic, readwrite) IBPNSCollectionLayoutDimension *heightDimension;

@end

@implementation IBPNSCollectionLayoutSize

+ (instancetype)sizeWithWidthDimension:(IBPNSCollectionLayoutDimension *)width
                       heightDimension:(IBPNSCollectionLayoutDimension *)height {
    return [[self alloc] initWithWidthDimension:width heightDimension:height];
}

- (instancetype)initWithWidthDimension:(IBPNSCollectionLayoutDimension *)width
                       heightDimension:(IBPNSCollectionLayoutDimension *)height {
    self = [super init];
    if (self) {
        self.widthDimension = width;
        self.heightDimension = height;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [IBPNSCollectionLayoutSize sizeWithWidthDimension:self.widthDimension heightDimension:self.heightDimension];
}

- (CGSize)effectiveSizeForContainer:(id<IBPNSCollectionLayoutContainer>)container {
    return [self effectiveSizeForContainer:container ignoringInsets:YES];
}

- (CGSize)effectiveSizeForContainer:(id<IBPNSCollectionLayoutContainer>)container
                     ignoringInsets:(BOOL)ignoringInsets {
    CGSize effectiveSize = CGSizeZero;
    CGSize contentSize = container.effectiveContentSize;
    NSDirectionalEdgeInsets contentInsets = container.effectiveContentInsets;

    IBPNSCollectionLayoutDimension *widthDimension = self.widthDimension;
    IBPNSCollectionLayoutDimension *heightDimension = self.heightDimension;

    if (widthDimension.isFractionalWidth) {
        effectiveSize.width = contentSize.width * widthDimension.dimension;
    }
    if (widthDimension.isFractionalHeight) {
        effectiveSize.width = contentSize.height * widthDimension.dimension;
    }
    if (widthDimension.isAbsolute) {
        effectiveSize.width = widthDimension.dimension;
    }
    if (widthDimension.isEstimated) {
        effectiveSize.width = widthDimension.dimension;
    }
    if (!ignoringInsets) {
        effectiveSize.width -= contentInsets.leading + contentInsets.trailing;
    }

    if (heightDimension.isFractionalWidth) {
        effectiveSize.height = contentSize.width * heightDimension.dimension;
    }
    if (heightDimension.isFractionalHeight) {
        effectiveSize.height = contentSize.height * heightDimension.dimension;
    }
    if (heightDimension.isAbsolute) {
        effectiveSize.height = heightDimension.dimension;
    }
    if (heightDimension.isEstimated) {
        effectiveSize.height = heightDimension.dimension;
    }
    if (!ignoringInsets) {
        effectiveSize.height -= contentInsets.top + contentInsets.bottom;
    }

    return effectiveSize;
}

@end
