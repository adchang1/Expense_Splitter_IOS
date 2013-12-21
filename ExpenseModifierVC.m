//
//  ExpenseModifierVC.m
//  IOU
//
//  Created by Allen Chang on 3/9/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "ExpenseModifierVC.h"

@interface ExpenseModifierVC ()
@property (nonatomic) Expense *existingExpense;
@property (nonatomic) NSMutableArray *oldAllDebtors;

@end

@implementation ExpenseModifierVC
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.allDebtors == nil){  //initially, populate debtor list with the old data
        self.allDebtors = [self getAllPeopleForExpense:self.existingExpense withContext:self.managedObjectContext];
    }  
    if([self.expenseNameField.text isEqualToString:@""]){
        self.expenseNameField.text = self.existingExpense.expenseName;
    }
    if([self.expenseAmountField.text isEqualToString:@""]){
        self.expenseAmountField.text = [self.existingExpense.amount description];
    };
    if(self.fronter == nil){
        self.fronter = self.existingExpense.fronter;
    }
    if([self.fronterNameLabel.text isEqualToString:@""]){
        self.fronterNameLabel.text = self.fronter.name;
    }
    
    self.lat = self.existingExpense.latitude;
    self.lon = self.existingExpense.longitude;
    
    //upon modification, don't look to old data anymore- use new data passed by other views
    
    [self setTitle:@"Modify"];

    [self.table reloadData];  //refresh, esp if we selected new debtors

}


- (IBAction)unwindFromFronterSelectToModifier:(UIStoryboardSegue *)segue {
    self.fronterNameLabel.text = self.fronter.name;
}

- (IBAction)unwindFromDebtorSelectToModifier:(UIStoryboardSegue *)segue {
    
}

-(void)submitCreation{
    
    [self.managedObjectContext deleteObject:self.existingExpense];  //Remove the old version of this expense. This should cascade and also delete all associated transactions
    [super submitCreation]; //add the new version of this expense
    
}

-(NSFetchRequest *)getAllPeopleRequestForExpense:(Expense *)expense {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    request.predicate = [NSPredicate predicateWithFormat:@"%@ in expenses",expense]; //get the folks that have this expense associated with them
    return request;
}

-(NSMutableArray *)getAllPeopleForExpense:(Expense *)expense  withContext:(NSManagedObjectContext *)context{
    NSFetchRequest *request = [self getAllPeopleRequestForExpense:expense];
    NSMutableArray *peopleList = [[context executeFetchRequest:request error:NULL] mutableCopy];
    return peopleList;
}

-(NSFetchRequest *)getAllEventExpensesRequestforEvent:(Event *)event{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Expense"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"expenseName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    
    request.predicate = [NSPredicate predicateWithFormat:@"event = %@",event]; //get the folks that have this expense associated with them
    return request;
}


@end
