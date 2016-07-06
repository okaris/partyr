//
//  OKFlickrSmallPhotoCollectionViewCell.m
//  partyr
//
//  Created by Omer Karisman on 25/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKFlickrSmallPhotoCollectionViewCell.h"
#import "OKServices.h"
#import "PureLayout.h"

@implementation OKFlickrSmallPhotoCollectionViewCell

- (UIImageView *) imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.tintColor = arc4random()%2 == 0?OKPFlickrBlue:OKPFlickrPink;
        
        [self.contentView addSubview:_imageView];
        
        [_imageView autoPinEdgesToSuperviewEdges];
    }
    return _imageView;
}

- (void)hideImage
{
    _imageView.alpha = 0;
}

- (void)showImage
{
    _imageView.alpha = 1;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
}

@end
