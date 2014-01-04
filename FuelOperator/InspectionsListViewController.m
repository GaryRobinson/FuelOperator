//
//  InspectionsListViewController.m
//  FuelOperator
//
//  Created by Gary Robinson on 3/15/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "InspectionsListViewController.h"
#import "InspectionsListCellView.h"
#import <MapKit/MapKit.h>
#import "InspectionFormViewController.h"
#import "MapAnnotation.h"
#import "MapAnnotationView.h"
#import "SignatureViewController.h"

#define INSPECTIONS_LIST_CELL_VIEW_TAG 3

@interface InspectionsListViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) UISegmentedControl *listMapControl;
@property (nonatomic, strong) UIButton *addSiteBtn;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleDateLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIView *switchView;

@property (nonatomic, strong) NSArray *inspections;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL firstTimeMap;
@property (nonatomic, strong) MKPointAnnotation *curLocationAnnotation;

@end

@implementation InspectionsListViewController

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-noise"]];
    self.firstTimeMap = YES;
    
    self.navigationItem.titleView = self.listMapControl;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addSiteBtn];
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.switchView];
    [self.switchView addSubview:self.mapView];
    [self.switchView addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitInspection:) name:@"submitInspection" object:nil];
    
    [self useCustomBackButton];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)submitInspection:(NSNotification *)notification
{
    Inspection *inspection = [notification.userInfo objectForKey:@"inspection"];
    SignatureViewController *sigVC = [[SignatureViewController alloc] init];
    sigVC.inspection = inspection;
    [self presentViewController:sigVC animated:YES completion:nil];
}

