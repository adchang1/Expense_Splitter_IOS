//
//  People.h
//  IOU
//
//  Created by Allen Chang on 3/12/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Expense, Transaction;

@interface People : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) NSSet *expenses;
@property (nonatomic, retain) NSSet *frontedexpenses;
@property (nonatomic, retain) NSSet *transactionDebt;
@property (nonatomic, retain) NSSet *transactionFront;
@end

@interface People (CoreDataGeneratedAccessors)

- (void)addExpensesObject:(Expense *)value;
- (void)removeExpensesObject:(Expense *)value;
- (void)addExpenses:(NSSet *)values;
- (void)removeExpenses:(NSSet *)values;

- (void)addFrontedexpensesObject:(Expense *)value;
- (void)removeFrontedexpensesObject:(Expense *)value;
- (void)addFrontedexpenses:(NSSet *)values;
- (void)removeFrontedexpenses:(NSSet *)values;

- (void)addTransactionDebtObject:(Transaction *)value;
- (void)removeTransactionDebtObject:(Transaction *)value;
- (void)addTransactionDebt:(NSSet *)values;
- (void)removeTransactionDebt:(NSSet *)values;

- (void)addTransactionFrontObject:(Transaction *)value;
- (void)removeTransactionFrontObject:(Transaction *)value;
- (void)addTransactionFront:(NSSet *)values;
- (void)removeTransactionFront:(NSSet *)values;

@end
