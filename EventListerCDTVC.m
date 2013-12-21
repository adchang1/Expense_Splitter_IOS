//
//  EventListerCDTVC.m
//  IOU
//
//  Created by Allen Chang on 3/3/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "EventListerCDTVC.h"
#import "Event+Init.h"
@interface EventListerCDTVC ()


@end

@implementation EventListerCDTVC




-(NSFetchRequest *)getCustomRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"eventName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = nil; //get ALL the events
    return request;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Event"];
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = event.eventName;
    cell.detailTextLabel.text = nil; //might want to add something here later
    
    return cell;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //abstract
}

- (void)tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    
    //abstract
}

@end
