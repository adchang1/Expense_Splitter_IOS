//
//  People+Init.h
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "People.h"

@interface People (Init)

//Acts as an initializer and getter.  Returns the object with the given init info.  If it doesn't exist yet, this method will create it and then return it.
// Creates an object in the database for the given input data (if necessary).

+ (People *)peopleWithName:(NSString *)name withPhoto:(UIImage *)photo 
                 withEvent:(Event *)event withEmail:(NSString *)email
     inManagedObjectContext:(NSManagedObjectContext *)context;


@end
