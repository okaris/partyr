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

@interface OKServices : NSObject

@property (strong, nonatomic) AFHTTPRequestOperationManager* httpRequestOperationManager;
@property (strong, nonatomic) NSString* tokenCode;

+(instancetype) sharedInstance;
-(void) initServicesWithBlock:(void (^)()) completion;

-(AFHTTPRequestOperation*) postRequestWithUrl:(NSString*) url
                                      request:(OKJSONRequest*) request
                                    onSuccess:(void(^)(OKJSONResponse*)) successBlock
                                    onFailure:(void(^)(OKJSONError*)) errorBlock
                                responseClass:(Class) responseClass;

@end
