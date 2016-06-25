//
//  OKData.h
//  partyr
//
//  Created by Omer Karisman on 25/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OKFlickrPhotosModel.h"

@interface OKData : NSObject

@property (strong, nonatomic) OKFlickrPhotosModel *flickrPhotos;
@property (strong, nonatomic) int currentPage;

+(instancetype) sharedInstance;

@end