- (void)viewDidLayoutSubviews
{
    self.switchView.frame = CGRectMake(0, self.titleView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.titleView.frame.size.height);
    self.tableView.frame = CGRectMake(0, 0, self.switchView.frame.size.width, self.switchView.frame.size.height);
    self.mapView.frame = CGRectMake(0, 0, self.switchView.frame.size.width, self.switchView.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    
    self.inspections = [Inspection MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(user.login = %@) AND (date >= %@) AND (date < %@)", [User loggedInUser].login, _date, [NSDate dateWithNumberOfDays:1 sinceDate:_date]]];
    
    //format the date selected here like: "Mon Oct 6, 2012"
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEEE"];
    NSString *day = [dayFormatter stringFromDate:_date];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:_date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    int monthIndex = [components month] - 1;
    NSString *monthName = [[formatter monthSymbols] objectAtIndex:monthIndex];
    monthName = [monthName substringToIndex:3];
    
    [formatter setDateFormat:@"dd"];
    NSString *dayAndYear = [formatter stringFromDate:_date];
    
    self.dateString = [NSString stringWithFormat:@"%@, %@ %@", day, monthName, dayAndYear];
}

- (UISegmentedControl*)listMapControl
{
    if(_listMapControl == nil)
    {
        CGFloat width = 170;
        _listMapControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - width/2, 10, width, 30)];
        _listMapControl.segmentedControlStyle = UISegmentedControlStyleBar;
        
        UIImage *listImage = [UIImage imageNamed:@"listView"];
        UIImage *mapImage = [UIImage imageNamed:@"mapView"];
        
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        {
            listImage = [listImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            mapImage = [mapImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        
        [_listMapControl insertSegmentWithImage:listImage atIndex:0 animated:NO];
        [_listMapControl insertSegmentWithImage:mapImage atIndex:1 animated:NO];
        
        _listMapControl.selectedSegmentIndex = 0;
        
        [_listMapControl setBackgroundImage:[UIImage imageNamed:@"segemented-background"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_listMapControl setBackgroundImage:[UIImage imageNamed:@"segemented-background-selected"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [_listMapControl setDividerImage:[UIImage imageNamed:@"segemented-background"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_listMapControl setDividerImage:[UIImage imageNamed:@"segemented-background"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        _listMapControl.layer.cornerRadius = 5;
        _listMapControl.layer.masksToBounds = YES;
        [_listMapControl addTarget:self action:@selector(toggleListMap:) forControlEvents:UIControlEventValueChanged];
    }
    return _listMapControl;
}

- (void)toggleListMap:(id)sender
{
    [UIView beginAnimations:@"View Flip" context:nil];
	[UIView setAnimationDuration:1.25];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.switchView cache:YES];
    
    if(self.listMapControl.selectedSegmentIndex == 0)
    {
        [self.switchView addSubview:self.tableView];
        [self.mapView removeFromSuperview];
    }
    else
    {
        [self.switchView addSubview:self.mapView];
        [self.tableView removeFromSuperview];
        
        if(self.firstTimeMap)
        {
            self.firstTimeMap = NO;
            [self locationTapped:self];
        }
    }
    
    [UIView commitAnimations];
}

- (UIButton*)addSiteBtn
{
    if(_addSiteBtn == nil)
    {
        _addSiteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *addSiteImage = [UIImage imageNamed:@"addSite"];
        [_addSiteBtn setImage:addSiteImage forState:UIControlStateNormal];
        _addSiteBtn.frame = CGRectMake(0, 0, addSiteImage.size.width, addSiteImage.size.height);
        [_addSiteBtn addTarget:self action:@selector(addSite:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addSiteBtn;
}

- (void)addSite:(id)sender
{
    NSLog(@"addSite\n");
}

- (UIView*)titleView
{
    if(_titleView == nil)
    {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
        _titleView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black-noise.png"]];
        [_titleView addSubview:self.titleDateLabel];
    }
    return _titleView;
}

- (UILabel*)titleDateLabel
{
    if(_titleDateLabel == nil)
    {
        _titleDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, 40)];
        _titleDateLabel.backgroundColor = [UIColor clearColor];
        _titleDateLabel.font = [UIFont thinFontOfSize:36];
        _titleDateLabel.textColor = [UIColor whiteColor];
        //?? do the day they picked
        _titleDateLabel.text = self.dateString;
    }
    return _titleDateLabel;
}

- (void)setDateString:(NSString *)dateString
{
    _dateString = dateString;
    self.titleDateLabel.text = _dateString;
}

- (UIView*)switchView
{
    if(_switchView == nil)
    {
        _switchView = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.titleView.frame.size.height - 60)];
    }
    return _switchView;
}

- (UITableView*)tableView
{
    if(_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.switchView.frame.size.width, self.switchView.frame.size.height)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor fopOffWhiteColor];
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.inspections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return INSPECTIONS_LIST_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"inspectionsListCell";
    
    InspectionsListCellView *cellView = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        cellView = [[InspectionsListCellView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.width)];
        cellView.tag = INSPECTIONS_LIST_CELL_VIEW_TAG;
        [cell.contentView addSubview:cellView];
    }
    else
    {
        cellView = (InspectionsListCellView *)[cell.contentView viewWithTag:INSPECTIONS_LIST_CELL_VIEW_TAG];
    }
    
    Inspection *inspection = [self.inspections objectAtIndex:indexPath.row];
    cellView.inspection = inspection;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    self.navigationItem.title = @" ";
    
    InspectionFormViewController *inspectionFormVC = [[InspectionFormViewController alloc] init];
    CGRect test = inspectionFormVC.view.frame;
    
    Inspection *inspection = [self.inspections objectAtIndex:indexPath.row];
    inspectionFormVC.inspection = inspection;
    
    [self.navigationController pushViewController:inspectionFormVC animated:YES];
}

- (MKMapView*)mapView
{
    if(_mapView == nil)
    {
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.switchView.frame.size.width, self.switchView.frame.size.height)];
        _mapView.delegate = self;
        
        UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *locationImage = [UIImage imageNamed:@"location"];
        [locationButton setImage:locationImage forState:UIControlStateNormal];
        locationButton.frame = CGRectMake(10, _mapView.frame.size.height - 10 - locationImage.size.height, locationImage.size.width, locationImage.size.height);
        [locationButton addTarget:self action:@selector(locationTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_mapView addSubview:locationButton];
        
        for(NSUInteger i=0; i<self.inspections.count; i++)
        {
            Inspection *inspection = [self.inspections objectAtIndex:i];
//            Station *station = [self.stations objectAtIndex:i];
            MapAnnotation *anno = [[MapAnnotation alloc] init];
            anno.coordinate = CLLocationCoordinate2DMake([inspection.facility.lattitude floatValue], [inspection.facility.longitude floatValue]);
            anno.inspection = inspection;
            anno.annotationTitle = inspection.facility.storeCode;
            anno.annotationSubtitle = [NSString stringWithFormat:@"%@, %@", inspection.facility.city, inspection.facility.state];
            anno.title = @" ";
            anno.subtitle = @" ";
            [_mapView addAnnotation:anno];
        }
        
        //set the starting view of the map - slc, northern utah
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.770951,-112.13501); //slc
        _mapView.region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(2.0, 2.0));
    }
    return _mapView;
}

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id <MKAnnotation>)annotation
{
    if(annotation == self.curLocationAnnotation)
    {
        MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:@"curLocationAnnotation"];
        if(!aView)
        {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"curLocationAnnotation"];
        }
        aView.canShowCallout = NO;
        aView.annotation = annotation;
        return aView;
    }
    else
    {
        MKAnnotationView *aView = [sender dequeueReusableAnnotationViewWithIdentifier:@"mapAnnotation"];
        if(!aView)
        {
            MapAnnotationView *mapView = [[MapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"mapAnnotation"];
            mapView.image = [UIImage imageNamed:@"mappin"];
            
            MapAnnotation *mapAnnotation = (MapAnnotation *)annotation;
            mapView.inspection = mapAnnotation.inspection;
            mapView.annotationTitle = mapAnnotation.annotationTitle;
            mapView.annotationSubtitle = mapAnnotation.annotationSubtitle;
            mapView.delegate = self;
            
            aView = mapView;
        }
        
        aView.canShowCallout = NO;
        aView.annotation = annotation; 
        UIView* popupView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAP_ANNOTATION_VIEW_WIDTH, MAP_ANNOTATION_VIEW_HEIGHT)];
        aView.leftCalloutAccessoryView = popupView;
        
        return aView;
    }
}

