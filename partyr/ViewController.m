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
#import "OKFlickrPhotoDetailView.h"
#import "PureLayout.h"
#import "extobjc.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define OKFlickrScaleSliderHeight 40.f

NSInteger const itemsBeforeEndToPullMoreData = 10;

@interface ViewController ()
@property (strong, nonatomic) OKFlickrSmallPhotoCollectionViewCell *zoomedCell;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height) collectionViewLayout:layout];
    _photoCollectionView.delegate = self;
    _photoCollectionView.dataSource = self;
    _photoCollectionView.layer.masksToBounds = NO;
    _photoCollectionView.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0.0f, OKFlickrScaleSliderHeight, 0.0f);

    [_photoCollectionView registerClass:[OKFlickrSmallPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"imageCell"];
    
    [_photoCollectionView registerClass:[OKFlickrCollectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];

    [self.view addSubview:_photoCollectionView];
    
    [_photoCollectionView autoPinEdgesToSuperviewEdges];
  
    CGFloat initialCollectionViewZoom = 3.f;
    
    _collectionViewZoom = initialCollectionViewZoom;
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - OKFlickrScaleSliderHeight, [UIScreen mainScreen].bounds.size.width, OKFlickrScaleSliderHeight)];
    slider.thumbTintColor = OKPFlickrPink;
    slider.tintColor = OKPFlickrBlue;
    slider.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
    [slider setValue: 1.f - initialCollectionViewZoom/10.f];

    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:slider];
    
    [slider autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [slider autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [slider autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [slider autoSetDimension:ALDimensionHeight toSize:OKFlickrScaleSliderHeight relation:NSLayoutRelationEqual];
    
    OKFlickrPhotoRequestModel *request = [OKFlickrPhotoRequestModel new];
    request.method = PhotoSearchEndpoint;
    request.tags = @"party";
    
    _networkOperationInProgress = YES;
    
    [[OKServices sharedInstance] postRequestWithUrl:FlickrRestAPIUrl request:request onSuccess:^(OKJSONResponseModel *response)
    {        
        OKFlickrPhotoResponseModel *formattedResponse = (OKFlickrPhotoResponseModel *)response;
        NSLog(@"Response: %@",formattedResponse.toJSONString);
        [[OKData sharedInstance] setFlickrPhotos:formattedResponse.photos];
        [[OKData sharedInstance] setCurrentPage:formattedResponse.photos.page];
        
        [_photoCollectionView reloadData];

        _networkOperationInProgress = NO;
        
    } onFailure:^(OKJSONErrorModel *error)
    {
        NSLog(@"Failure: %@", error.toJSONString);
        
        _networkOperationInProgress = NO;
        
    } responseClass:[OKFlickrPhotoResponseModel class]];
}

- (IBAction)sliderValueChanged:(UISlider *)slider
{
    CGFloat newZoomLevel = floorf((1 - slider.value) * 10.f) + 1;
    if (_collectionViewZoom != newZoomLevel)
    {
        _collectionViewZoom = newZoomLevel;
        [_photoCollectionView reloadData];
    }
}

- (void) loadMorePictures
{
    if (_networkOperationInProgress)
    {
        return;
    }
    
    _networkOperationInProgress = YES;
    
    OKFlickrPhotoRequestModel *request = [OKFlickrPhotoRequestModel new];
    request.method = PhotoSearchEndpoint;
    request.tags = @"party";
    request.page = [OKData sharedInstance].currentPage + 1;
    
    [[OKServices sharedInstance] postRequestWithUrl:FlickrRestAPIUrl request:request onSuccess:^(OKJSONResponseModel *response)
    {
        OKFlickrPhotoResponseModel *formattedResponse = (OKFlickrPhotoResponseModel *)response;
        NSLog(@"Response: %@",formattedResponse.toJSONString);
        
        NSMutableArray *temporaryArray = [NSMutableArray arrayWithArray:[OKData sharedInstance].flickrPhotos.photo];
                                          
        [temporaryArray addObjectsFromArray:formattedResponse.photos.photo];
        
        formattedResponse.photos.photo = [temporaryArray copy];
        
        [[OKData sharedInstance] setFlickrPhotos:formattedResponse.photos];
        
        [[OKData sharedInstance] setCurrentPage:formattedResponse.photos.page];

        [_photoCollectionView reloadData];

        _networkOperationInProgress = NO;
        
    } onFailure:^(OKJSONErrorModel *error)
    {
        NSLog(@"Failure: %@", error.toJSONString);
        
        _networkOperationInProgress = NO;

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
    
    if(indexPath.item == [OKData sharedInstance].flickrPhotos.photo.count - itemsBeforeEndToPullMoreData)
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
                      placeholderImage:[UIImage imageNamed:@"42-photos"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                      {
                            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
                      }];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)theCollectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)theIndexPath
{
    
    if(kind == UICollectionElementKindSectionHeader)
    {
        return nil;
    }
    
    UICollectionReusableView *theView = [theCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:theIndexPath];
    
    return theView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if ([self collectionView:collectionView numberOfItemsInSection:section] == 0)
    {
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height);
    }
    
    return CGSizeMake(collectionView.frame.size.width, OKFlickrScaleSliderHeight);

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self zoomInCollectionViewAndDisplayDetailView:collectionView fromCellAtIndexPath:indexPath completion:^(BOOL finished) {
        _collectionViewIsZoomed = YES;
    }];
}

- (void)zoomInCollectionViewAndDisplayDetailView:(UICollectionView *)collectionView fromCellAtIndexPath:(NSIndexPath *)indexPath completion:(void (^ __nullable)(BOOL finished))completion
{
    OKFlickrSmallPhotoCollectionViewCell *cell = (OKFlickrSmallPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    _zoomedCell = cell;
    
    OKFlickrPhotoModel *photo = (OKFlickrPhotoModel *) [[OKData sharedInstance].flickrPhotos.photo objectAtIndex:indexPath.item];
    
    CGFloat photoAspectRatio = cell.imageView.image.size.height / cell.imageView.image.size.width;
    CGFloat heightConsideringPhotoAspectRatio = self.view.frame.size.width * photoAspectRatio;
    //    CGFloat widthConsiderinPhotoAspectRatio = self.view.frame.size.width * photoAspectRatio;
    if (heightConsideringPhotoAspectRatio > self.view.frame.size.width) {
        heightConsideringPhotoAspectRatio = self.view.frame.size.width;
    }
    
    CGRect targetFrame = CGRectMake((self.view.frame.size.width - heightConsideringPhotoAspectRatio) /2, (self.view.frame.size.height - heightConsideringPhotoAspectRatio) /2, heightConsideringPhotoAspectRatio, heightConsideringPhotoAspectRatio);
    
    UICollectionViewLayoutAttributes * theAttributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
    
    CGRect cellFrameInSuperview = [collectionView convertRect:theAttributes.frame toView:self.view];
    
    CGAffineTransform transform = [self transformFromRect:cellFrameInSuperview toRect:targetFrame keepingAspectRatio:YES inParentView:collectionView]   ;
    
    OKFlickrPhotoDetailView * detailView = [self photoDetailViewWithPhoto:photo andPlaceholderImage:cell.imageView.image];
    detailView.alpha = 0;
    
    @weakify(detailView);
    detailView.onDismiss = ^(void){
        @strongify(detailView);
        [self zoomOutCollectionView:detailView];
    };
    
    [self.view addSubview:detailView];
    
    detailView.dismissTransform = CGAffineTransformInvert(transform);
    detailView.transform = detailView.dismissTransform;
    
    [UIView animateWithDuration:.4f animations:^{
        collectionView.transform = transform;
        detailView.transform = CGAffineTransformIdentity;
        detailView.alpha = 1;
    } completion:^(BOOL finished) {
        [cell hideImage];
        completion(finished);
    }];
}

- (void)zoomOutCollectionView:(OKFlickrPhotoDetailView *)detailView
{
    if (_collectionViewIsZoomed)
    {
        [UIView animateWithDuration:.4f animations:^{
            _photoCollectionView.transform = CGAffineTransformIdentity;
            detailView.transform = detailView.dismissTransform;
            [detailView hideEverythingExceptImage];
        } completion:^(BOOL finished)
        {
            [_zoomedCell showImage];
            [detailView removeFromSuperview];
        }];
        
        _collectionViewIsZoomed = NO;
    }
}

- (OKFlickrPhotoDetailView *)photoDetailViewWithPhoto:(OKFlickrPhotoModel *)photo andPlaceholderImage:(UIImage *)placeholderImage
{
    OKFlickrPhotoDetailView *detailView = [[OKFlickrPhotoDetailView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    detailView.photo = photo;
    detailView.placeholderImage = placeholderImage;
    return detailView;
}

- (CGAffineTransform)transformFromRect:(CGRect)sourceRect toRect:(CGRect)finalRect keepingAspectRatio:(BOOL)keepingAspectRatio inParentView:(UIView *)parentView
{
    CGAffineTransform transform = CGAffineTransformIdentity;

    CGFloat transformRatioX = CGRectGetWidth(finalRect)/CGRectGetWidth(sourceRect);
    CGFloat transformRatioY = CGRectGetHeight(finalRect)/CGRectGetHeight(sourceRect);

    CGFloat differenceX = (CGRectGetMinX(sourceRect) - (parentView.layer.anchorPoint.x * CGRectGetWidth(parentView.frame) + CGRectGetMinX(parentView.frame))) * (transformRatioX - 1);
    CGFloat differenceY = (CGRectGetMinY(sourceRect) - (parentView.layer.anchorPoint.y * CGRectGetHeight(parentView.frame) + CGRectGetMinY(parentView.frame))) * (transformRatioY - 1);
    
    sourceRect.origin = CGPointMake(CGRectGetMinX(sourceRect) + differenceX, CGRectGetMinY(sourceRect) + differenceY);

    CGAffineTransform transformTranslate = CGAffineTransformTranslate(transform, -(CGRectGetMinX(sourceRect)-CGRectGetMinX(finalRect)), -(CGRectGetMinY(sourceRect)-CGRectGetMinY(finalRect)));
    
    CGAffineTransform transformScale;
    if (keepingAspectRatio)
    {
        CGFloat sourceAspectRatio = sourceRect.size.width/sourceRect.size.height;
        CGFloat finalAspectRatio = finalRect.size.width/finalRect.size.height;
        
        if (sourceAspectRatio > finalAspectRatio)
        {
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
    return CGSizeMake(collectionView.frame.size.width / _collectionViewZoom, collectionView.frame.size.width / _collectionViewZoom);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
