//
//  ViewController.m
//  partyr
//
//  Created by Omer Karisman on 24/06/16.
//  Copyright © 2016 Okaris. All rights reserved.
//

#import "ViewController.h"
#import "OKData.h"
#import "OKFlickrPhotoResponseModel.h"
#import "OKFlickrPhotoRequestModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    OKFlickrPhotoRequestModel *request = [OKFlickrPhotoRequestModel new];
    request.method = PhotoSearchEndpoint;
    request.tags = @"party";
    
    [[OKServices sharedInstance] postRequestWithUrl:FlickrRestAPIUrl request:request onSuccess:^(OKJSONResponseModel *response) {
        
        OKFlickrPhotoResponseModel *formattedResponse = (OKFlickrPhotoResponseModel *)response;
        NSLog(@"Response: %@",formattedResponse.toJSONString);
        [[OKData sharedInstance] setFlickrPhotos:formattedResponse.photos];
        [[OKData sharedInstance] setCurrentPage:formattedResponse.photos.page];

    } onFailure:^(OKJSONErrorModel *error) {
        NSLog(@"Failure: %@", error.toJSONString);
        
    } responseClass:[OKFlickrPhotoResponseModel class]];
}

- (void) loadMorePictures
{
    OKFlickrPhotoRequestModel *request = [OKFlickrPhotoRequestModel new];
    request.method = PhotoSearchEndpoint;
    request.tags = @"party";
    request.page = [OKData sharedInstance].currentPage + 1;
    
    [[OKServices sharedInstance] postRequestWithUrl:FlickrRestAPIUrl request:request onSuccess:^(OKJSONResponseModel *response) {
        
        OKFlickrPhotoResponseModel *formattedResponse = (OKFlickrPhotoResponseModel *)response;
        NSLog(@"Response: %@",formattedResponse.toJSONString);
        
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
            NSMakeRange(0,[[OKData sharedInstance].flickrPhotos.photo count])];
        
        NSMutableArray *temporaryArray = [NSMutableArray arrayWithArray:formattedResponse.photos.photo];
        
        [temporaryArray insertObjects:[OKData sharedInstance].flickrPhotos.photo atIndexes:indexes];

        formattedResponse.photos.photo = [temporaryArray copy];
        
        [[OKData sharedInstance] setFlickrPhotos:formattedResponse.photos];
        
    } onFailure:^(OKJSONErrorModel *error) {
        NSLog(@"Failure: %@", error.toJSONString);
        
    } responseClass:[OKFlickrPhotoResponseModel class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
