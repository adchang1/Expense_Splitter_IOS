//
//  Event+Init.m
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Event+Init.h"

@implementation Event (Init)

+ (Event *)eventWithName:(NSString*)eventName
  inManagedObjectContext:(NSManagedObjectContext *)context{
    
    
    Event *event = nil;
    
    // Build a fetch request to see if we can find this object in the database.
    // The "unique" attribute is the event Name.
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"eventName" ascending:YES]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"eventName = %@",eventName];  //filters based on eventName
    
    // Execute the fetch
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Check what happened in the fetch
    
    if (!matches || ([matches count] > 1)) {  // nil means fetch failed; more than one impossible (unique!)
        NSLog(@"Event init Error: Came up with multiple matches for a unique request");// handle error
    } else if (![matches count]) { // none found, so let's create an object
        
        
        event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
        event.eventName = eventName;
        event.participants = nil;  //this will get fleshed out automatically as people are created that have this event listed in their attributes
        event.expenses = nil;
        event.current = FALSE; //events do not become the "currently selected event" unless chosen through the event picker, not at creation. 
        
        
    } else { // found the object, just return it from the list of matches (which there will only be one of)
        event = [matches lastObject];
    }
    
    return event;
    
    
    
}

@end
