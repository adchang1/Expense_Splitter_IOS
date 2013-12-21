//
//  People+Init.m
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "People+Init.h"

@implementation People (Init)


+ (People *)peopleWithName:(NSString *)name withPhoto:(UIImage *)photo 
                  withEvent:(Event *)event withEmail:(NSString *)email
     inManagedObjectContext:(NSManagedObjectContext *)context{
    
    
    
    People *people = nil;
    
    // Build a fetch request to see if we can find this object in the database.
    // The "unique" attribute is the eventName combined with person's name and the event.
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"event = %@ AND name = %@",event,name];  //filters based on event and name (both need to match)
    
    // Execute the fetch
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Check what happened in the fetch
    
    if (!matches || ([matches count] > 1)) {  // nil means fetch failed; more than one impossible (unique!)
        NSLog(@"People init Error: Came up with multiple matches for a unique request");// handle error
    } else if (![matches count]) { // none found, so let's create an object
        
        
        people = [NSEntityDescription insertNewObjectForEntityForName:@"People" inManagedObjectContext:context];
        people.name = name;
        
        //convert the UIimage into NSData
        NSData *imageData = UIImageJPEGRepresentation(photo, 1);
        people.photo = imageData;
        people.event = event;
        people.expenses = nil;
        people.email = email;
        
        
    } else { // found the object, just return it from the list of matches (which there will only be one of)
        people = [matches lastObject];
    }
    
    return people;
    
    
}



@end
