//
//  LLViewController.m
//  CoreData
//
//  Created by Lauren Lee on 5/7/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import "LLViewController.h"
#import "LLAppDelegate.h"
#import "LLArtistViewController.h"
#import "LLAppDelegate+CoreDataContext.h"
#import "Label.h"

@interface LLViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) NSManagedObjectContext *objectContext;
@property (strong, nonatomic) NSArray *labels;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *resultsController;

@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LLAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [appDelegate createManagedObjectContext:^(NSManagedObjectContext *context) {
        self.objectContext = context;
    }];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
//    [self seedCoreData:nil];
//    [self fetchResults:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)seedCoreData:(id)sender {
    
    Label *rapLabel = [NSEntityDescription insertNewObjectForEntityForName:@"Label"
                                                    inManagedObjectContext:self.objectContext];
    rapLabel.name = @"Bros 4 Lyfe";
    
    Label *countryLabel = [NSEntityDescription insertNewObjectForEntityForName:@"Label"
                                                       inManagedObjectContext:self.objectContext];
    countryLabel.name = @"Pickup Trucks";
    
    Label *popLabel = [NSEntityDescription insertNewObjectForEntityForName:@"Label"
                                                    inManagedObjectContext:self.objectContext];
    popLabel.name = @"Lollipopcorn";
    
    NSError *error;
    [self.objectContext save:&error];
    
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }
}

- (IBAction)fetchResults:(id)sender {
    
    NSError *error;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Label"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.objectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self.resultsController performFetch:&error];
    
    self.resultsController.delegate = self;
    
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", @"Lollipopcorn"];
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"any artists.genre = %@", @"pop"];
//    self.labels = [self.objectContext executeFetchRquest:fetchRequest error:&error];
    
    [self.tableView reloadData];
}

- (IBAction)addLabel:(id)sender {
    Label *newLabel = [NSEntityDescription insertNewObjectForEntityForName:@"Label" inManagedObjectContext:self.objectContext];
    newLabel.name = @"New Label";
}


#pragma  mark - Table View Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LabelCell"];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.resultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.resultsController sections][section];
    
    return [sectionInfo numberOfObjects];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showLabelSegue"]) {
        LLArtistViewController *destination = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        destination.selectedLabel = self.labels[indexPath.row];
    }
}

- (IBAction)deleteObjects:(id)sender {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Label"];
    
//    NSString *name = @"Pickup Trucks";
    
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    
    
    NSError *error;
    NSArray *objects = [self.objectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *object in objects) {
        [self.objectContext deleteObject:object];
    }
    
    [self fetchResults:sender];
}


-(void)deleteAllObjectsFrom:(NSString*)entity
                  inContext:(NSManagedObjectContext*)context {
    
    NSFetchRequest *request;
    request = [NSFetchRequest fetchRequestWithEntityName:entity];
    request.entity = [NSEntityDescription entityForName:entity
                                 inManagedObjectContext:context];
    
    NSError *error = nil;
    NSArray *entityObjects = [context executeFetchRequest:request
                                                    error:&error];
    
    for (NSManagedObject *object in entityObjects) {
        [context deleteObject:object];
        NSLog(@"\n\nDeleted: \n\n%@.", object);
    }
}

/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void) configureCell:(UITableViewCell *)cell
        atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.resultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object valueForKey:@"name"];
    
}


@end
