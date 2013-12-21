//
//  Expense+Init.h
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Expense.h"
#define EXPENSE_NAME  @"expenseName"
#define EXPENSE_EVENT  @"expenseEvent"
#define EXPENSE_FRONTER @"expenseFronter"
#define EXPENSE_DEBTORS @"expenseDebtors"
#define EXPENSE_AMOUNT @"expenseAmount"
#define EXPENSE_MODDATE @"expenseModDate"
#define EXPENSE_TRANSACTIONS @"expenseTransactions"
#define EXPENSE_LATITUDE @"expenseLatitude"
#define EXPENSE_LONGITUDE @"expenseLongitude"

@interface Expense (Init)


//Acts as an initializer and getter.  Returns the expense object with the given dictionary of init info.  If it doesn't exist yet, this method will create it and then return it.
// Creates an Expense in the database for the given input data (if necessary).

+ (Expense *)expenseWithInfoDict:(NSDictionary *)expenseInfoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
