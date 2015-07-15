//
//  ISCMyLocationViewController.h
//  Interactive
//
//  Created by WuYong on 6/12/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ISCMyLocationViewController : UIViewController<MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>{
    
}
@property (weak, nonatomic) IBOutlet MKMapView *m_mapView;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UITableView *m_tableview;


@end
