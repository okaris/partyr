//
//  OKFlickrPhotoModel.h
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "JSONModel.h"
@protocol OKFlickrPhotoModel <NSObject>
@end

@interface OKFlickrPhotoModel : JSONModel

typedef NS_ENUM(NSInteger, OKPhotoSizeConstants){
    OKPhotoSizeSmallSquare,
    OKPhotoSizeLargeSquare,
    OKPhotoSizeThumbnail,
    OKPhotoSizeSmall,
    OKPhotoSizeMedium,
    OKPhotoSizeLarge,
    OKPhotoSizeOriginal
};

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *secret;
@property (strong, nonatomic) NSString *server;
@property (assign, nonatomic) int farm;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) int ispublic;
@property (assign, nonatomic) int isfriend;
@property (assign, nonatomic) int isfamily;
@end
