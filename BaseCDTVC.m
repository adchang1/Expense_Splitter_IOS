//
//  BaseCDTVC.m
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "BaseCDTVC.h"

@interface BaseCDTVC () 

@end

@implementation BaseCDTVC





- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.managedObjectContext){
        [self useDemoDocument];  //also runs setupFetchedResultsController inside this since it runs the custom setManagedObjectContext method
        
    }
    else{
        [self setupFetchedResultsController];
    }
    self.event = [Shared getCurrentEvent:self.managedObjectContext];
    
}

-(void)setEvent:(Event *)event{
    _event = event;
    [self setupFetchedResultsController];  //now that the event has been set, load up relevant info
}

-(NSFetchRequest *)getCustomRequest{
    return nil; //abstract getter
}

// The Model for this class.
//  Special setter that also does some prep code
// When it gets set, we create an NSFetchRequest to get all Tags in the database associated with it.
// Then we hook that NSFetchRequest up to the table view using an NSFetchedResultsController.

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    [self setupFetchedResultsController];
    
}


//Gets a static document that is shared amongst the view controllers, and sets the context. Need this to maintain continuity between the different views.
- (void)useDemoDocument
{
    
    UIManagedDocument *document = [Shared sharedDoc];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[Shared sharedURL] path]]) {
        [document saveToURL:[Shared sharedURL]
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
    
}

// Uses NSFetchRequest for objects sorted in some manner specified by the subclass.
// Build and set our NSFetchedResultsController property inherited from CoreDataTableViewController.

- (void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self getCustomRequest] managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];    
        
    } else {
        self.fetchedResultsController = nil;
    }

}



//required method for all TableViewControllers....cell setup!
// Uses NSFetchedResultsController's objectAtIndexPath: to find the Tag for this row in the table.
// Then uses that Tag to set the cell up.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;  //abstract
}





@end
