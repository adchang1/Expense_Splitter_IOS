//
//  EventExpenseCDTVC.m
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "EventExpenseCDTVC.h"
#define ACCESSORY_HEIGHT 40
#define ACCESSORY_WIDTH 40
@interface EventExpenseCDTVC ()
@property (nonatomic) NSIndexPath *passedIndexPath;

@end

@implementation EventExpenseCDTVC


- (IBAction)unwindFromExpense:(UIStoryboardSegue *)segue {
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated]; 
    self.title = @"Expenses"; // TabBarItem.title at the bottom inherits the viewController's self.title
    self.navigationItem.title = @"Expenses";  //this is the top bar title
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonPressed)];
    UIBarButtonItem *eventsButton = [[UIBarButtonItem alloc] initWithTitle:@"Events" style:UIBarButtonItemStylePlain target:self action:@selector(eventsButtonPressed)];
    self.navigationItem.leftBarButtonItem=eventsButton;
    self.navigationItem.rightBarButtonItem=addButton;
    
    [self setupFetchedResultsController];

}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.tableView reloadData];  //if rotation occurs, need to refresh cells to place second button correctly
}

//get any expense objects that are associated with this event
-(NSFetchRequest *)getCustomRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Expense"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"expenseName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"event = %@", self.event];
    return request;
}


-(UIButton *)accessoryModifyButton{
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [accessory setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    accessory.frame = CGRectMake(0, 0, ACCESSORY_HEIGHT, ACCESSORY_WIDTH);
    accessory.userInteractionEnabled = YES;
    
    [accessory addTarget:self action:@selector(didTapAccessory:) forControlEvents: UIControlEventTouchUpInside];
    return accessory;
}

-(UIButton *)secondAccessoryForIndexPath:(NSIndexPath *)indexPath{
    
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeCustom];
    [accessory setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];    
    accessory.userInteractionEnabled = YES;
    
    CGRect cellRect = [self.tableView rectForRowAtIndexPath:indexPath]; //get cell dimensions for a row at given indexpath
    int height = cellRect.size.height;
    int width = cellRect.size.width;
    int verticalButtonPosition = height/2-ACCESSORY_HEIGHT/2;
    int horizonalButtonPosition= width - 80;
    accessory.frame = CGRectMake(horizonalButtonPosition, verticalButtonPosition, ACCESSORY_HEIGHT, ACCESSORY_WIDTH);

    [accessory addTarget:self action:@selector(didTapDelete:) forControlEvents: UIControlEventTouchUpInside];
    return accessory;
}


- (void)didTapAccessory:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[sender superview]];
    self.passedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"Modify Expense" sender:self];
    
}

- (void)didTapDelete:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[sender superview]];
    Expense *expense = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.managedObjectContext deleteObject:expense];  //delete the expense
    [self.tableView reloadData];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Expense"];
    Expense *expense = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = expense.expenseName;
    cell.accessoryView = [self accessoryModifyButton];
    
    
    for(UIView *buttonView in cell.subviews){  //take out the second button every time, because its position might need to be recalculated
        if([buttonView isKindOfClass:[UIButton class]]){  //find the second button in the subviews array
            [buttonView removeFromSuperview];  //remove the second button and 
        }
        
    }
    
    [cell addSubview:[self secondAccessoryForIndexPath:indexPath]];  //re-place the button in its correct location depending on current dimensions of cell
    
    return cell;
  
}



// Gets the NSIndexPath of the UITableViewCell which is sender.
// Then uses that NSIndexPath to find the Event in question using NSFetchedResultsController.
// Prepares a destination view controller through the "Expense Detail" segue by sending that to it.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    self.navigationItem.title = @"Back"; //cheesy way to rename next view's back button
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];  //can retrieve the indexPath in the model (aka the location of the model object)
    }
    
    if (indexPath) {   
        if ([segue.identifier isEqualToString:@"Expense Detail"]) {
            Expense *expense = [self.fetchedResultsController objectAtIndexPath:indexPath];  //if you have the indexPath, then can use the FRC to retrieve the object in the database
            if ([segue.destinationViewController respondsToSelector:@selector(setExpense:)])
            {
                
                [segue.destinationViewController performSelector:@selector(setExpense:) withObject:expense];
            }
        }
 
    }
    if ([segue.identifier isEqualToString:@"Modify Expense"]) {
        //need to get the expense item so we can prepopulate the fields
        
        Expense *expense = [self.fetchedResultsController objectAtIndexPath:self.passedIndexPath];  //if you have the indexPath, then can use the FRC to retrieve the object in the database
        
        if ([segue.destinationViewController respondsToSelector:@selector(setExistingExpense:)])
        {
            
            [segue.destinationViewController performSelector:@selector(setExistingExpense:) withObject:expense];
        }
    }
}

-(void)addButtonPressed{
    [self performSegueWithIdentifier:@"Add Expense" sender:self];
    
}

-(void)eventsButtonPressed{
    [self performSegueWithIdentifier:@"Unwind To Picker" sender:self];
    
}

@end
