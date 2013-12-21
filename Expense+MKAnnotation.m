//
//  Expense+MKAnnotation.m
//  IOU
//
//  Created by Allen Chang on 3/17/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "Expense+MKAnnotation.h"


@implementation Expense (MKAnnotation) 

// part of the MKAnnotation protocol

- (NSString *)title
{
    return self.expenseName;
}

// part of the MKAnnotation protocol

- (NSString *)subtitle
{
    NSNumber *num = self.amount;
    float numfloat = [num floatValue];
    return [NSString stringWithFormat:@"%.02f",numfloat];
}

// (required) part of the MKAnnotation protocol
// just picks the location of a random photo by this photographer

- (CLLocationCoordinate2D)coordinate
{
    double lat = [self.latitude doubleValue];
    double longi = [self.longitude doubleValue];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, longi);
    return coord;
}

// MapViewController likes annotations to implement this

- (UIImage *)thumbnail
{
    NSData *photoData= self.fronter.photo;
    UIImage *photo = [UIImage imageWithData:photoData];
    return photo;
}


@end
