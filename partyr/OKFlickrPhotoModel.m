//
//  OKFlickrPhotoModel.m
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKFlickrPhotoModel.h"

@implementation OKFlickrPhotoModel

- (NSURL *)photoURLWithSize:(int) size
{
    NSString *sizeString;
    
    switch (size) {
        case OKPhotoSizeSmallSquare:
            sizeString = @"s";
            break;
        case OKPhotoSizeLargeSquare:
            sizeString = @"q";
            break;
        case OKPhotoSizeThumbnail:
            sizeString = @"t";
            break;
        case OKPhotoSizeSmall:
            sizeString = @"n";
            break;
        case OKPhotoSizeMedium:
            sizeString = @"z";
            break;
        case OKPhotoSizeLarge:
            sizeString = @"b";
            break;
        case OKPhotoSizeOriginal:
            sizeString = @"o";
            break;
        default:
            sizeString = @"z";
            break;
    }
    
    NSString *photoURLString = [NSString stringWithFormat:@"https://farm%i.staticflickr.com/%@/%@_%@_%@.jpg", self.farm, self.server, self.id, self.secret, sizeString];
    NSURL *photoURL = [NSURL URLWithString:photoURLString];
    
    return photoURL;
}

@end
