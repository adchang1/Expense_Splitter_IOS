//
//  SharedContext.m
//  CoreDataSPOT
//
//  Created by Allen Chang on 2/25/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Shared.h"
#import "People+Init.h"
#import "Transaction+Init.h"

static UIManagedDocument *document;
static NSURL *url;

@implementation Shared


+(NSURL *)sharedURL{
    url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Demo Document"];
    return url;
}

+(UIManagedDocument *)sharedDoc{

    if(!document){        
        document = [[UIManagedDocument alloc] initWithFileURL:[Shared sharedURL]];
    } 
    return document;
}

+(NSFetchRequest *)getCurrentEventRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.predicate= [NSPredicate predicateWithFormat:@"current = TRUE"];
    return request;
    
}

+(Event *)getCurrentEvent:(NSManagedObjectContext *)context{
    NSArray *fetchResults = [[NSArray alloc]init];
    fetchResults = [context executeFetchRequest:[Shared getCurrentEventRequest] error:NULL];
    
    if([fetchResults count]==0){
        return nil;
    }
    Event *current = [fetchResults lastObject]; //should only be one object in here
    return current;
}



+(void)forceSaveDocument{
    [document saveToURL:document.fileURL
            forSaveOperation:UIDocumentSaveForOverwriting
           completionHandler:^(BOOL success) {
               if (!success){
                   NSLog(@"failed to save document %@",document.localizedName);
               }
           }];
    
}


//useful utility methods for calculating balance between two people
+(NSFetchRequest *)getMyDebtTransactionsFor:(People *)mainPerson withOtherPerson:(People *)otherPerson{  //get debt transactions involving the selected Person
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transaction"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"debtor = %@ AND fronter = %@",mainPerson,otherPerson]; //get the transactions where I am debtor and the other person is fronter
    return request;
}

+(NSFetchRequest *)getMyFrontTransactionsFor:(People *)mainPerson withOtherPerson:(People *)otherPerson{  //get front transactions involving the selected Person
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transaction"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"debtor = %@ AND fronter = %@",otherPerson, mainPerson]; //get the transactions where I am debtor and the other person is fronter
    return request;
}

+(float)calculateBalanceFor:(People *)mainPerson withOtherPerson:(People *)otherPerson withContext:(NSManagedObjectContext *)context{
    NSArray *myDebts = [context executeFetchRequest:[Shared getMyDebtTransactionsFor:mainPerson withOtherPerson:otherPerson] error:NULL];
    NSArray *myFronts = [context executeFetchRequest:[Shared getMyFrontTransactionsFor:mainPerson withOtherPerson:otherPerson] error:NULL];
    
    float balance=0;
    for(Transaction *trans in myDebts){
        balance = balance - [trans.amountOwed floatValue];
    }
    for(Transaction *trans in myFronts){
        balance = balance + [trans.amountOwed floatValue];
    }
    return balance;
}


//useful utility method for formatting floats into currency 
+(NSString *)formatFloatToCurrencyString:(float)balance{
    if(balance >=0){
        NSString* formattedBalance = [NSString stringWithFormat:@"%.02f", balance];
        return [NSString stringWithFormat:@"+$%@",formattedBalance];
    }
    else{
        balance = -balance;  //convert to abs val
        NSString* formattedBalance = [NSString stringWithFormat:@"%.02f", balance];
        return [NSString stringWithFormat:@"-$%@",formattedBalance]; //stick in dollar sign after a neg sign to the abs val
    }
}


+(NSFetchRequest *)getAllEventPeopleRequestForEvent:(Event *)event {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
 
    
    request.predicate = [NSPredicate predicateWithFormat:@"event = %@",event]; //get the folks specifically from the given event
    return request;
}

+(NSArray *)getAllEventPeopleForEvent:(Event *)event withContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [Shared getAllEventPeopleRequestForEvent:event];
    NSArray *peopleList = [context executeFetchRequest:request error:NULL];
    return peopleList;
}



+(NSMutableArray *)getAllEventPeopleNamesForEvent:(Event *)event withContext:(NSManagedObjectContext *)context{
    NSArray *allPeople = [Shared getAllEventPeopleForEvent:event withContext:context];
    NSMutableArray *allPeopleNames = [[NSMutableArray alloc]init];
    for(int index=0;index<[allPeople count];index++){
        People *person = allPeople[index];
        [allPeopleNames addObject:person.name];
    }
    return allPeopleNames;
}



+(UIImage *)forceFixedPicSize:(UIImage *)pic{
    CGSize itemSize = CGSizeMake(40, 40);  //default tableviewcell image size
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [pic drawInRect:imageRect];
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tempImage;
}

+(void)scrollAwayFromKeyboard:(UIScrollView *)thisScrollView withTextField:(UITextField *)textField forMainView:(UIView *)mainView{
    CGRect textBounds = [textField bounds];  //gives size of textbox (assuming origin is upper left of textbox
    textBounds = [textField convertRect:textBounds toView:thisScrollView];  //updates origin of textbox to its actual location in the scrollview
    textBounds.origin.x = 0 ;
    textBounds.origin.y -= 60 ;  //decrements the y-position by 60
    
    CGRect totalViewSize = mainView.bounds;
    
    textBounds.size.height = totalViewSize.size.height;  //sets the "height" of the textbox to some big number so that we will scroll down to it...
    
    [thisScrollView scrollRectToVisible:textBounds animated:YES]; //tries to scroll to make the top of the textBounds visible

    
}


+(bool)doesPersonWithNameExist:(NSString *)name inEvent:(Event *)event withContext:(NSManagedObjectContext *)context{
    NSMutableArray *names = [Shared getAllEventPeopleNamesForEvent:event withContext:context];
    for(NSString *personName in names){
        if([personName isEqualToString:name]){
            return YES;
        }
    }
    return NO;
}

+(void)clearActiveEventsWithContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"eventName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    request.predicate = nil; //get ALL events
    NSArray *events = [context executeFetchRequest:request error:NULL];
    for(Event *event in events){
        event.current = FALSE;
    }
    
    
}
@end
