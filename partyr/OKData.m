//
//  OKData.m
//  partyr
//
//  Created by Omer Karisman on 25/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "OKData.h"

@implementation OKData

+(instancetype) sharedInstance{
    
    static OKData* instance = nil;
    
    @synchronized( self ) {
        if( instance == nil ) {
            instance = [[OKData alloc] init];
        }
    }
    
    return instance;
}

-(instancetype)init{
    if ( (self = [super init]) )
    {
        
    }
    return self;
}

@end
