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
#import "OKFlickrSmallPhotoCollectionViewCell.h"
#import "OKFlickrPhotoModel.h"
#import "OKFlickrCollectionFooterView.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()
{
    BOOL networkOperationInProgress;
    UICollectionView *photoCollectionView;
    CGFloat zoom;
    BOOL zoomed;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height) collectionViewLayout:layout];
    photoCollectionView.delegate = self;
    photoCollectionView.dataSource = self;
    photoCollectionView.layer.masksToBounds = NO;
    
    [photoCollectionView registerClass:[OKFlickrSmallPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"imageCell"];
    
    [photoCollectionView registerClass:[OKFlickrCollectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];

    [self.view addSubview:photoCollectionView];
    
    zoom = 3.f;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 40.f, [UIScreen mainScreen].bounds.size.width, 40.f)];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    [slider setValue:.7f];
    
    OKFlickrPhotoRequestModel *request = [OKFlickrPhotoRequestModel new];
    request.method = PhotoSearchEndpoint;
    request.tags = @"party";
    
    networkOperationInProgress = YES;
    
    [[OKServices sharedInstance] postRequestWithUrl:FlickrRestAPIUrl request:request onSuccess:^(OKJSONResponseModel *response) {
        
        OKFlickrPhotoResponseModel *formattedResponse = (OKFlickrPhotoResponseModel *)response;
        NSLog(@"Response: %@",formattedResponse.toJSONString);
        [[OKData sharedInstance] setFlickrPhotos:formattedResponse.photos];
        [[OKData sharedInstance] setCurrentPage:formattedResponse.photos.page];
        
        [photoCollectionView reloadData];

        networkOperationInProgress = NO;
        
    } onFailure:^(OKJSONErrorModel *error) {
        NSLog(@"Failure: %@", error.toJSONString);
        
        networkOperationInProgress = NO;
        
    } responseClass:[OKFlickrPhotoResponseModel class]];
}

- (IBAction)sliderValueChanged:(UISlider *)slider
{
    CGFloat newZoomLevel = floorf((1 - slider.value) * 10.f) + 1;
    if (zoom != newZoomLevel) {
        zoom = newZoomLevel;
        [photoCollectionView reloadData];
    }
}

