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
        httpRequestOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
        httpRequestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        httpRequestOperationManager.operationQueue.maxConcurrentOperationCount = 1;
        
    }
    return self;
}


-(void) initServicesWithBlock:(void (^)()) completion{
    
    
    
}

-(AFHTTPRequestOperation*)postRequestWithUrl:(NSString *)url request:(OKJSONRequestModel *)request onSuccess:(void (^)(OKJSONResponseModel *))successBlock onFailure:(void (^)(OKJSONErrorModel *))errorBlock responseClass:(Class)responseClass
{
    if (!request.format) {
        request.format = @"json";
    }
    
    return [httpRequestOperationManager POST:url parameters:[request toDictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        if (responseObject)
        {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:nil];
            NSString* prettyJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            prettyJson = [prettyJson stringByReplacingOccurrencesOfString:@"%" withString:@"%%"];
            
            
            JSONModelError* error;
            
            OKJSONResponseModel* response = [[responseClass alloc] initWithString:operation.responseString error:&error];
            
            if (error) {
                
                OKJSONErrorModel* baseError = [OKJSONErrorModel new];
                baseError.message = @"Generic Error";
                baseError.code = -1;
                if(errorBlock){
                    errorBlock(baseError);
                }
                
                
            }else{
                
                
                if ([response.stat isEqualToString:@"OK"]) {
                    if(successBlock){
                        successBlock(response);
                    }
                }else if([response.stat isEqualToString:@"fail"]){
                    OKJSONErrorModel* baseError = [OKJSONErrorModel new];
                    baseError.message = response.message;
                    baseError.stat = response.stat;
                    baseError.code = response.code;
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
                baseError.message = @"Generic Error";
                baseError.code = (int)error.code;
            }
            
            
            if (errorBlock) {
                errorBlock(baseError);
            }
        }

    }];
}

@end
