//
//  ISCLocationPickerViewController.m
//  Fitition
//
//  Created by WuYong on 7/16/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCLocationPickerViewController.h"

@interface ISCLocationPickerViewController ()<UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate>

@end

@implementation ISCLocationPickerViewController{
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *annIdentifier = @"myAnnotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.m_mapView dequeueReusableAnnotationViewWithIdentifier:annIdentifier];
    if(!annotationView){
        annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annIdentifier];
        annotationView.pinColor = MKPinAnnotationColorRed;
        annotationView.animatesDrop = YES;
        annotationView.canShowCallout = YES;
    }else{
        annotationView.annotation = annotation;
    }
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
//    NSLog(@"Annotation: %@",view.annotation);
//    MKPlacemark *info = (MKPlacemark *)view.annotation;
//    NSLog(@"Name: %@", info.name);
//    NSLog(@"Coords: (%f, %f)", info.location.coordinate.longitude, info.location.coordinate.latitude);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:view.annotation forKey:@"SelectedPlace"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SelectedPlaceNotification" object:nil userInfo:userInfo];
    [self btnBackClicked:nil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.searchDisplayController setDelegate:self];
    [self.m_searchBar setDelegate:self];
    
    // Zoom the map to current location.
    [self.m_mapView setDelegate:self];
    [self.m_mapView setShowsUserLocation:YES];
    [self.m_mapView setUserInteractionEnabled:YES];
    [self.m_mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
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
    [self.searchDisplayController setActive:NO animated:YES];
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
    [self.m_mapView addAnnotation:item.placemark];
    [self.m_mapView selectAnnotation:item.placemark animated:YES];
    [self.m_mapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
    [self.m_mapView setUserTrackingMode:MKUserTrackingModeNone];
}
@end
