//
//  EventPeopleCDTVC.m
//  IOU
//
//  Created by Allen Chang on 3/5/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "EventPeopleCDTVC.h"
#import "People+Init.h"
@interface EventPeopleCDTVC ()
@property (nonatomic) NSArray *allPeople;  //used for generating balances

@end

@implementation EventPeopleCDTVC


- (IBAction)unwindFromTest:(UIStoryboardSegue *)segue {
    
}

-(void)viewDidLoad{
    [super viewDidLoad];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.title = @"People"; // TabBarItem.title at the bottom inherits the viewController's self.title
    self.navigationItem.title = @"People";  //this is the top bar title

    
    UIBarButtonItem *eventsButton = [[UIBarButtonItem alloc] initWithTitle:@"Events" style:UIBarButtonItemStylePlain target:self action:@selector(eventsButtonPressed)];
    self.navigationItem.leftBarButtonItem=eventsButton;

    self.allPeople = [self.managedObjectContext executeFetchRequest:[self getCustomRequest] error:NULL];  //generate array of all people (for balance calculation, not for main list)
    [self.tableView reloadData];
}


- (IBAction)unwindToPeople:(UIStoryboardSegue *)segue {  //unwind segue destination for Person Creator
    
}

-(void)eventsButtonPressed{
    [self performSegueWithIdentifier:@"Unwind To Picker" sender:self];
    
}
//get any expense objects that are associated with this event
-(NSFetchRequest *)getCustomRequest{
    

    return [Shared getAllEventPeopleRequestForEvent:self.event];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person"];
    People *mainPerson = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = mainPerson.name;
    UIImage *personPic = [UIImage imageWithData:mainPerson.photo];
    UIImage *tempImage = [Shared forceFixedPicSize:personPic];
    cell.imageView.image = tempImage;
    
    float totalBalance = 0;
    
    for(People *otherPerson in self.allPeople){  //calc total balance, summing up balance between this person and all other ppl
        if(otherPerson!=mainPerson){
            totalBalance = totalBalance + [Shared calculateBalanceFor:mainPerson withOtherPerson:otherPerson withContext:self.managedObjectContext];
        }
    }
    
    
    [cell.detailTextLabel setAttributedText:[self colorMoneyTextwithFloatValue:totalBalance]];
    return cell;
    
}

-(NSMutableAttributedString *)colorMoneyTextwithFloatValue:(float)floatVal{
    
    UIColor *balanceColor;
    UIFont *balanceFont = [UIFont systemFontOfSize:14];
    if(floatVal <0){
        balanceColor = [UIColor redColor];
    }
    else{
        balanceColor = [UIColor colorWithRed: 0 green:0.5 blue:0 alpha:1]; //a dark green...the fraction is the % of 255
    }
    NSDictionary *attributeDic = @{NSForegroundColorAttributeName:balanceColor,NSFontAttributeName:balanceFont};
    NSString *balanceString = [Shared formatFloatToCurrencyString:floatVal];
    NSMutableAttributedString *coloredBalanceString = [[NSMutableAttributedString alloc] initWithString:balanceString attributes:attributeDic];
    return coloredBalanceString;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];  //can retrieve the indexPath in the model (aka the location of the model object)
    }
    
    if (indexPath) {  //send the identity of the person we want to know more about
        if ([segue.identifier isEqualToString:@"Show Balance"]) {
            People *person = [self.fetchedResultsController objectAtIndexPath:indexPath];  //if you have the indexPath, then can use the FRC to retrieve the object in the database
            if ([segue.destinationViewController respondsToSelector:@selector(setMainPerson:)])
            {
                
                [segue.destinationViewController performSelector:@selector(setMainPerson:) withObject:person];
            }
        }
    }
}



@end
