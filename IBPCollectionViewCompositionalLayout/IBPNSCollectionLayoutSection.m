#import "IBPNSCollectionLayoutSection.h"
#import "IBPNSCollectionLayoutSection_Private.h"
#import "IBPNSCollectionLayoutGroup_Private.h"

@implementation IBPNSCollectionLayoutSection

+ (instancetype)sectionWithGroup:(IBPNSCollectionLayoutGroup *)group {
    return [[self alloc] initWithGroup:group];
}

- (instancetype)initWithGroup:(IBPNSCollectionLayoutGroup *)group {
    self = [super init];
    if (self) {
        self.group = group;
        self.orthogonalScrollingBehavior = UICollectionLayoutSectionOrthogonalScrollingBehaviorNone;
    }
    return self;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    IBPNSCollectionLayoutSection *section = [IBPNSCollectionLayoutSection sectionWithGroup:self.group];
    section.contentInsets = self.contentInsets;
    section.interGroupSpacing = self.interGroupSpacing;
    section.orthogonalScrollingBehavior = self.orthogonalScrollingBehavior;
    section.boundarySupplementaryItems = self.boundarySupplementaryItems;
    section.supplementariesFollowContentInsets = self.supplementariesFollowContentInsets;
    section.visibleItemsInvalidationHandler = self.visibleItemsInvalidationHandler;
    section.decorationItems = self.decorationItems;
    return section;
}

- (BOOL)scrollsOrthogonally {
    return self.orthogonalScrollingBehavior != UICollectionLayoutSectionOrthogonalScrollingBehaviorNone;
}

@end
