//
//  UpcomingInspectionsViewController.m
//  FuelOperator
//
//  Created by Gary Robinson on 2/26/13.
//  Copyright (c) 2013 GaryRobinson. All rights reserved.
//

#import "UpcomingInspectionsViewController.h"
#import "UpcomingInspectionsCellView.h"
#import "InspectionsListViewController.h"
#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define UPCOMING_INSPECTIONS_CELL_VIEW_TAG 2
#define HEADER_HEIGHT 25

@interface UpcomingInspectionsViewController ()

@property (nonatomic, strong) UIButton *settingsBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) BOOL settingsOpen;
@property (nonatomic) BOOL firstAppear;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end

@implementation UpcomingInspectionsViewController

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.settingsBtn];
    self.navigationItem.titleView = self.titleLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.settingsOpen = NO;
    self.firstAppear = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inspectionsUpdated:) name:@"inspectionsUpdated" object:nil];
    
    [[OnlineService sharedService] updateInspections];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews
{
    self.tableView.frame = self.view.bounds;
}

- (void)inspectionsUpdated:(id)sender
{
    self.startDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"startDate"];
    self.endDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"endDate"];
    [self.tableView reloadData];
}

- (UIButton*)settingsBtn
{
    if(_settingsBtn == nil)
    {
        _settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"btn-settings"];
        _settingsBtn.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [_settingsBtn setImage:image forState:UIControlStateNormal];
        [_settingsBtn addTarget:self action:@selector(toggleLeftView:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingsBtn;
}

- (void)toggleLeftView:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate*)([[UIApplication sharedApplication] delegate]);
    [appDelegate.rootViewController toggleOpen];
}

- (UILabel *)titleLabel
{
    if(_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = @"Upcoming Inspections";
        _titleLabel.font = [UIFont boldFontOfSize:18];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_titleLabel sizeToFit];
        _titleLabel.center = CGPointMake(self.view.bounds.size.width/2.0, 20);
    }
    return _titleLabel;
}

- (UITableView *)tableView
{
    if(_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor fopWhiteColor];
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfWeeks = [self.endDate timeIntervalSinceDate:self.startDate]/[NSDate secondsPerDay]/7;
    return numberOfWeeks;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = CGRectMake(0, 0, tableView.bounds.size.width, HEADER_HEIGHT);
    UIView *headerView = [[UIView alloc] initWithFrame:rect];
    headerView.backgroundColor = [UIColor fopOrangeColor];
    
    rect.origin.x = 5;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:rect];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldFontOfSize:18];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.numberOfLines = 1;
    
    //based off the current date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    
    NSDate *startOfWeek = [self.startDate dateByAddingTimeInterval:[NSDate secondsPerDay] * 7.0 * section];
    NSDate *endOfWeek = [self.startDate dateByAddingTimeInterval:[NSDate secondsPerDay] * (6.0 + 7.0 * section)];
    headerLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:startOfWeek], [formatter stringFromDate:endOfWeek]];
    
    [headerLabel sizeToFit];
    headerLabel.frame = CGRectMake(5, 6, tableView.bounds.size.width - 5, headerLabel.frame.size.height);
    
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UPCOMING_INSPECTIONS_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"upcomingInspectionCell";
    
    UpcomingInspectionsCellView *cellView = nil;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        
        cellView = [[UpcomingInspectionsCellView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.width)];
        cellView.tag = UPCOMING_INSPECTIONS_CELL_VIEW_TAG;
        [cell.contentView addSubview:cellView];
    }
    else
    {
        cellView = (UpcomingInspectionsCellView *)[cell.contentView viewWithTag:UPCOMING_INSPECTIONS_CELL_VIEW_TAG];
    }
    
    NSString *dayTitle;
    if(indexPath.row == 0)
        dayTitle = @"Sunday";
    else if(indexPath.row == 1)
        dayTitle = @"Monday";
    else if(indexPath.row == 2)
        dayTitle = @"Tuesday";
    else if(indexPath.row == 3)
        dayTitle = @"Wednesday";
    else if(indexPath.row == 4)
        dayTitle = @"Thursday";
    else if(indexPath.row == 5)
        dayTitle = @"Friday";
    else
        dayTitle = @"Saturday";
    
    [cellView setDayTitle:dayTitle withNumInspections:[self numInspectionsWithIndexPath:indexPath]];
    
    return cell;
}

- (NSInteger)numInspectionsWithIndexPath:(NSIndexPath *)indexPath
{
    NSDate *startDate = [NSDate dateWithNumberOfDays:(indexPath.row + 7 * indexPath.section) sinceDate:self.startDate];
    NSDate *endDate = [NSDate dateWithNumberOfDays:1 sinceDate:startDate];
    NSArray *inspections = [Inspection MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(user.login = %@) AND (date >= %@) AND (date < %@)", [User loggedInUser].login, startDate, endDate]];
    return inspections.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    InspectionsListViewController *inspectionsListVC = [[InspectionsListViewController alloc] init];
    NSDate *dateSelected = [NSDate dateWithNumberOfDays:(indexPath.row + 7 * indexPath.section) sinceDate:self.startDate];
    inspectionsListVC.date = dateSelected;
    [self.navigationController pushViewController:inspectionsListVC animated:YES];
}






@end