- (void) loadMorePictures
{
    if (networkOperationInProgress) {
        return;
    }
    
    networkOperationInProgress = YES;
    
    OKFlickrPhotoRequestModel *request = [OKFlickrPhotoRequestModel new];
    request.method = PhotoSearchEndpoint;
    request.tags = @"party";
    request.page = [OKData sharedInstance].currentPage + 1;
    
    [[OKServices sharedInstance] postRequestWithUrl:FlickrRestAPIUrl request:request onSuccess:^(OKJSONResponseModel *response) {
        
        OKFlickrPhotoResponseModel *formattedResponse = (OKFlickrPhotoResponseModel *)response;
        NSLog(@"Response: %@",formattedResponse.toJSONString);
        
        NSMutableArray *temporaryArray = [NSMutableArray arrayWithArray:[OKData sharedInstance].flickrPhotos.photo];
                                          
        [temporaryArray addObjectsFromArray:formattedResponse.photos.photo];
        
        formattedResponse.photos.photo = [temporaryArray copy];
        
        [[OKData sharedInstance] setFlickrPhotos:formattedResponse.photos];
        
        [[OKData sharedInstance] setCurrentPage:formattedResponse.photos.page];

        [photoCollectionView reloadData];

        networkOperationInProgress = NO;
        
    } onFailure:^(OKJSONErrorModel *error) {
        NSLog(@"Failure: %@", error.toJSONString);
        
        networkOperationInProgress = NO;

    } responseClass:[OKFlickrPhotoResponseModel class]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return [OKData sharedInstance].flickrPhotos.photo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OKFlickrSmallPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    [self configureCell:cell forItemAtIndexPath:indexPath];
    
    if(indexPath.item == [OKData sharedInstance].flickrPhotos.photo.count - 10)
    {
        [self loadMorePictures];
    }
    
    return cell;
}

- (void)configureCell:(OKFlickrSmallPhotoCollectionViewCell *)cell
   forItemAtIndexPath:(NSIndexPath *)indexPath
{    
    OKFlickrPhotoModel *photo = (OKFlickrPhotoModel *) [[OKData sharedInstance].flickrPhotos.photo objectAtIndex:indexPath.item];
    
    [cell.imageView sd_setImageWithURL:[photo photoURLWithSize:OKPhotoSizeSmall]
                      placeholderImage:[UIImage imageNamed:@"42-photos"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                          cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                      }];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)theCollectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)theIndexPath
{
    UICollectionReusableView *theView;
    
    if(kind == UICollectionElementKindSectionHeader)
    {
        return nil;
    } else {
        theView = [theCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:theIndexPath];
    }
    
    return theView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if ([self collectionView:collectionView numberOfItemsInSection:section] == 0) {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
    }else{
        return CGSizeMake(collectionView.frame.size.width, 40.f);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if (zoomed) {
        [UIView animateWithDuration:.4f animations:^{
            collectionView.transform = CGAffineTransformIdentity;
        }];
        
        zoomed = NO;
    }else{
    
        CGRect targetFrame = CGRectMake(0, (self.view.frame.size.height - self.view.frame.size.width) /2, self.view.frame.size.width, self.view.frame.size.width);
        
        UICollectionViewLayoutAttributes * theAttributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
        
        CGRect cellFrameInSuperview = [collectionView convertRect:theAttributes.frame toView:self.view];
        
//        UIView *v = [[UIView alloc] initWithFrame:cellFrameInSuperview];
//        v.backgroundColor = OKPFlickrPink;
//        [self.view addSubview:v];
        
        CGAffineTransform transform = [self transformFromRect:cellFrameInSuperview toRect:targetFrame keepingAspectRatio:YES inParentView:collectionView]   ;
        
        [UIView animateWithDuration:.4f animations:^{
            collectionView.transform = transform;
        }];
        zoomed = YES;
    }
}

- (CGAffineTransform)transformFromRect:(CGRect)sourceRect toRect:(CGRect)finalRect keepingAspectRatio:(BOOL)keepingAspectRatio inParentView:(UIView *)parentView {
    CGAffineTransform transform = CGAffineTransformIdentity;

    CGFloat transformRatioX = CGRectGetWidth(finalRect)/CGRectGetWidth(sourceRect);
    CGFloat transformRatioY = CGRectGetHeight(finalRect)/CGRectGetHeight(sourceRect);

    CGFloat differenceX = (CGRectGetMinX(sourceRect) - (parentView.layer.anchorPoint.x * CGRectGetWidth(parentView.frame) + CGRectGetMinX(parentView.frame))) * (transformRatioX - 1);
    CGFloat differenceY = (CGRectGetMinY(sourceRect) - (parentView.layer.anchorPoint.y * CGRectGetHeight(parentView.frame) + CGRectGetMinY(parentView.frame))) * (transformRatioY - 1);
    
    sourceRect.origin = CGPointMake(CGRectGetMinX(sourceRect) + differenceX, CGRectGetMinY(sourceRect) + differenceY);

    CGAffineTransform transformTranslate = CGAffineTransformTranslate(transform, -(CGRectGetMinX(sourceRect)-CGRectGetMinX(finalRect)), -(CGRectGetMinY(sourceRect)-CGRectGetMinY(finalRect)));
    
    CGAffineTransform transformScale;
    if (keepingAspectRatio) {
        CGFloat sourceAspectRatio = sourceRect.size.width/sourceRect.size.height;
        CGFloat finalAspectRatio = finalRect.size.width/finalRect.size.height;
        
        if (sourceAspectRatio > finalAspectRatio) {
            transformScale = CGAffineTransformScale(transform, transformRatioY, transformRatioY);
        } else {
            transformScale = CGAffineTransformScale(transform, transformRatioX, transformRatioX);
        }
    } else {
        transformScale = CGAffineTransformScale(transform, transformRatioX, transformRatioY);
    }
    
    transform = CGAffineTransformConcat(transformScale, transformTranslate);
    return transform;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width / zoom, collectionView.frame.size.width / zoom);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
