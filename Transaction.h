//
//  Transaction.h
//  IOU
//
//  Created by Allen Chang on 3/9/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Expense, People;

@interface Transaction : NSManagedObject

@property (nonatomic, retain) NSNumber * amountOwed;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) People *debtor;
@property (nonatomic, retain) People *fronter;
@property (nonatomic, retain) Expense *expense;

@end
