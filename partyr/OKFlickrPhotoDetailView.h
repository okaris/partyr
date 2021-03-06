//
//  OKFlickrPhotoDetailView.h
//  partyr
//
//  Created by Omer Karisman on 26/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OKFlickrPhotoModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface OKFlickrPhotoDetailView : UIView <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *placeholderImage;
@property (strong, nonatomic) OKFlickrPhotoModel *photo;
@property (assign, nonatomic) CGAffineTransform dismissTransform;
@property (assign, nonatomic) BOOL didLoadBiggerImage;
@property (assign, nonatomic) CGPoint firstLocation;
@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *captionLabel;

@property (copy, nonatomic) void (^onDismiss)(void);

- (void)hideEverythingExceptImage;

@end
