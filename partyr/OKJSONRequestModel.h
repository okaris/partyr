//
//  OKJSONRequestModel.h
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface OKJSONRequestModel : JSONModel
@property (strong, nonatomic) NSString *api_key;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSString *format;
@property (assign, nonatomic) int per_page;
@property (assign, nonatomic) int nojsoncallback;
@end
