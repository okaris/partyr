//
//  OKFlickrPhotoDetailView.m
//  partyr
//
//  Created by Omer Karisman on 26/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKFlickrPhotoDetailView.h"
#import "PureLayout.h"

CGFloat const captionViewMinimumHeight = 20.f;
CGFloat const minimumBackgroundAlpha = .2f;

@implementation OKFlickrPhotoDetailView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self prepareLayout:self.bounds];
}

- (void)prepareLayout:(CGRect)rect
{
    _backgroundView = [[UIView alloc] initWithFrame:rect];
    _backgroundView.backgroundColor = [UIColor blackColor];
    
    [self addSubview:_backgroundView];
    
    [_backgroundView autoPinEdgesToSuperviewEdges];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.delegate = self;
    _scrollView.maximumZoomScale = 1.0;
    _scrollView.minimumZoomScale = 1.0;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    
    [self addGestureRecognizer:_panGestureRecognizer];
    
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    [_scrollView addGestureRecognizer:doubleTapGestureRecognizer];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self action:@selector(didSingleTap:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];

    [_scrollView addGestureRecognizer:singleTapGestureRecognizer];
    
    _imageView = [[UIImageView alloc] initWithFrame:rect];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [_scrollView addSubview:_imageView];
    _scrollView.contentSize = rect.size;
    
    _placeholderImage = _placeholderImage?:[UIImage imageNamed:@"42-photos"];
    
    [_imageView sd_setImageWithURL:[_photo photoURLWithSize:OKPhotoSizeLarge]
                  placeholderImage:_placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                            {
                                _didLoadBiggerImage = YES;
                                _imageView.contentMode = UIViewContentModeScaleAspectFit;
                                _scrollView.contentSize = image.size;
                                _imageView.frame = CGRectMake(0, (_scrollView.frame.size.height - image.size.height / image.size.width * _scrollView.frame.size.width) / 2, image.size.width, image.size.height);
                                _scrollView.minimumZoomScale = _scrollView.frame.size.width / image.size.width;
                                _scrollView.zoomScale = _scrollView.minimumZoomScale;
                            }];

    [self addSubview:_scrollView];
    
    _captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
    _captionLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightThin];
    _captionLabel.numberOfLines = 0;
    _captionLabel.text = _photo.title;
    
    [self addSubview:_captionLabel];
    
    [_captionLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [_captionLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [_captionLabel autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [_captionLabel autoSetDimension:ALDimensionHeight toSize:captionViewMinimumHeight
                          relation:NSLayoutRelationGreaterThanOrEqual];

    [_scrollView autoPinEdgesToSuperviewEdges];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)viewDidPan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_scrollView.zoomScale > _scrollView.minimumZoomScale) {
        return;
    }
    if ([panGestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        _firstLocation.x = [_scrollView center].x;
        _firstLocation.y = [_scrollView center].y;
    }
    
    CGPoint translatedPoint = [panGestureRecognizer translationInView:panGestureRecognizer.view.superview];
    
    translatedPoint = CGPointMake(_firstLocation.x + translatedPoint.x, _firstLocation.y + translatedPoint.y);

    CGFloat alpha = 1.f - [self distanceBetween:_firstLocation and:translatedPoint] / 100.f;

    alpha = alpha>minimumBackgroundAlpha?alpha:minimumBackgroundAlpha;
    
    if ([panGestureRecognizer state] == UIGestureRecognizerStateChanged)
    {
        [_scrollView setCenter:translatedPoint];
        
        _backgroundView.alpha = alpha;
        _captionLabel.alpha = alpha;
    }
    
    if ([panGestureRecognizer state] == UIGestureRecognizerStateEnded)
    {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.4f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDelegate:self];
        [_scrollView setCenter:CGPointMake(_firstLocation.x, _firstLocation.y)];
        
        if (alpha != minimumBackgroundAlpha) {
            _backgroundView.alpha = 1;
            _captionLabel.alpha = 1;
        }
    
        [UIView commitAnimations];
        
        if (alpha == minimumBackgroundAlpha) {
            _onDismiss();
        }
    }
}

- (float) distanceBetween : (CGPoint) p1 and: (CGPoint)p2
{
    return sqrt(pow(p2.x-p1.x,2)+pow(p2.y-p1.y,2));
}

- (IBAction)didDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    UIScrollView *scrollView = _scrollView;
    
    [UIView animateWithDuration:.4f animations:^{
        if (scrollView.zoomScale > scrollView.minimumZoomScale)
        {
            scrollView.zoomScale = scrollView.minimumZoomScale;
        }else{
            scrollView.zoomScale = (scrollView.minimumZoomScale + scrollView.maximumZoomScale) / 2;
        }
    }];
}

- (IBAction)didSingleTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    _onDismiss();
}

// make the change during scrollViewDidScroll instead of didEndScrolling...
-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (!_didLoadBiggerImage) {
        return;
    }
    
    CGSize imageViewSize = self.imageView.frame.size;
    CGSize imageSize = self.imageView.image.size;
    
    CGSize realImageSize;
    if(imageSize.width / imageSize.height > imageViewSize.width / imageViewSize.height)
    {
        realImageSize = CGSizeMake(imageViewSize.width, imageViewSize.width / imageSize.width * imageSize.height);
    }
    else
    {
        realImageSize = CGSizeMake(imageViewSize.height / imageSize.height * imageSize.width, imageViewSize.height);
    }
    
    CGRect newFrame = CGRectMake(0, 0, 0, 0);
    newFrame.size = realImageSize;
    self.imageView.frame = newFrame;
    
    CGSize screenSize = scrollView.frame.size;
    float offsetX = screenSize.width > realImageSize.width ? (screenSize.width - realImageSize.width) / 2 : 0;
    float offsetY = screenSize.height > realImageSize.height ? (screenSize.height - realImageSize.height) / 2 : 0;
    
    scrollView.contentInset = UIEdgeInsetsMake(offsetY, offsetX, offsetY, offsetX);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scale == scrollView.minimumZoomScale) {
        [self addGestureRecognizer:_panGestureRecognizer];
    }else{
        [self removeGestureRecognizer:_panGestureRecognizer];
    }
}

- (void)hideEverythingExceptImage
{
    _captionLabel.alpha = 0;
    _backgroundView.alpha = 0;
    
    _imageView.contentMode = UIViewContentModeCenter;
    _imageView.clipsToBounds = YES;
    
    if (_imageView.image.size.width > _imageView.image.size.height) {
        _imageView.frame = CGRectMake(_imageView.frame.origin.x + (_imageView.frame.size.width - _imageView.frame.size.height) / 2, _imageView.frame.origin.y, _imageView.frame.size.height, _imageView.frame.size.height);
    }else{
        _imageView.frame = CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y + (_imageView.frame.size.height - _imageView.frame.size.width) / 2, _imageView.frame.size.width, _imageView.frame.size.width);
    }
}

@end
