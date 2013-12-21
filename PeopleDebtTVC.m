//
//  PeopleDebtTVC.m
//  IOU
//
//  Created by Allen Chang on 3/9/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "PeopleDebtTVC.h"
#import "Transaction+Init.h"
#import "People+Init.h"
#define ACCESSORY_HEIGHT 40
#define ACCESSORY_WIDTH 40

@interface PeopleDebtTVC ()
@property (nonatomic) People *mainPerson;
@property (nonatomic) NSArray *allPeople;
@end

@implementation PeopleDebtTVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *title = [NSString stringWithFormat:@"%@'s Balances",self.mainPerson.name];
    [self setTitle:title];
    
    
    //prepare list of all people in this event
    NSFetchRequest *request = [self getAllEventPeople];
    NSArray *peopleList = [self.managedObjectContext executeFetchRequest:request error:NULL];
    self.allPeople=peopleList;
    [self.tableView reloadData]; //now that we have our model set, populate the table!
    
}

-(NSFetchRequest *)getAllEventPeople{  //get all OTHER people besides the main person, from this event
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"event = %@ AND name!= %@",self.event, self.mainPerson.name]; //get the folks specifically from the given event
    return request;
}



-(NSFetchRequest *)getAllEventTransactions{  //test method to get ALL transactions assoc with this event
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Transaction"];
    request.predicate = [NSPredicate predicateWithFormat:@"event = %@",self.event]; 
    return request;
}

-(NSArray *)getAllTransactions{
    NSArray *trans = [self.managedObjectContext executeFetchRequest:[self getAllEventTransactions] error:NULL];
    return trans;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Person"];
    People *person = self.allPeople[indexPath.row];
    //list all people in the event
    cell.textLabel.text = person.name;
    
    //figure out your balance with them
    float balance = [Shared calculateBalanceFor:self.mainPerson withOtherPerson:person withContext:self.managedObjectContext];
    
    [cell.detailTextLabel setAttributedText:[self colorMoneyTextwithFloatValue:balance]];  //print out colored balance
    
    
    UIImage *personPic = [UIImage imageWithData:person.photo];
    UIImage *tempImage = [Shared forceFixedPicSize:personPic];
    cell.imageView.image = tempImage;
    cell.accessoryView = [self accessoryButton];
 
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.allPeople count];
    
}


- (void)openMail:(NSIndexPath *)indexPath
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSString *subject = [NSString stringWithFormat:@"A Reminder from %@",self.mainPerson.name];
        [mailer setSubject:subject];
        People *recipient = self.allPeople[indexPath.row];
        NSArray *toRecipients = [NSArray arrayWithObjects:recipient.email, nil];
        [mailer setToRecipients:toRecipients];
        NSString *emailBody = @"We have a debt to settle...";
        [mailer setMessageBody:emailBody isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
   
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UIButton *)accessoryButton{
    UIButton *accessory = [UIButton buttonWithType:UIButtonTypeCustom];

    [accessory setImage:[UIImage imageNamed:@"mail.png"] forState:UIControlStateNormal];
    accessory.frame = CGRectMake(0, 0, ACCESSORY_HEIGHT, ACCESSORY_WIDTH);
    accessory.userInteractionEnabled = YES;
    
    [accessory addTarget:self action:@selector(didTapAccessory:) forControlEvents: UIControlEventTouchUpInside];
    return accessory;
}

- (void)didTapAccessory:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[sender superview]];
    
    [self openMail:indexPath];
}



@end
