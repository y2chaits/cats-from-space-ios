//
//  ViewController.m
//  CatsFromSpace
//
//  Created by Chaitanya Bagaria on 4/11/15.
//  Copyright (c) 2015 Space Shrimp. All rights reserved.
//

#import "ViewController.h"
#import "SSClient.h"
#import "CoreLocation/CLGeocoder.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) GMSMarker *marker;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.7833
                                                            longitude:-122.4167
                                                                 zoom:5];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.delegate = self;

    self.mapView.mapType = kGMSTypeHybrid;


    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(37.7833, -122.4167);
    marker.title = @"San Francisco";
    marker.snippet = @"USA";
    marker.map = self.mapView;

//    [self.mapView setMinZoom:1 maxZoom:8];


    // Implement GMSTileURLConstructor
    // Returns a Tile based on the x,y,zoom coordinates, and the requested floor
//    GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger zoom) {
//
//        NSString *url = [NSString stringWithFormat:@"http://map1.vis.earthdata.nasa.gov/wmts-geo/MODIS_Terra_CorrectedReflectance_TrueColor/default/2015-04-08/EPSG4326_250m/%ld/%ld/%ld.jpeg", zoom, y, x];
//
//
//        NSLog(@"%@",url);
//
//        return [NSURL URLWithString:url];
//    };
//
//    // Create the GMSTileLayer
//    GMSURLTileLayer *layer = [GMSURLTileLayer tileLayerWithURLConstructor:urls];
//
//    // Display on the map at a specific zIndex
//    layer.zIndex = 100;
//    layer.map = self.mapView;


//    self.view = self.mapView;
}

-(void) mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate{

    if (!self.marker) {
        self.marker = [[GMSMarker alloc] init];
    }

    self.marker.position = coordinate;
    self.marker.title = @"Tap here to add tags";
    self.marker.draggable = YES;
    self.marker.appearAnimation = kGMSMarkerAnimationPop;
    self.marker.map = self.mapView;
    
}

- (BOOL) mapView: 		(GMSMapView *)  	mapView
    didTapMarker: 		(GMSMarker *)  	marker
{
    if (marker == self.marker) {
        UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:@"Enter tag \n"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Upload", nil];

        dialog.alertViewStyle = UIAlertViewStylePlainTextInput;
        [dialog show];
        return YES;
    }



    return NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex != [alertView cancelButtonIndex]) {
        UITextField *textfield =  [alertView textFieldAtIndex: 0];
        [SSClient submitTag:textfield.text lat:self.marker.position.latitude lon:self.marker.position.longitude zoom:(int) self.mapView.camera.zoom];

        // take screenshot
        UIGraphicsBeginImageContext(self.mapView.frame.size);
        [self.mapView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *screenShotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        CGSize newSize = CGSizeMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
        [screenShotImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];

        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        UIImageView *imageView = [[UIImageView alloc] initWithImage:smallImage];

        CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
        [alertView setContainerView:imageView];

        [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Share", @"Close", nil]];
        alertView.delegate = self;
        
        [alertView show];
    }
}

- (void) customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [alertView close];

        // Share button
        [self shareText:@"Look what I found on #CatsFromSpace" andImage:((UIImageView *)alertView.containerView).image andUrl:nil];
    } else {
        [alertView close];
    }
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url
{
    NSMutableArray *sharingItems = [NSMutableArray new];

    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void) mapView: 		(GMSMapView *)  	mapView
didBeginDraggingMarker: 		(GMSMarker *)  	marker
{

}

- (void) mapView: 		(GMSMapView *)  	mapView
didEndDraggingMarker: 		(GMSMarker *)  	marker
{

}

- (void) mapView: 		(GMSMapView *)  	mapView
   didDragMarker: 		(GMSMarker *)  	marker
{

}

- (BOOL) didTapMyLocationButtonForMapView: 		(GMSMapView *)  	mapView
{
    return NO;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    //Hide the keyboard
    [searchBar resignFirstResponder];

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchBar.text
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark* aPlacemark = placemarks[0];

                         GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:aPlacemark.location.coordinate.latitude
                                                                                 longitude:aPlacemark.location.coordinate.longitude
                                                                                      zoom:8];
                         [self.mapView animateToCameraPosition:camera];

                     } else {
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results"
                                                                         message:@"No Results Found"
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
                         
                         [alert show];
                     }
                 }];


}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
