//
//  ViewController.m
//  CatsFromSpace
//
//  Created by Chaitanya Bagaria on 4/11/15.
//  Copyright (c) 2015 Space Shrimp. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL* url = [NSURL URLWithString: @"http://modis.arcgis.com/arcgis/rest/services/MODIS/ImageServer"];
    AGSImageServiceLayer* layer = [AGSImageServiceLayer imageServiceLayerWithURL:url];

    [self.mapView addMapLayer:layer withName:@"Modis Tiled Layer"];

    self.mapView.layerDelegate = self;
    self.mapView.touchDelegate = self;

}

- (void)mapViewDidLoad:(AGSMapView *) mapView {
    //do something now that the map is loaded
    //for example, show the current location on the map
    [mapView.locationDisplay startDataSource];

    //
    AGSSpatialReference *sr = [self.mapView spatialReference];
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-123.4167
                                                ymin:36.7833
                                                xmax:-121.4167
                                                ymax:38.7833
                                    spatialReference:sr];

    NSLog(@"%@", env);

    [self.mapView zoomToEnvelope:env animated:YES];

}

- (IBAction)currentLocationBtnPressed:(id)sender {

//    NSLog(@"%@", self.mapView.visibleAreaEnvelope);

    AGSSpatialReference *sr = [self.mapView spatialReference];

    double x = self.mapView.locationDisplay.location.point.x;
    double y = self.mapView.locationDisplay.location.point.y;

    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:x - 1
                                                ymin:y - 1
                                                xmax:x + 1
                                                ymax:y + 1
                                    spatialReference:sr];

    NSLog(@"%@", env);

    [self.mapView zoomToEnvelope:env animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
