//
//  BaseCDTVC.h
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Shared.h"
#import "Event+Init.h"
@interface BaseCDTVC : CoreDataTableViewController

// The Model for this class.
//GIVEN a managedObjectContext (aka a database), display the table based on ...something

// Essentially specifies the database to look in to display in this table.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) Event *event;  //the active event


- (void)useDemoDocument;
- (void)setupFetchedResultsController;
-(NSFetchRequest *)getCustomRequest;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; //abstract

@end
