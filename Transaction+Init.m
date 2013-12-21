//
//  Transaction+Init.m
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Transaction+Init.h"

@implementation Transaction (Init)

+ (Transaction *)transactionWithAmount:(float)amount
                       withFronter:(People *)fronter
                       withDebtor:(People *)debtor
                         withEvent:(Event *)event
                       withExpense:(Expense *)expense
            inManagedObjectContext:(NSManagedObjectContext *)context{
    
    
    
    Transaction *transaction = nil;
    
    // Build a fetch request to see if we can find this object in the database.
    // The "unique" attribute is the eventName combined with Expense.
/*
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transaction"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"amountOwed" ascending:YES]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"expense = %@ AND event = %@ ", expense,event];  //filters based on event and expense (both need to match)
    
    // Execute the fetch
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    // Check what happened in the fetch
    
    if (!matches || ([matches count] > 1)) {  // nil means fetch failed; more than one impossible (unique!)
        NSLog(@"Error: Came up with multiple matches for a unique request");// handle error
    } else if (![matches count]) { // none found, so let's create an object
    
*/
        transaction = [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:context];
        transaction.amountOwed = [NSNumber numberWithFloat:amount];  
        transaction.fronter = fronter;
        transaction.debtor= debtor;
        transaction.event = event;
        transaction.expense = expense;
  
/*
    } else { // found the object, just return it from the list of matches (which there will only be one of)
        transaction = [matches lastObject];
    }
 */   
    return transaction;

    
}
@end
