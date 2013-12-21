//
//  Transaction+Init.h
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Transaction.h"
#import "Expense+Init.h"
#import "Event.h"
@interface Transaction (Init)

//Acts as an initializer and getter.  Returns the object with the given init info.  If it doesn't exist yet, this method will create it and then return it.
// Creates an object in the database for the given input data (if necessary).

+ (Transaction *)transactionWithAmount:(float)amount
                       withFronter:(People *)fronter
                       withDebtor:(People *)debtor
                         withEvent:(Event *)event
                       withExpense:(Expense *)expense
            inManagedObjectContext:(NSManagedObjectContext *)context;

@end
