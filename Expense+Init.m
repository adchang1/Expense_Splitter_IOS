//
//  Expense+Init.m
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Expense+Init.h"
#import "Transaction+Init.h"
@implementation Expense (Init)

+ (Expense *)expenseWithInfoDict:(NSDictionary *)expenseInfoDictionary inManagedObjectContext:(NSManagedObjectContext *)context{
    
    Expense *expense = nil;
    
    // Build a fetch request to see if we can find this Expense in the database.
    // The "unique" attribute in Expense is the expenseName combined with eventName.
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Expense"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"expenseName" ascending:YES]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"expenseName = %@ AND event = %@", [expenseInfoDictionary[EXPENSE_NAME] description],expenseInfoDictionary[EXPENSE_EVENT]];  //filters based on event name and expense(both need to match)
    
    // Execute the fetch
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Check what happened in the fetch
    
    if (!matches || ([matches count] > 1)) {  // nil means fetch failed; more than one impossible (unique!)
        NSLog(@"Expense init Error: Came up with multiple matches for a unique request");// handle error
    } else if (![matches count]) { // none found, so let's create an expense object for that expense
        expense = [NSEntityDescription insertNewObjectForEntityForName:@"Expense" inManagedObjectContext:context];
        expense.expenseName = [expenseInfoDictionary[EXPENSE_NAME] description];
        expense.amount = expenseInfoDictionary[EXPENSE_AMOUNT];  
        expense.fronter = expenseInfoDictionary[EXPENSE_FRONTER];
        expense.event = expenseInfoDictionary[EXPENSE_EVENT];
        expense.lastModified = expenseInfoDictionary[EXPENSE_MODDATE];
        expense.debtors = expenseInfoDictionary[EXPENSE_DEBTORS];  //this is an NSSet
        expense.latitude = expenseInfoDictionary[EXPENSE_LATITUDE];
        expense.longitude = expenseInfoDictionary[EXPENSE_LONGITUDE];
        

        
    /*
        
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; // bad
            // UIImage is one of the few UIKit objects which is thread-safe, so we can do this here
            NSURL *url =[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare];
            photo.thumbdata = [[NSData alloc] initWithContentsOfURL: url];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO; // bad
            
        });
    */    

 
        
    } else { // found the Expense, just return it from the list of matches (which there will only be one of)
        expense = [matches lastObject];
    }
    
    return expense;


    
}



@end
