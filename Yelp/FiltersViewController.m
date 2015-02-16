//
//  FiltersViewController.m
//  Yelp
//
//  Created by Charlie Hu on 2/14/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"
#import "RadioButtonCell.h"
#import "MoreContentCell.h"

typedef NS_ENUM(NSInteger, SectionType) {
  SectionTypePopular = 0,
  SectionTypeDistance,
  SectionTypeSort,
  SectionTypeCategory
};

@interface FiltersViewController () <UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate, RadioButtonCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *sections;

@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, assign) NSInteger numberOfCategoriesToShow;
@property (nonatomic, assign) BOOL showAllCategories;

@property (nonatomic, strong) NSArray *distanceOptions;
@property (nonatomic, assign) NSInteger indexSelectedDistance;
@property (nonatomic, assign) BOOL showAllDistanceOptions;

@property (nonatomic, strong) NSArray *sortOptions;
@property (nonatomic, assign) NSInteger indexSelectedSortOption;
@property (nonatomic, assign) BOOL showAllSortOptions;

@property (nonatomic, strong) NSArray *popularOptions;
@property (nonatomic, strong) NSMutableSet *selectedPopularOptions;

- (void)initCategories;
- (void)initSections;
- (void)initDistanceOptions;
- (void)initSortOptions;
- (void)initPopularOptions;
- (NSDictionary *)filters;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  if (self) {
    self.selectedCategories = [NSMutableSet set];
    [self initCategories];
    [self initSections];
    [self initDistanceOptions];
    [self initSortOptions];
    [self initPopularOptions];
    self.showAllDistanceOptions = NO;
    self.showAllSortOptions = NO;
    self.numberOfCategoriesToShow = 3;
    self.showAllCategories = NO;
  }

  return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

  self.tableView.delegate = self;
  self.tableView.dataSource = self;

  [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"RadioButtonCell" bundle:nil] forCellReuseIdentifier:@"RadioButtonCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"MoreContentCell" bundle:nil] forCellReuseIdentifier:@"MoreContentCell"];

  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 45.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case SectionTypePopular:
      return self.popularOptions.count;
    case SectionTypeDistance:
      if (self.showAllDistanceOptions) {
        return self.distanceOptions.count;
      } else {
        return 1;
      }
    case SectionTypeSort:
      if (self.showAllSortOptions) {
        return self.sortOptions.count;
      } else {
        return 1;
      }
    case SectionTypeCategory:
      if (self.showAllCategories) {
        return self.categories.count + 1;
      } else {
        return self.numberOfCategoriesToShow + 1;
      }

    default:
      return 0;
  }
}

-(UIView *) tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section
{
  UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 34)];
  l.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
  l.text= self.sections[section];
  return l;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  SwitchCell *switchCell;
  RadioButtonCell *radioButtonCell;
  MoreContentCell *moreContentCell;

  switch (indexPath.section) {
    case SectionTypePopular:
      switchCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
      switchCell.titleLabel.text = self.popularOptions[indexPath.row][@"name"];
      switchCell.on = [self.selectedPopularOptions containsObject:self.popularOptions[indexPath.row]];
      switchCell.delegate = self;
      cell = switchCell;
      break;
    case SectionTypeDistance:
      radioButtonCell = [tableView dequeueReusableCellWithIdentifier:@"RadioButtonCell"];
      if (self.showAllDistanceOptions) {
        radioButtonCell.radioButtonTitle.text = self.distanceOptions[indexPath.row][@"name"];
        if (indexPath.row == self.indexSelectedDistance) {
          [radioButtonCell setCheckBoxChecked:YES];
        } else {
          [radioButtonCell setCheckBoxChecked:NO];
        }
      } else {
        radioButtonCell.radioButtonTitle.text = self.distanceOptions[self.indexSelectedDistance][@"name"];
        [radioButtonCell.radioButton setImage:[UIImage imageNamed:@"down-24.png"] forState:UIControlStateNormal];
      }
      radioButtonCell.delegate = self;
      cell = radioButtonCell;
      break;
    case SectionTypeSort:
      radioButtonCell = [tableView dequeueReusableCellWithIdentifier:@"RadioButtonCell"];
      if (self.showAllSortOptions) {
        radioButtonCell.radioButtonTitle.text = self.sortOptions[indexPath.row][@"name"];
        if (indexPath.row == self.indexSelectedSortOption) {
          [radioButtonCell setCheckBoxChecked:YES];
        } else {
          [radioButtonCell setCheckBoxChecked:NO];
        }
      } else {
        radioButtonCell.radioButtonTitle.text = self.sortOptions[self.indexSelectedSortOption][@"name"];
        [radioButtonCell.radioButton setImage:[UIImage imageNamed:@"down-24.png"] forState:UIControlStateNormal];
      }
      radioButtonCell.delegate = self;
      cell = radioButtonCell;
      break;
    case SectionTypeCategory:
      if (self.showAllCategories == NO) {
        if (indexPath.row == self.numberOfCategoriesToShow) {
          moreContentCell = [self.tableView  dequeueReusableCellWithIdentifier:@"MoreContentCell"];
          moreContentCell.titleLabel.text = @"See All";
          cell = moreContentCell;
        } else {
          switchCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
          switchCell.titleLabel.text = self.categories[indexPath.row][@"name"];
          switchCell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
          switchCell.delegate = self;
          cell = switchCell;
        }
      } else {
          if (indexPath.row < self.categories.count) {
            switchCell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            switchCell.titleLabel.text = self.categories[indexPath.row][@"name"];
            switchCell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
            switchCell.delegate = self;
            cell = switchCell;
          } else {
            moreContentCell = [self.tableView  dequeueReusableCellWithIdentifier:@"MoreContentCell"];
            moreContentCell.titleLabel.text = @"See Less";
            cell = moreContentCell;
          }
      }
      break;

    default:
      break;
  }

  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  switch (indexPath.section) {
    case SectionTypeSort:
      self.showAllSortOptions = YES;
      [self.tableView reloadData];
      break;
    case SectionTypeDistance:
      self.showAllDistanceOptions = YES;
      [self.tableView reloadData];
      break;
    case SectionTypeCategory:
      if ((self.showAllCategories == NO) && (indexPath.row == self.numberOfCategoriesToShow)) {
        self.showAllCategories = YES;
        [self.tableView reloadData];
      }

      if ((self.showAllCategories == YES) && (indexPath.row == self.categories.count)) {
        self.showAllCategories = NO;
        [self.tableView reloadData];
      }
    default:
      break;
  }
}