- (void)locationTapped:(id)sender
{
    [self.locationManager startUpdatingLocation];
    
//    //?? change the center of the map to the current location
//    //?? make the span 1.0 instead of 2.0
//    //?? zoom it so that all the pins can be seen
//    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.770951,-112.13501); //slc
//    self.mapView.region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(2.0, 2.0));
}

- (MKPointAnnotation *)curLocationAnnotation
{
    if(_curLocationAnnotation == nil)
    {
        _curLocationAnnotation = [[MKPointAnnotation alloc] init];
    }
    return _curLocationAnnotation;
}

-(CLLocationManager *)locationManager
{
	if (_locationManager == nil)
	{
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
		_locationManager.distanceFilter = kCLDistanceFilterNone;
		_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	}
	return _locationManager;
}

- (void)locationManager:(CLLocationManager *)locationManager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0)
        return;
    
    if (newLocation.horizontalAccuracy <= 1000.0f)
    {
        [locationManager stopUpdatingLocation];
        
        self.curLocationAnnotation.coordinate = newLocation.coordinate;
        [self.mapView addAnnotation:self.curLocationAnnotation];
        
        double minLat = newLocation.coordinate.latitude;
        double maxLat = newLocation.coordinate.latitude;
        double minLon = newLocation.coordinate.longitude;
        double maxLon = newLocation.coordinate.longitude;
        //set the map so that every inspection can be seen
        for(Inspection *inspection in self.inspections)
        {
            if([inspection.facility.lattitude floatValue] < minLat)
                minLat = [inspection.facility.lattitude floatValue];
            if([inspection.facility.lattitude floatValue] > maxLat)
                maxLat = [inspection.facility.lattitude floatValue];
            if([inspection.facility.longitude floatValue] < minLon)
                minLon = [inspection.facility.longitude floatValue];
            if([inspection.facility.longitude floatValue] > maxLon)
                maxLon = [inspection.facility.longitude floatValue];
        }
        
        double latDelta = maxLat - minLat;
        latDelta *= 1.1;
        
        double lonDelta = maxLon - minLon;
        lonDelta *= 1.1;
        
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake((minLat+maxLat)/2.0, (minLon+maxLon)/2.0);//newLocation.coordinate;
        [self.mapView setRegion:MKCoordinateRegionMake(center, MKCoordinateSpanMake(latDelta, lonDelta)) animated:YES];
        
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorString;
    [manager stopUpdatingLocation];
    switch([error code])
    {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"Access to Location Services denied by user";
            //Do something...
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"Location data unavailable";
            //Do something else...
            break;
        default:
            errorString = @"An unknown error has occurred";
            break;
    }
    
    //?? notify the user
    NSLog(@"%@", errorString);
    
    //fall back on a default location
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(40.770951,-112.13501); //slc
    self.mapView.region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(2.0, 2.0));

}


@end
