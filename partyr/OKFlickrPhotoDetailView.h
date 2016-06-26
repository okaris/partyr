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
@property (strong, nonatomic) OKFlickrPhotoModel *photo;
@property (copy, nonatomic) void (^onDismiss)(void);

@end
