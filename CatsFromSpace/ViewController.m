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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURL* url = [NSURL URLWithString: @"http://modis.arcgis.com/arcgis/rest/services/MODIS/ImageServer"];
    AGSImageServiceLayer* layer = [AGSImageServiceLayer imageServiceLayerWithURL:url];

    [self.mapView addMapLayer:layer withName:@"Modis Tiled Layer"];

    self.mapView.layerDelegate = self;

}

- (void)mapViewDidLoad:(AGSMapView *) mapView {
    //do something now that the map is loaded
    //for example, show the current location on the map
    [mapView.locationDisplay startDataSource];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
