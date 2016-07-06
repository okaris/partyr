//
//  OKFlickrSmallPhotoCollectionViewCell.h
//  partyr
//
//  Created by Omer Karisman on 25/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OKFlickrSmallPhotoCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) UIImageView *imageView;

- (void)hideImage;
- (void)showImage;

@end
