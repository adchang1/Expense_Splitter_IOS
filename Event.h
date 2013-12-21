//
//  Event.h
//  IOU
//
//  Created by Allen Chang on 3/9/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Expense, People, Transaction;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSNumber * current;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSSet *expenses;
@property (nonatomic, retain) NSSet *participants;
@property (nonatomic, retain) NSSet *transactions;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addExpensesObject:(Expense *)value;
- (void)removeExpensesObject:(Expense *)value;
- (void)addExpenses:(NSSet *)values;
- (void)removeExpenses:(NSSet *)values;

- (void)addParticipantsObject:(People *)value;
- (void)removeParticipantsObject:(People *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

- (void)addTransactionsObject:(Transaction *)value;
- (void)removeTransactionsObject:(Transaction *)value;
- (void)addTransactions:(NSSet *)values;
- (void)removeTransactions:(NSSet *)values;

@end
