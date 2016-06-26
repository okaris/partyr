//
//  OKServices.h
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "JSONModel.h"
#import "OKJSONRequestModel.h"
#import "OKJSONResponseModel.h"
#import "OKJSONErrorModel.h"

#define FlickrRestAPIUrl @"https://api.flickr.com/services/rest/"
#define PhotoSearchEndpoint @"flickr.photos.search"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define OKPFlickrPink UIColorFromRGB(0xff2e92)
#define OKPFlickrBlue UIColorFromRGB(0x007bdc)

@interface OKServices : NSObject

@property (strong, nonatomic) AFHTTPRequestOperationManager* httpRequestOperationManager;
@property (strong, nonatomic) NSString* tokenCode;

+(instancetype) sharedInstance;

-(AFHTTPRequestOperation*) postRequestWithUrl:(NSString*) url
                                      request:(OKJSONRequestModel*) request
                                    onSuccess:(void(^)(OKJSONResponseModel*)) successBlock
                                    onFailure:(void(^)(OKJSONErrorModel*)) errorBlock
                                responseClass:(Class) responseClass;

@end
