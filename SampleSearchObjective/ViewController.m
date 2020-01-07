//
//  ViewController.m
//  customSimpeTable
//
//  Created by v-20 on 7/3/17.
//  Copyright © 2017 VividInfotech. All rights reserved.
//

#import "ViewController.h"
#import "customTableViewCell.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
# import "Place.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UISearchBarDelegate, UISearchResultsUpdating,UIViewControllerPreviewingDelegate>
{
    NSArray *allparts;
    NSMutableArray *allTitle;
    NSMutableArray *allBody;
    
    
    
}

@property (strong, nonatomic) NSArray *filteredList;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

typedef NS_ENUM(NSInteger, UYLWorldFactsSearchScope)
{
    searchScopeCountry = 0
    
};
@end

@implementation ViewController
@synthesize tableList;
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.tableLoadView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"customcellobject"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
self.searchController.view = false;
    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Place")];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
   self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    
    self.tableList.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    
    [self.searchController.searchBar sizeToFit];
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
        (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable))
    {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    
    
    //    NSURL *url = [NSURL URLWithString:@"http://jsonplaceholder.typicode.com/posts"];
    //    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    //    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //
    //    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse* response, NSData* data, NSError *error)
    //     {
    //         NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    //         NSLog(@"the datata%@",dictionary);
    //     }];
    
    
    
    
    allTitle =[[NSMutableArray alloc ]init];
    allBody =[[NSMutableArray alloc ]init];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"http://jsonplaceholder.typicode.com/posts"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"the datata%@", json);
        
        allparts = [[NSArray alloc]initWithArray:json];
        [self getData:allparts];
        [self.tableList reloadData];
        NSLog(@"the dataxxxxxxxxta%lu", (unsigned long)allparts.count);
    }];
    
    [dataTask resume];
    
    
}

- (NSFetchRequest *)searchFetchRequest
{
    if (_searchFetchRequest != nil)
    {
        return _searchFetchRequest;
    }
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    _searchFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
    [_searchFetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"titleplace" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [_searchFetchRequest setSortDescriptors:sortDescriptors];
    
    return _searchFetchRequest;
}



- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
           NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    
    if (context)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"titleplace" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:@"Place"];
        frc.delegate = self;
        self.fetchedResultsController = frc;
        
        NSError *error = nil;
        if (![self.fetchedResultsController performFetch:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    return _fetchedResultsController;
}
- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableList reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return [self.filteredList count];
    }
    else
    {
        return [allparts count];
    }

    
}



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableList reloadData];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"customcellobject";
    customTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Place *country = nil;
    if (self.searchController.active)
    {
        country = [self.filteredList objectAtIndex:indexPath.row];
    }
    else
    {
        country = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    cell.lblTitle.text = country.titleplace;
    cell.lblBody.text = country.bobyplace;
    
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.searchFetchRequest = nil;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self updateSearchResultsForSearchController:self.searchController];
}

//- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
//{
//    
//}

#pragma mark -
#pragma mark === UISearchResultsUpdating ===
#pragma mark -

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableList reloadData];
}


- (void)searchForText:(NSString *)searchText scope:(UYLWorldFactsSearchScope)scopeOption
{
    NSManagedObjectContext *context2 = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    if (context2)
    {
        NSString *predicateFormat = @"%K BEGINSWITH[cd] %@";
        NSString *searchAttribute = @"titleplace";
        
        if (scopeOption == searchScopeCountry)
        {
            searchAttribute = @"titleplace";
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat, searchAttribute, searchText];
        [self.searchFetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        
        

        self.filteredList = [context2 executeFetchRequest:self.searchFetchRequest error:&error];
        if (error)
        {
            NSLog(@"searchFetchRequest failed: %@",[error localizedDescription]);
        }
    }
}


- (Place *)countryForIndexPath:(NSIndexPath *)indexPath {
    
    Place *country = nil;
    if (indexPath) {
        if (self.searchController.isActive) {
            country = [self.filteredList objectAtIndex:indexPath.row];
        } else {
            country = [self.fetchedResultsController objectAtIndexPath:indexPath];
        }
    }
    return country;
}


-(void)getData:(NSArray *) ary
{
    for (int i=0; i<ary.count; i++) {
        

        NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
        
        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];

        [newDevice setValue:[[ary objectAtIndex:i] valueForKey:@"title"] forKey:@"titleplace"];

        [newDevice setValue:[[ary objectAtIndex:i] valueForKey:@"body"] forKey:@"bobyplace"];
        
       
        
//        NSError *error = nil;
//        // Save the object to persistent store
//        if (![context save:&error]) {
//            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//        }

    }
     [self.tableList reloadData];
}
@end