#pragma mark - Switch cell delegate

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
  NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

  if (value) {
    [self.selectedCategories addObject:self.categories[indexPath.row]];
  } else {
    [self.selectedCategories removeObject:self.categories[indexPath.row]];
  }
}

#pragma mark - Radio button delegate methods

- (void)radioButtonCell:(RadioButtonCell *)cell didUpdateValue:(BOOL)value {
  NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

  if (value) {
    switch (indexPath.section) {
      case SectionTypeDistance:
        NSLog(@"distance selected");
        self.indexSelectedDistance = indexPath.row;
        self.showAllDistanceOptions = NO;
        [self.tableView reloadData];
        break;
      case SectionTypeSort:
        NSLog(@"Sort by selected");
        self.indexSelectedSortOption = indexPath.row;
        self.showAllSortOptions = NO;
        [self.tableView reloadData];
        break;

      default:
        break;
    }
  }
}

#pragma mark - Private methods

- (NSDictionary *)filters {
  NSMutableDictionary *filters = [NSMutableDictionary dictionary];

  if (self.selectedCategories.count > 0) {
    NSMutableArray *names = [NSMutableArray array];
    for (NSDictionary *category in self.selectedCategories) {
      [names addObject:category[@"code"]];
    }
    NSString *categoryFilter = [names componentsJoinedByString:@","];
    [filters setObject:categoryFilter forKey:@"category_filter"];
  }

  if (self.selectedPopularOptions.count > 0) {
    [filters setObject:@(YES) forKey:@"deals_filter"];
  }

  if (self.indexSelectedDistance > 0) {
    [filters setObject:@([self.distanceOptions[self.indexSelectedDistance][@"value"] integerValue]) forKey:@"radius_filter"];
  }

  if (self.indexSelectedSortOption > 0) {
    [filters setObject:@([self.sortOptions[self.indexSelectedSortOption][@"value"] integerValue]) forKey:@"sort"];
  }

  return filters;
}

