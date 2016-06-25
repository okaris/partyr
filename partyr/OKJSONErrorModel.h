//
//  OKJSONErrorModel.h
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface OKJSONErrorModel : JSONModel
@property (strong, nonatomic) NSString *stat;
@property (assign, nonatomic) NSInteger code;
@property (strong, nonatomic) NSString *message;
@end
