//
//  OKJSONResponseModel.h
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface OKJSONResponseModel : JSONModel
@property (strong, nonatomic) NSString *stat;
@property (assign, nonatomic) NSNumber<Optional> *code;
@property (strong, nonatomic) NSString<Optional> *message;
@end
