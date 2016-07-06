//
//  ViewController.h
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKServices.h"

@interface ViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (assign, nonatomic) BOOL networkOperationInProgress;
@property (assign, nonatomic) BOOL collectionViewIsZoomed;
@property (assign, nonatomic) CGFloat collectionViewZoom;
@property (strong, nonatomic) UICollectionView *photoCollectionView;

@end

