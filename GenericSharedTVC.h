//
//  GenericSharedTVC.h
//  IOU
//
//  Created by Allen Chang on 3/9/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shared.h"
#import "Event+Init.h"

@interface GenericSharedTVC : UITableViewController

// Essentially specifies the database to look in to display in this table.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) Event *event;  //the active event

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; //abstract
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;  //abstract

@end
