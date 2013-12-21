//
//  ExpenseCreatorVC.h
//  IOU
//
//  Created by Allen Chang on 3/3/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Shared.h"
#import "People+Init.h"
#import "Expense+Init.h"
#import "Event+Init.h"
#import "Transaction+Init.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ExpenseCreatorVC : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate>  //implements various protocols

@property (nonatomic) NSMutableArray *allDebtors;
@property (nonatomic) People *fronter;
@property (nonatomic) Event *thisEvent;
@property (nonatomic) NSNumber *lat;  //latitude and longitude
@property (nonatomic) NSNumber *lon;

// Essentially specifies the database to look in to display in this table.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UITextField *expenseNameField;
@property (weak, nonatomic) IBOutlet UITextField *expenseAmountField;
@property (weak, nonatomic) IBOutlet UILabel *fronterNameLabel;
@property (nonatomic) IBOutlet UIBarButtonItem *doneButton;

-(void)submitCreation;
    
@end
