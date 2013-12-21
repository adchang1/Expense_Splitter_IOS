//
//  EventModifierVC.m
//  IOU
//
//  Created by Allen Chang on 3/9/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "EventModifierVC.h"

@interface EventModifierVC ()

@property NSManagedObjectContext *managedObjectContext;
@end

@implementation EventModifierVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setTitle:@"Edit Event"];
    
    if(!self.managedObjectContext){
        [self useDemoDocument];  //also runs setupFetchedResultsController inside this since it runs the custom setManagedObjectContext method
        
    }
    self.thisEvent = [Shared getCurrentEvent:self.managedObjectContext];

    self.participantNames = [self getAllEventPeopleDictionaryForEvent:self.thisEvent withContext:self.managedObjectContext];  //fill in the participant dictionary array every time you come.
    self.eventName.text = self.thisEvent.eventName; //set the event name field every time you come.
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

//Gets a static document that is shared amongst the view controllers, and sets the context. Need this to maintain continuity between the different views.
- (void)useDemoDocument
{
    
    UIManagedDocument *document = [Shared sharedDoc];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[[Shared sharedURL] path]]) {
        [document saveToURL:[Shared sharedURL]
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
    
}

-(void)submitCreation{
    
    //first do error checking for fields
    if([self.eventName.text isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Please fill in Event Name"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
        return;
    }
    
    else{
        if(![self.thisEvent.eventName isEqualToString:self.eventName.text]){  //if the name got changed
            //check for conflict with any other existing name...if so, returns with an error popup
            NSArray *eventNames = [self getEventNames];
            if([self isInvalidEventName:self.eventName.text withExistingNames:eventNames]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Event name already exists. Please choose a different name."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                [alert show];
                
                return;
            }
        }
        
        
        
        //otherwise...everything is fine, modify the event object
        
        self.thisEvent.eventName = self.eventName.text;
        
        //add all NEW participants to database; initialize them with info
        if([self.participantNames count] !=0){  //only add people if there are some people listed
            NSArray *allPeople = [Shared getAllEventPeopleForEvent:self.thisEvent withContext:self.managedObjectContext];  //get original participant list
            for(NSMutableDictionary *personDic in self.participantNames){
                NSString *newName = [personDic objectForKey:NAME];
                bool exist = [self checkNameExistsAlready:newName inPeopleArray:allPeople];
                if(exist==FALSE){
                    [People peopleWithName:newName withPhoto:[personDic objectForKey:PIC] withEvent:self.thisEvent withEmail:[personDic objectForKey:EMAIL]inManagedObjectContext:self.managedObjectContext];
                }
                
                
                
                
            }
        }
        
        //force save once you modify an event
        [Shared forceSaveDocument];
        
        
        [self performSegueWithIdentifier:@"Unwind To Picker" sender:self];
        
    }
    
}


-(bool)checkNameExistsAlready:(NSString *)name inPeopleArray:(NSArray *)peopleArray{
    for(People *person in peopleArray){
        if([name isEqualToString:person.name]){  //if person already exist in database, return true
            return YES;
        }
    }
    return FALSE; //only reaches here if no matches found
}

-(NSMutableArray *)getAllEventPeopleDictionaryForEvent:(Event *)event withContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [Shared getAllEventPeopleRequestForEvent:event];
    NSArray *peopleList = [[NSArray alloc]init];
    peopleList = [context executeFetchRequest:request error:NULL];

    NSMutableArray *peopleDictionaryList = [[NSMutableArray alloc]init];
    if([peopleList count]>0){
        for(People *person in peopleList){
            NSMutableDictionary *personDic = [[NSMutableDictionary alloc]init];
            [personDic setObject:person.name forKey:NAME];
            UIImage *image = [UIImage imageWithData:person.photo];
            [personDic setObject:image forKey:PIC];
            [peopleDictionaryList addObject:personDic];
        }
    }
    
    return peopleDictionaryList;
}

-(bool)isInvalidEventName:(NSString *)name withExistingNames:(NSArray *)existings{
    //modified for this class  (override)
    
    for(NSString *eventName in existings){
        if([eventName isEqualToString: name]){
            return TRUE;
            
        }
    }
    return FALSE; //only get here if the proposed name does not exist already
    
    
}

@end
