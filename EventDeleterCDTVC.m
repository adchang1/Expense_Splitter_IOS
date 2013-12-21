//
//  EventDeleterCDTVC.m
//  IOU
//
//  Created by Allen Chang on 3/3/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "EventDeleterCDTVC.h"
#import "Event+Init.h"
#import "Shared.h"
@interface EventDeleterCDTVC ()

@end

@implementation EventDeleterCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Delete Event"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}
//delete an event if you select its cell
- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{

    
    if (indexPath) {
       
        Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];  //if you have the indexPath, then can use the FRC to retrieve the object in the database
        [self.managedObjectContext deleteObject:event];  //this should cascade and also delete all associated expenses, transactions, and people
               
     //force save after deletion so that we can immediately update
        [Shared forceSaveDocument];
  
        
    }
}

@end
