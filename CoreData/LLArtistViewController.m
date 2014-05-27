//
//  LLArtistViewController.m
//  CoreData
//
//  Created by Lauren Lee on 5/7/14.
//  Copyright (c) 2014 Lauren Lee. All rights reserved.
//

#import "LLArtistViewController.h"
#import "Artist.h"

@interface LLArtistViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *genreField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *artists;

@end

@implementation LLArtistViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.firstNameField.delegate = self;
    self.lastNameField.delegate = self;
    self.genreField.delegate = self;
    
    self.artists = [self.selectedLabel.artists allObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveButtonPressed:(id)sender {
    
    Artist *newArtist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.selectedLabel.managedObjectContext];
    newArtist.firstName = self.firstNameField.text;
    newArtist.lastName = self.lastNameField.text;
    newArtist.genre = self.genreField.text;
    newArtist.label = self.selectedLabel;
    
    NSError *error;
    [self.selectedLabel.managedObjectContext save:&error];
    
    self.artists = [self.selectedLabel.artists allObjects];
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ArtistCell"];
    Artist *artist = self.artists[indexPath.row];
    cell.textLabel.text = artist.firstName;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.artists.count;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

@end
