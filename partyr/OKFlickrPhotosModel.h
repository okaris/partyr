//
//  OKFlickrPhotosModel.h
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "JSONModel.h"
#import "OKFlickrPhotoModel.h"

@interface OKFlickrPhotosModel : JSONModel
@property (assign, nonatomic) int page;
@property (assign, nonatomic) int pages;
@property (assign, nonatomic) int perpage;
@property (strong, nonatomic) NSString *total;
@property (strong, nonatomic) NSArray <OKFlickrPhotoModel> *photo;

@end
