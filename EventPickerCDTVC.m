//
//  EventPickerCDTVC.m
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "EventPickerCDTVC.h"
#import "Event+Init.h"
#import "EventExpenseCDTVC.h"
#import "EventPeopleCDTVC.h"
@interface EventPickerCDTVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mainMenuButton;

@end

@implementation EventPickerCDTVC


// Just sets the title of the view

- (void)viewDidLoad
{
    [super viewDidLoad];
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
    self.navigationItem.title = @"Load Event";
    self.navigationItem.hidesBackButton = YES;
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}

- (IBAction)unwindToPicker:(UIStoryboardSegue *)segue {
    
}





-(UIButton *)accessoryModifyButton{
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
 //   [accessory setImage:[UIImage imageNamed:@"star.png"] forState:UIControlStateNormal];
 //   accessory.frame = CGRectMake(0, 0, 15, 15);
    accessory.userInteractionEnabled = YES;
    [accessory addTarget:self action:@selector(didTapAccessory:) forControlEvents: UIControlEventTouchUpInside];
    return accessory;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event"];
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = event.eventName;
    cell.detailTextLabel.text = @"Edit";
    // cell.accessoryView = [self accessoryModifyButton];  //disables event editing...for now
    return cell;
    
    
}

- (void)didTapAccessory:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[sender superview]];
    
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self setEventToCurrent:event withContext:self.managedObjectContext]; //set the current event to the selected event
 
    [self performSegueWithIdentifier:@"Modify Event" sender:self];
    
}

-(void)setEventToCurrent:(Event *)event withContext:(NSManagedObjectContext *)context{
    //now make all events that are "currently selected" to be unselected (there should only be 1)
    Event *current = [Shared getCurrentEvent:self.managedObjectContext];
    current.current = FALSE;  //set the attribute to false
    
    
    
    //now set the chosen event to the "current" event"
    NSNumber *boolTrue = [NSNumber numberWithBool:TRUE];  //Core data uses NSNumber for Booleans?
    event.current = boolTrue;  //set the current to be true for this event, indicating it is the currently selected event
}

// Gets the NSIndexPath of the UITableViewCell which is sender.
// Then uses that NSIndexPath to find the Event in question using NSFetchedResultsController.
// Prepares a destination view controller through the "Load Event" segue by sending that to it.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    self.navigationItem.title = @"Back"; //cheesy way to rename next view's back button
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];  //can retrieve the indexPath in the model (aka the location of the model object)
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"Load Event"]) {
            Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];  //if you have the indexPath, then can use the FRC to retrieve the object in the database
   
            [self setEventToCurrent:event withContext:self.managedObjectContext];
  
        }
    }
}


@end
