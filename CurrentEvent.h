//
//  CurrentEvent.h
//  IOU
//
//  Created by Allen Chang on 3/7/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface CurrentEvent : NSManagedObject

@property (nonatomic, retain) Event *event;

@end
