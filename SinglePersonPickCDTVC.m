//
//  SinglePersonPickCDTVC.m
//  IOU
//
//  Created by Allen Chang on 3/3/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "SinglePersonPickCDTVC.h"
#import "People+Init.h"

@interface SinglePersonPickCDTVC ()

 
@end

@implementation SinglePersonPickCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Select Fronter"];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(NSFetchRequest *)getCustomRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"event = %@",self.event]; //get the folks specifically from the given event
    return request;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person"];
    People *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = nil; //might want to add something here later
    UIImage *personPic = [UIImage imageWithData:person.photo];
    UIImage *tempImage = [Shared forceFixedPicSize:personPic];
    cell.imageView.image = tempImage;
    
    return cell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];  //can retrieve the indexPath in the model (aka the location of the model object)
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"UnwindFronter"]) {
            People *person = [self.fetchedResultsController objectAtIndexPath:indexPath];  //if you have the indexPath, then can use the FRC to retrieve the object in the database
            if ([segue.destinationViewController respondsToSelector:@selector(setFronter:)])
            {
                
                [segue.destinationViewController performSelector:@selector(setFronter:) withObject:person];
            }
        }
    }
}


@end
