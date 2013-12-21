//
//  SharedContext.h
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/25/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//  Useful Shared methods

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event+Init.h"
#define NAME @"name"
#define PIC @"pic"
#define EMAIL @"email"
@interface Shared : NSObject
+(UIManagedDocument *)sharedDoc;
+(NSURL *)sharedURL;
+(Event *)getCurrentEvent:(NSManagedObjectContext *)context;  //get the currently set event of interest
+(void)forceSaveDocument;
+(void)clearActiveEventsWithContext:(NSManagedObjectContext *)context;


//debt related methods
+(float)calculateBalanceFor:(People *)mainPerson withOtherPerson:(People *)otherPerson withContext:(NSManagedObjectContext *)context;
+(NSFetchRequest *)getMyDebtTransactionsFor:(People *)mainPerson withOtherPerson:(People *)otherPerson;
+(NSFetchRequest *)getMyFrontTransactionsFor:(People *)mainPerson withOtherPerson:(People *)otherPerson;
+(NSString *)formatFloatToCurrencyString:(float)balance;


//people requests in database
+(NSFetchRequest *)getAllEventPeopleRequestForEvent:(Event *)event;
+(NSArray *)getAllEventPeopleForEvent:(Event *)event withContext:(NSManagedObjectContext *)context;
+(NSMutableArray *)getAllEventPeopleNamesForEvent:(Event *)event withContext:(NSManagedObjectContext *)context;
+(bool)doesPersonWithNameExist:(NSString *)name inEvent:(Event *)event withContext:(NSManagedObjectContext *)context;





+(UIImage *)forceFixedPicSize:(UIImage *)pic;  //for forcing pics to thumbnail size
+(void)scrollAwayFromKeyboard:(UIScrollView *)thisScrollView withTextField:(UITextField *)textField forMainView:(UIView *)mainView;  //move view away from Keyboard popup
@end
