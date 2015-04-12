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
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationBtn;

@property (strong, nonatomic) AGSLocator *locator;
@property (strong, nonatomic) AGSGraphicsLayer *graphicsLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    NSURL* url = [NSURL URLWithString: @"http://modis.arcgis.com/arcgis/rest/services/MODIS/ImageServer"];
//    NSString *name = @"Modis Tiled Layer";
//    AGSImageServiceLayer* layer = [AGSImageServiceLayer imageServiceLayerWithURL:url];
//    [self.mapView addMapLayer:layer withName:name];



    NSURL* url = [NSURL URLWithString: @"http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer"];
    NSString *name = @"World Imagery";

    AGSTiledMapServiceLayer* layer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL: url];
    [self.mapView addMapLayer:layer withName:name];

    AGSSimpleFillSymbol *fillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    fillSymbol.color = [[UIColor blackColor] colorWithAlphaComponent:1.0];
    fillSymbol.outline.color = [UIColor darkGrayColor];

    AGSGraphic* graphic = [AGSGraphic graphicWithGeometry:self.mapView.maxEnvelope.center symbol:fillSymbol attributes:nil];
    [self.graphicsLayer addGraphic:graphic];

    //Add a graphics layer to the map. This layer will hold geocoding results
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.mapView addMapLayer:self.graphicsLayer withName:@"Results"];


    //Assign a simple renderer to the layer to display results as pushpins
    AGSPictureMarkerSymbol* pushpin = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"LocationDisplay.png"];
    pushpin.offset = CGPointMake(9,16);
    pushpin.leaderPoint = CGPointMake(-9,11);
    AGSSimpleRenderer* renderer = [AGSSimpleRenderer simpleRendererWithSymbol:pushpin];
    self.graphicsLayer.renderer = renderer;


    self.mapView.layerDelegate = self;
    self.mapView.touchDelegate = self;

}

- (void)mapViewDidLoad:(AGSMapView *) mapView {
    //do something now that the map is loaded
    //for example, show the current location on the map
    [mapView.locationDisplay startDataSource];

    //
    AGSSpatialReference *sr = [AGSSpatialReference wgs84SpatialReference];
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:-123.4167
                                                ymin:36.7833
                                                xmax:-121.4167
                                                ymax:38.7833
                                    spatialReference:sr];


    [self.mapView zoomToEnvelope:env animated:YES];

}

- (IBAction)currentLocationBtnPressed:(id)sender {
    [self zoomToPoint:self.mapView.locationDisplay.location.point];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    //Hide the keyboard
    [searchBar resignFirstResponder];

    if(!self.locator){
        //Create the AGSLocator pointing to the geocode service on ArcGIS Online
        //Set the delegate so that we are informed through AGSLocatorDelegate methods
        self.locator = [AGSLocator locatorWithURL:[NSURL URLWithString:@"http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"]];
        self.locator.delegate = self;
    }

    //Set the parameters
    AGSLocatorFindParameters* params = [[AGSLocatorFindParameters alloc]init];
    params.text = searchBar.text;
    params.outFields = @[@"*"];
    params.outSpatialReference = self.mapView.spatialReference;

    //Kick off the geocoding operation.
    //This will invoke the geocode service on a background thread.
    [self.locator findWithParameters:params];
}


- (void)locator:(AGSLocator *)locator operation:(NSOperation *)op didFind:(NSArray *)results {
    if (results == nil || [results count] == 0)
    {
        //show alert if we didn't get results
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results"
                                                        message:@"No Results Found"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];

        [alert show];
    }
    else
    {
        AGSLocatorFindResult* result = results[0];
        [self zoomToPoint:(AGSPoint *)result.graphic.geometry];
    }
}

- (void) zoomToPoint:(AGSPoint *)point
{
    AGSSpatialReference *sr = point.spatialReference;
    double radius = ([sr isEqualToSpatialReference:[AGSSpatialReference wgs84SpatialReference]]) ? 0.1 : 5000;

    double x = point.x;
    double y = point.y;

    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:x - radius
                                                ymin:y - radius
                                                xmax:x + radius
                                                ymax:y + radius
                                    spatialReference:sr];

    NSLog(@"%@", env);

    [self.mapView zoomToEnvelope:env animated:YES];
}


- (void) mapView:(AGSMapView *)mapView didTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
//    [self.graphicsLayer removeAllGraphics];

    AGSPictureMarkerSymbol* pushpin = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"LocationDisplay.png"];
    pushpin.offset = CGPointMake(9,16);
    pushpin.leaderPoint = CGPointMake(-9,11);

    AGSGeometryEngine *engine = [AGSGeometryEngine new];

    mappoint = (AGSPoint *)[engine projectGeometry:mappoint toSpatialReference:self.mapView.spatialReference];

    AGSGraphic* graphic = [AGSGraphic graphicWithGeometry:mappoint symbol:pushpin attributes:nil];
    [self.graphicsLayer addGraphic:graphic];

    AGSMutableEnvelope *extent = [self.graphicsLayer.fullEnvelope mutableCopy];
    [extent expandByFactor:1.5];
    [self.mapView zoomToEnvelope:extent animated:YES];

    NSArray *layers = [self.mapView mapLayers];

    NSLog(@"%@", layers[0]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
