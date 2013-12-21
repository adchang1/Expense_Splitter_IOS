//
//  Expense.h
//  IOU
//
//  Created by Allen Chang on 3/16/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, People, Transaction;

@interface Expense : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * expenseName;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *debtors;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) People *fronter;
@property (nonatomic, retain) NSSet *transactions;
@end

@interface Expense (CoreDataGeneratedAccessors)

- (void)addDebtorsObject:(People *)value;
- (void)removeDebtorsObject:(People *)value;
- (void)addDebtors:(NSSet *)values;
- (void)removeDebtors:(NSSet *)values;

- (void)addTransactionsObject:(Transaction *)value;
- (void)removeTransactionsObject:(Transaction *)value;
- (void)addTransactions:(NSSet *)values;
- (void)removeTransactions:(NSSet *)values;

@end
