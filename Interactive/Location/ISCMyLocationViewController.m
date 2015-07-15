//
//  ISCMyLocationViewController.m
//  Interactive
//
//  Created by WuYong on 6/12/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCMyLocationViewController.h"
#import <Parse/Parse.h>
#import "ISCAppDelegate.h"
#import "ISCGeoQueryAnnotation.h"
#import "ISCGeoPointAnnotation.h"
#import "ISCCircleOverlay.h"
#import "ISCMyLocationTableViewCell.h"


enum PinAnnotationTypeTag{
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};


@interface ISCMyLocationViewController ()<InvitationDelegate>{
    CLLocationCoordinate2D myCoordinate;
    NSUInteger showStatus;
    NSMutableArray *nearPeoples;
}
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) ISCCircleOverlay *targetOverlay;
@property (nonatomic, assign) CLLocationDistance radius;
@end

@implementation ISCMyLocationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    showStatus = 0;
    self.m_mapView.hidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    
    nearPeoples = [[NSMutableArray alloc]init];
    
    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
    myCoordinate = del.locationManager.location.coordinate;
    self.location = del.locationManager.location;
    self.radius = 10;

    self.m_mapView.region = MKCoordinateRegionMake(myCoordinate, MKCoordinateSpanMake(0.05f, 0.05f));
    
    [self configureOverlay];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    static NSString *GeoPointAnnotationIdentifier = @"RedPinAnnotation";
    static NSString *GeoQueryAnnotationIdentifier = @"PurplePinAnnotation";
    
    if([annotation isKindOfClass:[ISCGeoQueryAnnotation class]]){
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoQueryAnnotationIdentifier];
        if(!annotationView){
            annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:GeoQueryAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.animatesDrop = NO;
            annotationView.draggable = YES;
            
        }
        return annotationView;
    }else if([annotation isKindOfClass:[ISCGeoPointAnnotation class]]){
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
        if(!annotationView){
            annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:GeoPointAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            annotationView.draggable = NO;
        }
        return annotationView;
    }
    return nil;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
//    static NSString *circleOverlayIdentifier = @"Circle";
    
    if([overlay isKindOfClass:[ISCCircleOverlay class]]){
        ISCCircleOverlay *circleOverlay = (ISCCircleOverlay *)overlay;
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:circleOverlay.coordinate radius:circleOverlay.radius];
        
        MKCircleRenderer *annotationRender = [[MKCircleRenderer alloc]initWithCircle:circle];
        
        if(overlay == self.targetOverlay){
            annotationRender.fillColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
            annotationRender.strokeColor = [UIColor redColor];
            annotationRender.lineWidth = 1.0f;
        }else{
            annotationRender.fillColor = [UIColor colorWithWhite:0.3f alpha:0.3f];
            annotationRender.strokeColor = [UIColor purpleColor];
            annotationRender.lineWidth = 2.0f;
        }
        return annotationRender;
    }
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)sliderDidTouchUp:(UISlider *)sender {
    if(self.targetOverlay){
        [self.m_mapView removeOverlay:self.targetOverlay];
    }
    [self configureOverlay];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.radius = sender.value;
    if(self.targetOverlay){
        [self.m_mapView removeOverlay:self.targetOverlay];
    }
    self.targetOverlay = [[ISCCircleOverlay alloc]initWithCoordinate:self.location.coordinate radius:self.radius];
    [self.m_mapView addOverlay:self.targetOverlay];
}

- (void)configureOverlay{
    if( self.location){
        [self.m_mapView removeAnnotations:self.m_mapView.annotations];
        [self.m_mapView removeOverlays:self.m_mapView.overlays];
        
        ISCCircleOverlay *overlay = [[ISCCircleOverlay alloc]initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.m_mapView addOverlay:overlay];
        
        ISCGeoQueryAnnotation *annotation = [[ISCGeoQueryAnnotation alloc]initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.m_mapView addAnnotation:annotation];
        
        [self updateLocations];
    }
}

- (void)updateLocations{
    
    PFGeoPoint *geoPoint;
    geoPoint = [PFGeoPoint geoPointWithLocation:self.location];
    
    CGFloat kilometers = self.radius;
    PFQuery *query = [PFUser query];
    
    [query setLimit:10];
    
    [query whereKey:@"username" notEqualTo:[PFUser currentUser].username];
    [query whereKey:@"CurrentLocation" nearGeoPoint:geoPoint withinKilometers:kilometers];

    
    [nearPeoples removeAllObjects];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for (PFObject *object in objects){
                [nearPeoples addObject:object];
                ISCGeoPointAnnotation *geoPointAnnotation = [[ISCGeoPointAnnotation alloc]initWithObject:object];
                [self.m_mapView addAnnotation:geoPointAnnotation];
            }
            [self.m_tableview reloadData];
        }
    }];
}

- (IBAction)btnChangeShowStatus:(id)sender {
    
    if(showStatus == 1){
        showStatus = 0;
        self.m_tableview.hidden = NO;
        self.m_mapView.hidden = YES;
        [(UIButton *)sender setTitle:@"Show on the map" forState:UIControlStateNormal];
    }else if(showStatus == 0){
        showStatus = 1;
        self.m_tableview.hidden = YES;
        self.m_mapView.hidden = NO;
        [(UIButton *)sender setTitle:@"Show on the Table" forState:UIControlStateNormal];
    }
}

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [nearPeoples count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    UITableViewCell *cell = [[UITableViewCell alloc]init];
//    return cell;
//    for (PFObject *object in nearPeoples){
    PFObject *object = nearPeoples[indexPath.row];
    ISCGeoPointAnnotation *geoPointAnnotation = [[ISCGeoPointAnnotation alloc]initWithObject:object];
    [self.m_mapView addAnnotation:geoPointAnnotation];
    PFGeoPoint *geoPoint = object[@"CurrentLocation"];
    
    ISCMyLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NearPeopleCellIdentifier"];
    if(!cell){
        cell = [[ISCMyLocationTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NearPeopleCellIdentifier"];
    }
    cell.m_lblUser.text = [NSString stringWithFormat:@"User: %@", object[@"username"]];
    cell.m_lblCoords.text = [NSString stringWithFormat:@"Coordinates: (%.3f, %.3f)", geoPoint.latitude, geoPoint.longitude];
    cell.delegate = self;
    
//    }
    return cell;
}

#pragma mark - Invitation Delegate
- (void)btnInviteClicked:(NSString *)userName{
    
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"username" equalTo:    [userName substringFromIndex:6]];
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" matchesQuery:innerQuery];
    [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:[NSString stringWithFormat:@"You were invited from %@",[PFUser currentUser][@"username"]]];
}

-(void)dealloc{
    NSLog(@"MyLocationviewController deallocated");
}

@end
