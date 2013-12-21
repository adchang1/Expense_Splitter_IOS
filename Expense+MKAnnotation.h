//
//  Expense+MKAnnotation.h
//  IOU
//
//  Created by Allen Chang on 3/17/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Expense.h"
#import <MapKit/MapKit.h>
#import "People+Init.h"

@interface Expense (MKAnnotation) <MKAnnotation>

- (UIImage *)thumbnail;  // blocks!

@end
