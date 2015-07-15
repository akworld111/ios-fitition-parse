//
//  ISCLocationPickerViewController.h
//  Fitition
//
//  Created by WuYong on 7/16/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ISCLocationPickerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *m_searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *m_mapView;

@end
