//
//  OKFlickrPhotoDetailView.m
//  partyr
//
//  Created by Omer Karisman on 26/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKFlickrPhotoDetailView.h"
#import "PureLayout.h"

@implementation OKFlickrPhotoDetailView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.backgroundColor = [UIColor blackColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = 1.0;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [_scrollView addGestureRecognizer:doubleTapGestureRecognizer];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];

    [_scrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    _imageView = [[UIImageView alloc] initWithFrame:rect];
    _imageView.contentMode = UIViewContentModeCenter;
    
    [_scrollView addSubview:_imageView];
    _scrollView.contentSize = rect.size;
    
    [_imageView sd_setImageWithURL:[_photo photoURLWithSize:OKPhotoSizeLarge]
                            placeholderImage:[UIImage imageNamed:@"42-photos"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                _scrollView.contentSize = image.size;
                                _imageView.frame = CGRectMake(0, (_scrollView.frame.size.height - image.size.height / image.size.width * _scrollView.frame.size.width) / 2, image.size.width, image.size.height);
                                _scrollView.minimumZoomScale = _scrollView.frame.size.width / image.size.width;
                                _scrollView.zoomScale = _scrollView.minimumZoomScale;
                            }];

    [self addSubview:_scrollView];
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
    captionLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightThin];
    captionLabel.numberOfLines = 0;
    captionLabel.text = _photo.title;
    
    [self addSubview:captionLabel];
    
    [captionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [captionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [captionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [captionLabel autoSetDimension:ALDimensionHeight toSize:20.f relation:NSLayoutRelationGreaterThanOrEqual];

    [_scrollView autoPinEdgesToSuperviewEdges];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (IBAction)didDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIScrollView *scrollView = (UIScrollView *)tapGestureRecognizer.view;
    [UIView animateWithDuration:.4f animations:^{
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.zoomScale = scrollView.minimumZoomScale;
        }else{
            scrollView.zoomScale = (scrollView.minimumZoomScale + scrollView.maximumZoomScale) / 2;
        }
    }];
}

- (IBAction)didSingleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [UIView animateWithDuration:.4f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        _onDismiss();
    }];
}

// make the change during scrollViewDidScroll instead of didEndScrolling...
-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGSize imageViewSize = self.imageView.frame.size;
    CGSize imageSize = self.imageView.image.size;
    
    CGSize realImageSize;
    if(imageSize.width / imageSize.height > imageViewSize.width / imageViewSize.height) {
        realImageSize = CGSizeMake(imageViewSize.width, imageViewSize.width / imageSize.width * imageSize.height);
    }
    else {
        realImageSize = CGSizeMake(imageViewSize.height / imageSize.height * imageSize.width, imageViewSize.height);
    }
    
    CGRect newFrame = CGRectMake(0, 0, 0, 0);
    newFrame.size = realImageSize;
    self.imageView.frame = newFrame;
    
    CGSize screenSize = scrollView.frame.size;
    float offsetX = (screenSize.width > realImageSize.width ? (screenSize.width - realImageSize.width) / 2 : 0);
    float offsetY = (screenSize.height > realImageSize.height ? (screenSize.height - realImageSize.height) / 2 : 0);
    
    // don't animate the change.
    scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, offsetY, offsetX);
}


@end
