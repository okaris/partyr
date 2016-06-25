//
//  OKFlickrPhotoRequestModel.h
//  partyr
//
//  Created by Omer Karisman on 25/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKJSONRequestModel.h"

@interface OKFlickrPhotoRequestModel : OKJSONRequestModel
@property (strong, nonatomic) NSString *tags;
@property (assign, nonatomic) int page;
@end
