//
//  EventExpenseCDTVC.h
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "BaseCDTVC.h"
#import "Event.h"
#import "Expense.h"
@interface EventExpenseCDTVC : BaseCDTVC

// The Model for this class.
// It displays all the Expense objects associated with this Event


@property (nonatomic, strong) Event *event;

@end
