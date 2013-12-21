//
//  MultiplePersonPickerCDTVC.m
//  IOU
//
//  Created by Allen Chang on 3/5/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "MultiplePersonPickerCDTVC.h"
#import "People+Init.h"

@interface MultiplePersonPickerCDTVC ()
@property (nonatomic) NSMutableArray *debtors;  //contains array of checkmarked people
@end

@implementation MultiplePersonPickerCDTVC
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Select Participants"];
    
    
}


-(NSMutableArray *)debtors{
    if(!_debtors){
        _debtors = [[NSMutableArray alloc]init];
    }
    return _debtors;
}


-(NSFetchRequest *)getCustomRequest{

    return [Shared getAllEventPeopleRequestForEvent:self.event];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person"];
    People *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = person.name;
    
    UIImage *personPic = [UIImage imageWithData:person.photo];
    UIImage *tempImage = [Shared forceFixedPicSize:personPic];
    cell.imageView.image = tempImage;
    
    cell.detailTextLabel.text = nil; //might want to add something here later
    if([self.debtors containsObject:person]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;  //checkmark it if they are already in the debtor list
    }
    return cell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UnwindDebtors"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setAllDebtors:)])
        {
            //sends the debtor list back
            [segue.destinationViewController performSelector:@selector(setAllDebtors:) withObject:self.debtors];
        }
    }
    
}

- (IBAction)DoneDebtorSelectButton:(id)sender {

    [self performSegueWithIdentifier:@"UnwindDebtors" sender:self];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    People *person = [self.fetchedResultsController objectAtIndexPath:indexPath];

   //adding removing people from debtor list
   
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.debtors addObject:person];
        
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.debtors removeObject:person];
    }
    
    
}

@end
