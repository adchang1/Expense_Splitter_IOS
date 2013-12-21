//
//  ExpenseCreatorVC.m
//  IOU
//
//  Created by Allen Chang on 3/3/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "ExpenseCreatorVC.h"

@interface ExpenseCreatorVC ()

@property (nonatomic) UITextField *currentField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ExpenseCreatorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //set up so taps can dismiss keyboard
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    self.expenseAmountField.delegate = self;  //set yourself as delegate for all the textFields!
    self.expenseNameField.delegate =self;

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setTitle:@"Create"];
    if(!self.managedObjectContext){  //upon first load, need to assign the shared document
        [self useDemoDocument];
    }

    self.thisEvent = [Shared getCurrentEvent:self.managedObjectContext]; //get the active event  
    [self.table reloadData];  //refresh, esp if we selected new debtors
    
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(submitCreation)];
   
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    self.table.frame = CGRectMake(self.table.frame.origin.x, self.table.frame.origin.y, self.table.frame.size.width, self.table.contentSize.height);
    
}

-(void)viewDidLayoutSubviews{  //IMPORTANT!! set the scrollview sizes here, because only now are views finally set
    CGSize scrollContentSize = CGSizeMake(self.view.bounds.size.width, 876);
    self.scrollView.contentSize = scrollContentSize;
    self.scrollView.frame = self.view.bounds;

}



- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {  //req'd delegate function for map
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
}



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

-(NSFetchRequest *)getCustomRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    request.predicate = [NSPredicate predicateWithFormat:@"event = %@",self.thisEvent]; //get the folks specifically from the given event
    return request;
}



-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [self.currentField resignFirstResponder];
    
}
- (void) textFieldDidBeginEditing:(UITextField *)textField{  //this gets called because we made this class a UITextField delegate
    self.currentField = textField; //track which text field we are using so we can dismiss the keyboard afterwards
    
    [Shared scrollAwayFromKeyboard:self.scrollView withTextField:textField forMainView:self.view];

}


- (IBAction)unwindFromFronterSelect:(UIStoryboardSegue *)segue {
    self.fronterNameLabel.text = self.fronter.name;
}

- (IBAction)unwindFromDebtorSelect:(UIStoryboardSegue *)segue {
    
}


//Table displays the names of the people who could potentially be debtors
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Debtor"];
    int index = indexPath.row;
    People *person = self.allDebtors[index];
    cell.textLabel.text = person.name;
    UIImage *personPic = [UIImage imageWithData:person.photo];
    UIImage *tempImage = [Shared forceFixedPicSize:personPic];
    cell.imageView.image = tempImage;
    cell.detailTextLabel.text = nil; //might want to add something here later


    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  //req'd protocol method
{
    return [self.allDebtors count];
}


-(void)submitCreation{
    float amount = [self.expenseAmountField.text floatValue];
    NSNumber *amountNumber = [NSNumber numberWithFloat:amount];
    
    //ensure fronter is included amongst the participants
    if(![self.allDebtors containsObject:self.fronter]){
        [self.allDebtors addObject:self.fronter];
    }
    

    
    NSSet *debtorSet = [NSSet setWithArray:self.allDebtors];  //prep an NSSet to go into the dictionary, since that's what we need
    
    //do error checking for fields
    if([self.expenseNameField.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Please fill in a valid name for the Expense"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
        return;
    }
    
    else if(amount <= 0 || [self.expenseAmountField.text isEqualToString:@""]){  //check for negative numbers or blank field
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Must input positive amount!"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
        return;
        
    }
    else if(self.fronter ==nil){ //check if fronter was set
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Must Select Fronter"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
        return;
        
    }
    else if([self.allDebtors count]==0){  //check if debtors are set
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Must select at least 1 participant"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
        return;
    }
    else{
        //Get the location of the expense
        CLLocationCoordinate2D location = [[[self.mapView userLocation] location] coordinate];
        
        if(!self.lat && !self.lon){
            self.lat = [NSNumber numberWithDouble:location.latitude];
            self.lon = [NSNumber numberWithDouble:location.longitude];
        }
        
        
        //create the expense argument dictionary first
        NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:amountNumber,EXPENSE_AMOUNT,self.expenseNameField.text,EXPENSE_NAME,[NSDate date],EXPENSE_MODDATE, self.fronter,EXPENSE_FRONTER,debtorSet,EXPENSE_DEBTORS,self.thisEvent,EXPENSE_EVENT,self.lat,EXPENSE_LATITUDE, self.lon,EXPENSE_LONGITUDE, nil];
       
        //Then create the actual expense object
        Expense *createdExpense =[Expense expenseWithInfoDict:infoDict inManagedObjectContext:self.managedObjectContext];
        
       
        
        //generate all related Transactions - each participant (aside from fronter) owes the fronter some fraction of the total amount owed
        float eachOwe = amount/[debtorSet count];
        for(People *person in debtorSet){ 
            if(person != self.fronter){  //avoid case where fronter owes self
                [Transaction transactionWithAmount:eachOwe withFronter:self.fronter withDebtor:person withEvent:self.thisEvent withExpense:createdExpense inManagedObjectContext:self.managedObjectContext];
    
            }
            
        }
  
        //Since everything is ok, perform the segue back
        [self performSegueWithIdentifier:@"UnwindFromExpense" sender:self];

    }
 
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender       
{
 
  
    if ([segue.identifier isEqualToString:@"Choose Fronter"]) {

       self.navigationItem.title = @"Back"; //cheesy way to rename next view's back button
    }
  
    
    if ([segue.identifier isEqualToString:@"Choose Participants"]) {
        self.navigationItem.title = @"Back"; //cheesy way to rename next view's back button
        
        if ([segue.destinationViewController respondsToSelector:@selector(setDebtors:)])
        {
            
            [segue.destinationViewController performSelector:@selector(setDebtors:) withObject:self.allDebtors];
        }
        
    }

}

@end