- (void)onCancelButton {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
  [self.delegate filtersViewController:self didChangeFilters:self.filters];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initCategories {
  self.categories =
  @[
    @{@"name" : @"Afghan", @"code": @"afghani" },
    @{@"name" : @"African", @"code": @"african" },
    @{@"name" : @"American, New", @"code": @"newamerican" },
    @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
    @{@"name" : @"Arabian", @"code": @"arabian" },
    @{@"name" : @"Argentine", @"code": @"argentine" },
    @{@"name" : @"Armenian", @"code": @"armenian" },
    @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
    @{@"name" : @"Asturian", @"code": @"asturian" },
    @{@"name" : @"Australian", @"code": @"australian" },
    @{@"name" : @"Austrian", @"code": @"austrian" },
    @{@"name" : @"Baguettes", @"code": @"baguettes" },
    @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
    @{@"name" : @"Barbeque", @"code": @"bbq" },
    @{@"name" : @"Basque", @"code": @"basque" },
    @{@"name" : @"Bavarian", @"code": @"bavarian" },
    @{@"name" : @"Beer Garden", @"code": @"beergarden" },
    @{@"name" : @"Beer Hall", @"code": @"beerhall" },
    @{@"name" : @"Beisl", @"code": @"beisl" },
    @{@"name" : @"Belgian", @"code": @"belgian" },
    @{@"name" : @"Bistros", @"code": @"bistros" },
    @{@"name" : @"Black Sea", @"code": @"blacksea" },
    @{@"name" : @"Brasseries", @"code": @"brasseries" },
    @{@"name" : @"Brazilian", @"code": @"brazilian" },
    @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
    @{@"name" : @"British", @"code": @"british" },
    @{@"name" : @"Buffets", @"code": @"buffets" },
    @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
    @{@"name" : @"Burgers", @"code": @"burgers" },
    @{@"name" : @"Burmese", @"code": @"burmese" },
    @{@"name" : @"Cafes", @"code": @"cafes" },
    @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
    @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
    @{@"name" : @"Cambodian", @"code": @"cambodian" },
    @{@"name" : @"Canadian", @"code": @"New)" },
    @{@"name" : @"Canteen", @"code": @"canteen" },
    @{@"name" : @"Caribbean", @"code": @"caribbean" },
    @{@"name" : @"Catalan", @"code": @"catalan" },
    @{@"name" : @"Chech", @"code": @"chech" },
    @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
    @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
    @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
    @{@"name" : @"Chilean", @"code": @"chilean" },
    @{@"name" : @"Chinese", @"code": @"chinese" },
    @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
    @{@"name" : @"Corsican", @"code": @"corsican" },
    @{@"name" : @"Creperies", @"code": @"creperies" },
    @{@"name" : @"Cuban", @"code": @"cuban" },
    @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
    @{@"name" : @"Cypriot", @"code": @"cypriot" },
    @{@"name" : @"Czech", @"code": @"czech" },
    @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
    @{@"name" : @"Danish", @"code": @"danish" },
    @{@"name" : @"Delis", @"code": @"delis" },
    @{@"name" : @"Diners", @"code": @"diners" },
    @{@"name" : @"Dumplings", @"code": @"dumplings" },
    @{@"name" : @"Eastern European", @"code": @"eastern_european" },
    @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
    @{@"name" : @"Fast Food", @"code": @"hotdogs" },
    @{@"name" : @"Filipino", @"code": @"filipino" },
    @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
    @{@"name" : @"Fondue", @"code": @"fondue" },
    @{@"name" : @"Food Court", @"code": @"food_court" },
    @{@"name" : @"Food Stands", @"code": @"foodstands" },
    @{@"name" : @"French", @"code": @"french" },
    @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
    @{@"name" : @"Galician", @"code": @"galician" },
    @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
    @{@"name" : @"Georgian", @"code": @"georgian" },
    @{@"name" : @"German", @"code": @"german" },
    @{@"name" : @"Giblets", @"code": @"giblets" },
    @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
    @{@"name" : @"Greek", @"code": @"greek" },
    @{@"name" : @"Halal", @"code": @"halal" },
    @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
    @{@"name" : @"Heuriger", @"code": @"heuriger" },
    @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
    @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
    @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
    @{@"name" : @"Hot Pot", @"code": @"hotpot" },
    @{@"name" : @"Hungarian", @"code": @"hungarian" },
    @{@"name" : @"Iberian", @"code": @"iberian" },
    @{@"name" : @"Indian", @"code": @"indpak" },
    @{@"name" : @"Indonesian", @"code": @"indonesian" },
    @{@"name" : @"International", @"code": @"international" },
    @{@"name" : @"Irish", @"code": @"irish" },
    @{@"name" : @"Island Pub", @"code": @"island_pub" },
    @{@"name" : @"Israeli", @"code": @"israeli" },
    @{@"name" : @"Italian", @"code": @"italian" },
    @{@"name" : @"Japanese", @"code": @"japanese" },
    @{@"name" : @"Jewish", @"code": @"jewish" },
    @{@"name" : @"Kebab", @"code": @"kebab" },
    @{@"name" : @"Korean", @"code": @"korean" },
    @{@"name" : @"Kosher", @"code": @"kosher" },
    @{@"name" : @"Kurdish", @"code": @"kurdish" },
    @{@"name" : @"Laos", @"code": @"laos" },
    @{@"name" : @"Laotian", @"code": @"laotian" },
    @{@"name" : @"Latin American", @"code": @"latin" },
    @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
    @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
    @{@"name" : @"Malaysian", @"code": @"malaysian" },
    @{@"name" : @"Meatballs", @"code": @"meatballs" },
    @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
    @{@"name" : @"Mexican", @"code": @"mexican" },
    @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
    @{@"name" : @"Milk Bars", @"code": @"milkbars" },
    @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
    @{@"name" : @"Modern European", @"code": @"modern_european" },
    @{@"name" : @"Mongolian", @"code": @"mongolian" },
    @{@"name" : @"Moroccan", @"code": @"moroccan" },
    @{@"name" : @"New Zealand", @"code": @"newzealand" },
    @{@"name" : @"Night Food", @"code": @"nightfood" },
    @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
    @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
    @{@"name" : @"Oriental", @"code": @"oriental" },
    @{@"name" : @"Pakistani", @"code": @"pakistani" },
    @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
    @{@"name" : @"Parma", @"code": @"parma" },
    @{@"name" : @"Persian/Iranian", @"code": @"persian" },
    @{@"name" : @"Peruvian", @"code": @"peruvian" },
    @{@"name" : @"Pita", @"code": @"pita" },
    @{@"name" : @"Pizza", @"code": @"pizza" },
    @{@"name" : @"Polish", @"code": @"polish" },
    @{@"name" : @"Portuguese", @"code": @"portuguese" },
    @{@"name" : @"Potatoes", @"code": @"potatoes" },
    @{@"name" : @"Poutineries", @"code": @"poutineries" },
    @{@"name" : @"Pub Food", @"code": @"pubfood" },
    @{@"name" : @"Rice", @"code": @"riceshop" },
    @{@"name" : @"Romanian", @"code": @"romanian" },
    @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
    @{@"name" : @"Rumanian", @"code": @"rumanian" },
    @{@"name" : @"Russian", @"code": @"russian" },
    @{@"name" : @"Salad", @"code": @"salad" },
    @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
    @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
    @{@"name" : @"Scottish", @"code": @"scottish" },
    @{@"name" : @"Seafood", @"code": @"seafood" },
    @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
    @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
    @{@"name" : @"Singaporean", @"code": @"singaporean" },
    @{@"name" : @"Slovakian", @"code": @"slovakian" },
    @{@"name" : @"Soul Food", @"code": @"soulfood" },
    @{@"name" : @"Soup", @"code": @"soup" },
    @{@"name" : @"Southern", @"code": @"southern" },
    @{@"name" : @"Spanish", @"code": @"spanish" },
    @{@"name" : @"Steakhouses", @"code": @"steak" },
    @{@"name" : @"Sushi Bars", @"code": @"sushi" },
    @{@"name" : @"Swabian", @"code": @"swabian" },
    @{@"name" : @"Swedish", @"code": @"swedish" },
    @{@"name" : @"Swiss Food", @"code": @"swissfood" },
    @{@"name" : @"Tabernas", @"code": @"tabernas" },
    @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
    @{@"name" : @"Tapas Bars", @"code": @"tapas" },
    @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
    @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
    @{@"name" : @"Thai", @"code": @"thai" },
    @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
    @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
    @{@"name" : @"Trattorie", @"code": @"trattorie" },
    @{@"name" : @"Turkish", @"code": @"turkish" },
    @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
    @{@"name" : @"Uzbek", @"code": @"uzbek" },
    @{@"name" : @"Vegan", @"code": @"vegan" },
    @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
    @{@"name" : @"Venison", @"code": @"venison" },
    @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
    @{@"name" : @"Wok", @"code": @"wok" },
    @{@"name" : @"Wraps", @"code": @"wraps" },
    @{@"name" : @"Yugoslav", @"code": @"yugoslav" }
    ];
}

- (void)initSections {
  self.sections = @[
                    @"Most Popular",
                    @"Distance",
                    @"Sort By",
                    @"Category"
                    ];
}

- (void)initDistanceOptions {
  self.distanceOptions = @[
                           @{@"name" : @"Best Match", @"value": @(0)},
                           @{@"name" : @"0.3 miles", @"value": @(483)},
                           @{@"name" : @"1 miles", @"value": @(1609)},
                           @{@"name" : @"5 miles", @"value": @(8047)},
                           @{@"name" : @"20 miles", @"value": @(32187)}
                           ];
}

- (void)initSortOptions {
  self.sortOptions = @[
                       @{@"name" : @"Best Match", @"value": @(0)},
                       @{@"name" : @"Distance", @"value": @(1)},
                       @{@"name" : @"Rating", @"value": @(2)}
                       ];
}

- (void)initPopularOptions {
  self.popularOptions = @[
                          @{@"name" : @"Offering a Deal"}
                          ];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
