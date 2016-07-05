//
//  OKFlickrCollectionFooterView.m
//  partyr
//
//  Created by Omer Karisman on 25/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKFlickrCollectionFooterView.h"
#import "OKServices.h"

CGFloat const BallWidth = 20.f;

@interface OKFlickrCollectionFooterView()
{
    UIView *blueView;
    UIView *pinkView;
}

@end

@implementation OKFlickrCollectionFooterView

- (id)initWithFrame:(CGRect)rect
{
    if ((self = [super initWithFrame:rect]))
    {
        [self prepareLayout:rect];
    }
    return self;
}

- (void)prepareLayout:(CGRect)rect
{
    blueView = [[UIView alloc] init];
    
    pinkView = [[UIView alloc] init];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    
    blueView.frame = CGRectMake(rect.size.width/2 - BallWidth, (rect.size.height - BallWidth)/2, BallWidth, BallWidth);
    blueView.backgroundColor = OKPFlickrBlue;
    blueView.layer.cornerRadius = BallWidth/2;
    blueView.layer.masksToBounds = YES;
    [self addSubview:blueView];
    
    pinkView.frame = CGRectMake(rect.size.width/2, (rect.size.height - BallWidth)/2, BallWidth, BallWidth);
    pinkView.backgroundColor = OKPFlickrPink;
    pinkView.layer.cornerRadius = BallWidth/2;
    pinkView.layer.masksToBounds = YES;
    [self addSubview:pinkView];
    
    [self startAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval: .8f
                                     target: self
                                   selector:@selector(startAnimating)
                                   userInfo: nil repeats:YES];

}

- (void)startAnimating
{
    [UIView animateWithDuration:.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        blueView.frame = CGRectMake(self.frame.size.width/2, (self.frame.size.height - BallWidth)/2, BallWidth, 20);
        pinkView.frame = CGRectMake(self.frame.size.width/2 - BallWidth, (self.frame.size.height - BallWidth) / 2, BallWidth, BallWidth);
    } completion:^(BOOL finished)
    {
        [self bringSubviewToFront:blueView];
        [UIView animateWithDuration:.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            pinkView.frame = CGRectMake(self.frame.size.width/2, (self.frame.size.height - BallWidth)/2, BallWidth, 20);
            blueView.frame = CGRectMake(self.frame.size.width/2 - BallWidth, (self.frame.size.height - BallWidth) / 2, BallWidth, BallWidth);
        } completion:^(BOOL finished)
        {
            [self bringSubviewToFront:pinkView];
        }];
    }];
}


@end
