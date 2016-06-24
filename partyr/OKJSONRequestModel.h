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
@property (strong, nonatomic) NSString *tags;
@end
