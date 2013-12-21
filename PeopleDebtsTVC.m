//
//  PeopleDebtsTVC.m
//  IOU
//
//  Created by Allen Chang on 3/9/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "PeopleDebtsTVC.h"
#import "Transaction+Init.h"
#import "People+Init.h"
@interface PeopleDebtsTVC ()
@property (nonatomic) People *mainPerson;
@property (nonatomic) NSArray *allPeople;

@end

@implementation PeopleDebtsTVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setTitle:@"Balances"];

    
    //prepare list of all people in this event
    NSFetchRequest *request = [self getAllEventPeople];
    NSArray *peopleList = [self.managedObjectContext executeFetchRequest:request error:NULL];
    self.allPeople=peopleList;
    
    NSLog(@"allPeople count is %d",[self.allPeople count]);
    
    [self.tableView reloadData]; //now that we have our model set, populate the table!
    
}

-(NSFetchRequest *)getAllEventPeople{  //get all people in this event
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]; 
    request.predicate = [NSPredicate predicateWithFormat:@"event = %@",self.event]; //get the folks specifically from the given event
    return request;
}

-(NSFetchRequest *)getMyDebtTransactionsWith:(People *)otherPerson{  //get debt transactions involving the selected Person
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transaction"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"debtor = %@ AND fronter = %@",self.mainPerson,otherPerson]; //get the transactions where I am debtor and the other person is fronter
    return request;
}

-(NSFetchRequest *)getMyFrontTransactionsWith:(People *)otherPerson{  //get front transactions involving the selected Person
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transaction"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"debtor = %@ AND fronter = %@",otherPerson, self.mainPerson]; //get the transactions where I am debtor and the other person is fronter
    return request;
}

-(float)calculateBalanceWith:(People *)otherPerson{
    NSArray *myDebts = [self.managedObjectContext executeFetchRequest:[self getMyDebtTransactionsWith:otherPerson] error:NULL];
    NSArray *myFronts = [self.managedObjectContext executeFetchRequest:[self getMyFrontTransactionsWith:otherPerson] error:NULL];
    float balance=0;
    for(Transaction *trans in myDebts){
        balance = balance - [trans.amountOwed floatValue];
    }
    for(Transaction *trans in myFronts){
        balance = balance + [trans.amountOwed floatValue];
    }
    return balance;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person"];
    People *person = self.allPeople[indexPath.row];
    //list all people in the event
    cell.textLabel.text = person.name;
    
    //figure out your balance with them
    float balance = [self calculateBalanceWith:person];
    if(balance >0){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"+%f",balance];
    }
    else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"-%f",balance];
    }
    
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSLog(@"allpeople count is %d",[self.allPeople count]);
    
    
    return [self.allPeople count];
    
}


@end
