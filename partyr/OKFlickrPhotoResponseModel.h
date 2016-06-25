//
//  OKFlickrPhotoResponseModel.h
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKJSONResponseModel.h"
#import "OKFlickrPhotosModel.h"

@interface OKFlickrPhotoResponseModel : OKJSONResponseModel
@property (strong, nonatomic) OKFlickrPhotosModel *photos;
@end
