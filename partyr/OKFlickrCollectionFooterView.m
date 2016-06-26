//
//  OKFlickrCollectionFooterView.m
//  partyr
//
//  Created by Omer Karisman on 25/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKFlickrCollectionFooterView.h"
#import "OKServices.h"

@interface OKFlickrCollectionFooterView()
{
    UIView *blueView;
    UIView *pinkView;
}

@end

@implementation OKFlickrCollectionFooterView


- (void)drawRect:(CGRect)rect {

    blueView = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width/2 - 20, rect.size.height / 2 - 10, 20, 20)];
    blueView.backgroundColor = OKPFlickrBlue;
    blueView.layer.cornerRadius = 10;
    blueView.layer.masksToBounds = YES;
    [self addSubview:blueView];
    
    pinkView = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width/2, rect.size.height / 2 - 10, 20, 20)];
    pinkView.backgroundColor = OKPFlickrPink;
    pinkView.layer.cornerRadius = 10;
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
        blueView.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height / 2 - 10, 20, 20);
        pinkView.frame = CGRectMake(self.frame.size.width/2 - 20, self.frame.size.height / 2 - 10, 20, 20);
    } completion:^(BOOL finished) {
        [self bringSubviewToFront:blueView];
        [UIView animateWithDuration:.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            pinkView.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height / 2 - 10, 20, 20);
            blueView.frame = CGRectMake(self.frame.size.width/2 - 20, self.frame.size.height / 2 - 10, 20, 20);
        } completion:^(BOOL finished) {
            [self bringSubviewToFront:pinkView];
        }];
    }];
}


@end
