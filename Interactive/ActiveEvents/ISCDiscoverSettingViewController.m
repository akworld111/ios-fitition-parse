//
//  ISCDiscoverSettingViewController.m
//  Fitition
//
//  Created by WuYong on 7/17/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCDiscoverSettingViewController.h"
#import <MapKit/MapKit.h>
#import "ISCCircleOverlay.h"
#import "ISCGeoQueryAnnotation.h"
#import "ISCGeoPointAnnotation.h"
#import "ISCAppDelegate.h"

enum PinAnnotationTypeTag{
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};

@interface ISCDiscoverSettingViewController ()<UISearchBarDelegate, UISearchDisplayDelegate, MKMapViewDelegate>{

    ISCCircleOverlay *targetOverlay;
    NSMutableArray *nearEvents;
    
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}

@property (weak, nonatomic) IBOutlet UISearchBar *m_searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *m_mapView;
@property (weak, nonatomic) IBOutlet UISlider *m_slider;

@end

@implementation ISCDiscoverSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    nearEvents = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
//    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
//    self.radius = 10;
//    self.centerCoords = [PFGeoPoint geoPointWithLocation:del.locationManager.location];
    self.m_slider.value = self.radius;
    [self.m_mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.centerCoords.latitude, self.centerCoords.longitude)];
    [self configureOverlay];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)btnBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnDoneClicked:(id)sender {
    NSDictionary *userInfo;
    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.centerCoords, @"CenterCoords", [NSNumber numberWithInteger:self.radius],@"Radius", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DiscoverSettingChanged" object:nil userInfo:userInfo];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)sliderValueChanged:(UISlider *)sender {
    self.radius = sender.value;
    if(targetOverlay){
        [self.m_mapView removeOverlay:targetOverlay];
    }
    
    CLLocation *tmpLocation = [[CLLocation alloc]initWithLatitude:self.centerCoords.latitude longitude:self.centerCoords.longitude];
    
    targetOverlay = [[ISCCircleOverlay alloc]initWithCoordinate:tmpLocation.coordinate radius:self.radius];
    [self.m_mapView addOverlay:targetOverlay];
}
- (IBAction)sliderValueChangingEnded:(id)sender {
    if(targetOverlay){
        [self.m_mapView removeOverlay:targetOverlay];
    }
    [self configureOverlay];
}
- (void)configureOverlay{
        [self.m_mapView removeAnnotations:self.m_mapView.annotations];
        [self.m_mapView removeOverlays:self.m_mapView.overlays];
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:self.centerCoords.latitude longitude:self.centerCoords.longitude];
    
        ISCCircleOverlay *overlay = [[ISCCircleOverlay alloc]initWithCoordinate:location.coordinate radius:self.radius];
        [self.m_mapView addOverlay:overlay];
        
        ISCGeoQueryAnnotation *annotation = [[ISCGeoQueryAnnotation alloc]initWithCoordinate:location.coordinate radius:self.radius];
        [self.m_mapView addAnnotation:annotation];
        
        [self updateLocations];
}

- (void)updateLocations{
    
    PFQuery *query = [[PFQuery alloc]initWithClassName:@"ActiveEvents"];
    NSString *gend = [[PFUser currentUser]objectForKey:@"gender"];
    if([gend isEqualToString:@"Male"]){
        gend = @"Female";
    }else{
        gend = @"Male";
    }
    [query whereKey:@"PostTo" notEqualTo:gend];
    [query whereKey:@"Closed" notEqualTo:@"YES"];
    [query whereKey:@"People" notContainedIn:@[[PFUser currentUser].objectId]];
    
    [query whereKey:@"PlaceCoords" nearGeoPoint:self.centerCoords withinKilometers:self.radius];
    
    [query orderByDescending:@"updatedAt"];
    query.limit = 10;
    query.skip = 0;
    
    
    [nearEvents removeAllObjects];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for (PFObject *object in objects){
                [nearEvents addObject:object];
                ISCGeoPointAnnotation *geoPointAnnotation = [[ISCGeoPointAnnotation alloc]initWithObject:object :YES];
                [self.m_mapView addAnnotation:geoPointAnnotation];
            }
        }
    }];
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
            annotationView.draggable = NO;
            
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
        
        if(overlay == targetOverlay){
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


#pragma mark - Search Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [localSearch cancel];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //Cancel any previous searches.
    [localSearch cancel];
    
    //Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.m_mapView.region;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if(error){
            [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Map Error!", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil]show];
            return ;
        }
        
        if([response.mapItems count] == 0){
            [[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No Results", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil]show];
            return;
        }
        
        results = response;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

#pragma mark - SearchResult View Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"SearchResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.placemark.addressDictionary[@"Street"];
    //    NSLog(@"%@",    item.placemark.title);
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchDisplayController setActive:NO animated:YES];
    
    MKMapItem *item = results.mapItems[indexPath.row];
//    [self.m_mapView addAnnotation:item.placemark];
//    [self.m_mapView selectAnnotation:item.placemark animated:YES];
//    [self.m_mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
//    [self.m_mapView setUserTrackingMode:MKUserTrackingModeNone];
    self.centerCoords = [PFGeoPoint geoPointWithLocation:item.placemark.location];
    [self.m_mapView setCenterCoordinate:item.placemark.location.coordinate];
    [self configureOverlay];
}
@end
