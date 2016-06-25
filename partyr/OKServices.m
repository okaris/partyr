//
//  OKServices.m
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKServices.h"
#import <AFNetworking/AFNetworking.h>

@implementation OKServices
@synthesize httpRequestOperationManager,tokenCode;

+(instancetype) sharedInstance{
    
    static OKServices* instance = nil;
    
    @synchronized( self ) {
        if( instance == nil ) {
            instance = [[OKServices alloc] init];
        }
    }
    
    return instance;
}

-(instancetype)init{
    if ( (self = [super init]) )
    {
        httpRequestOperationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:nil];
        httpRequestOperationManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];

        httpRequestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [httpRequestOperationManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [httpRequestOperationManager.requestSerializer setValue:@"UTF-8" forHTTPHeaderField:@"Accept-Encoding"];

        httpRequestOperationManager.operationQueue.maxConcurrentOperationCount = 1;
        
    }
    return self;
}

-(AFHTTPRequestOperation*)postRequestWithUrl:(NSString *)url request:(OKJSONRequestModel *)request onSuccess:(void (^)(OKJSONResponseModel *))successBlock onFailure:(void (^)(OKJSONErrorModel *))errorBlock responseClass:(Class)responseClass
{
    if (!request.format) {
        request.format = @"json";
    }
    
    if (!request.api_key) {
        request.api_key = @"46383d223578cb195eb6f5e257affb6b";
    }
    
    request.nojsoncallback = 1;
    
    NSLog(@"Request: %@", request.toJSONString);
    return [httpRequestOperationManager GET:url parameters:[request toDictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        if (responseObject)
        {
            
            JSONModelError* error;
            
            OKJSONResponseModel* response = [[responseClass alloc] initWithString:operation.responseString error:&error];
            
//            NSLog(@"Response: %@",[response toJSONString]);
            
            if (error) {
                
                OKJSONErrorModel* baseError = [OKJSONErrorModel new];
                baseError.message = error.description.localizedCapitalizedString;
                baseError.code = error.code;
                if(errorBlock){
                    errorBlock(baseError);
                }
            }else{
                
                
                if ([response.stat isEqualToString:@"ok"]) {
                    if(successBlock){
                        successBlock(response);
                    }
                }else if([response.stat isEqualToString:@"fail"]){
                    OKJSONErrorModel* baseError = [OKJSONErrorModel new];
                    baseError.message = response.message;
                    baseError.stat = response.stat;
                    baseError.code = [response.code integerValue];
                    if(errorBlock){
                        errorBlock(baseError);
                    }
                    
                }
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        if (!operation.isCancelled) {
            
            OKJSONErrorModel* baseError = [OKJSONErrorModel new];
            
            if(error.code == NSURLErrorTimedOut){
                baseError.message = @"URL Timed Out";
                baseError.code = NSURLErrorTimedOut;
            }else if(error.code == NSURLErrorNotConnectedToInternet){
                baseError.message = @"No Internet Connection";
                baseError.code = NSURLErrorNotConnectedToInternet;
            }else{
                baseError.message = error.description.localizedCapitalizedString;
                baseError.code = (int)error.code;
            }
            
            
            if (errorBlock) {
                errorBlock(baseError);
            }
        }

    }];
}

@end
