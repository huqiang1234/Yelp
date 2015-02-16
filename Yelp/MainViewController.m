//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"

NSString * const kYelpConsumerKey = @"zT_lC2-khVLUfNZQKlcqxg";
NSString * const kYelpConsumerSecret = @"x_XYumBxIXli0__G66qr_cdxLD8";
NSString * const kYelpToken = @"8_wzY5CwP0HxC4j_UhAs7NPBC34acYlg";
NSString * const kYelpTokenSecret = @"NZh5upFzS6blDzo-05inkyL0oDU";

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;

@property (nonatomic, strong) UISearchController *searchController;

@property (nonatomic, strong) NSDictionary *searchParams;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];

      [self fetchBusinessesWithQuery:@"Restaurants" params:nil];
      [self.tableView reloadData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

  self.tableView.delegate = self;
  self.tableView.dataSource = self;

  [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];

  self.tableView.rowHeight = UITableViewAutomaticDimension;

  self.businesses = [NSMutableArray array];

  self.title = @"Yelp";

  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];

  self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
  self.searchController.searchBar.delegate = self;
  self.searchController.dimsBackgroundDuringPresentation = NO;

  [self.searchController.searchBar sizeToFit];
  self.navigationItem.titleView = self.searchController.searchBar;
  self.searchController.hidesNavigationBarDuringPresentation = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];

  if (indexPath.row == self.businesses.count - 1) {
    [self fetchBusinessesWithQueryAndOffset:@"Restaurants" params:self.searchParams offset:self.businesses.count];
  }

  cell.business = self.businesses[indexPath.row];

  return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];

  cell.business = self.businesses[indexPath.row];
  CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
  return size.height + 1;
}

#pragma mark - Filters delegate methods

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
  self.searchParams = filters;
  [self fetchBusinessesWithQuery:@"Restaurants" params:filters];
  NSLog(@"fire new network event: %@", filters);
}

#pragma mark - private methods

- (void)onFilterButton {
  FiltersViewController *vc = [[FiltersViewController alloc] init];

  vc.delegate = self;

  UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
  [self presentViewController:nvc animated:YES completion:nil];
}

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params {
  [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
    NSLog(@"response: %@", response);

    NSArray *businessDictionary = response[@"businesses"];
    self.businesses = [[Business businessesWithDictionaries:businessDictionary] mutableCopy];
    [self.tableView reloadData];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error: %@", [error description]);
  }];
}

- (void)fetchBusinessesWithQueryAndOffset:(NSString *)query params:(NSDictionary *)params offset:(NSInteger)offset {

  NSMutableDictionary *offsetParam = [NSMutableDictionary dictionary];
  if (params != nil) {
    offsetParam = [params mutableCopy];
  }

  [offsetParam setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];

  [self.client searchWithTerm:query params:offsetParam success:^(AFHTTPRequestOperation *operation, id response) {
    NSLog(@"response: %@", response);

    NSArray *businessDictionary = response[@"businesses"];
    [self.businesses addObjectsFromArray:[Business businessesWithDictionaries:businessDictionary]];
    [self.tableView reloadData];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error: %@", [error description]);
  }];
}

#pragma mark - search bar delegate methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  NSMutableDictionary *searchCategory = [NSMutableDictionary dictionary];
  [searchCategory setObject:[searchBar.text lowercaseString] forKey:@"category_filter"];

  [self fetchBusinessesWithQuery:@"Restaurants" params:searchCategory];
  [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [self.searchController.searchBar resignFirstResponder];
  self.searchController.searchBar.text = @"";
  [self fetchBusinessesWithQuery:@"Restaurants" params:nil];
  [self.tableView reloadData];
}

@end
