//
//  ViewController.m
//  CatsFromSpace
//
//  Created by Chaitanya Bagaria on 4/11/15.
//  Copyright (c) 2015 Space Shrimp. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>


@interface ViewController ()

@property (nonatomic, strong) GMSMapView *mapView;

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
    self.view = self.mapView;

    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(37.7833, -122.4167);
    marker.title = @"San Francisco";
    marker.snippet = @"USA";
    marker.map = self.mapView;

    [self.mapView setMinZoom:1 maxZoom:8];


    // Implement GMSTileURLConstructor
    // Returns a Tile based on the x,y,zoom coordinates, and the requested floor
    GMSTileURLConstructor urls = ^(NSUInteger x, NSUInteger y, NSUInteger zoom) {

        NSString *url = [NSString stringWithFormat:@"http://map1.vis.earthdata.nasa.gov/wmts-geo/MODIS_Terra_CorrectedReflectance_TrueColor/default/2015-04-08/EPSG4326_250m/%ld/%ld/%ld.jpeg", zoom, y, x];


        NSLog(@"%@",url);

        return [NSURL URLWithString:url];
    };

    // Create the GMSTileLayer
    GMSURLTileLayer *layer = [GMSURLTileLayer tileLayerWithURLConstructor:urls];

    // Display on the map at a specific zIndex
    layer.zIndex = 100;
    layer.map = self.mapView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
