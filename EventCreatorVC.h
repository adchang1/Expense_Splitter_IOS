//
//  EventCreatorVC.h
//  IOU
//
//  Created by Allen Chang on 3/3/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shared.h"
#import "Event+Init.h"
#import "People+Init.h"
#import <CoreData/CoreData.h>


@interface EventCreatorVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate,UITextFieldDelegate, UIPopoverControllerDelegate>  //implements various protocols

@property (weak, nonatomic) IBOutlet UITextField *eventName;
@property (nonatomic) NSMutableArray *participantNames;

@property (nonatomic) Event *thisEvent;

-(NSArray *)getEventNames;
-(void)submitCreation; //allow override
-(bool)isInvalidEventName:(NSString *)name withExistingNames:(NSArray *)existings; //allow override
@end
