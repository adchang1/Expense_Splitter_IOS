//
//  EventCreatorVC.m
//  IOU
//
//  Created by Allen Chang on 3/3/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "EventCreatorVC.h"





@interface EventCreatorVC ()

// Essentially specifies the database to look in to display in this table.
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *eventPeopleTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSubmit;
@property (nonatomic) UITextField *currentField;

@end

@implementation EventCreatorVC

-(NSMutableArray *)participantNames{
    if(!_participantNames){
        _participantNames = [[NSMutableArray alloc]init];
    }
    return _participantNames;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
   
    
    
    if(!self.managedObjectContext){  //upon first load, need to assign the shared document
        [self useDemoDocument];
    }
    
    //set up so taps can dismiss keyboard
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    self.eventName.delegate = self;  //set yourself as delegate for all the textFields!
   
    
    
  
    self.participantNames = nil;  //reset the participant array every time you come.
    self.eventName.text = nil; //clear the event name field every time you come.
}

- (void)viewWillAppear:(BOOL)animated
{   [super viewWillAppear:animated];
    self.navigationItem.title = @"Create Event";
    
    [self.eventPeopleTable reloadData];   //may have gotten new participants
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [Shared clearActiveEventsWithContext:self.managedObjectContext];  //make all events inactive 
    
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

-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [self.currentField resignFirstResponder];
  
}
- (void) textFieldDidBeginEditing:(UITextField *)textField{  //this gets called because we made this class a UITextField delegate
    self.currentField = textField; //track which text field we are using so we can dismiss the keyboard afterwards
    
}

-(NSFetchRequest *)getCustomRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"eventName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    request.predicate = nil; //get all Events
    return request;
}

-(NSArray *)getEventNames{
    NSFetchRequest *req = [self getCustomRequest];
    NSMutableArray *names = [[NSMutableArray alloc]init];
    NSArray *events =[[self managedObjectContext] executeFetchRequest:req error:NULL];
    for(Event *event in events){   //create the names Array
        [names addObject:event.eventName];
    } 
    return names;
}

-(void)submitCreation{
    
    //first do error checking for fields
    if([self.eventName.text isEqualToString:@""]){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Please fill in Event Name"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
        return;
    }
   
    else{
        
        //check for existing name, return error if so
        NSArray *eventNames = [self getEventNames];
      
        if([self isInvalidEventName:self.eventName.text withExistingNames:eventNames]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Event name already exists. Please choose a different name."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
            
            return;
        }
        
     
        
        //otherwise...everything is fine, add it to the database

        
        //first create the event object and add to database
        self.thisEvent =[Event eventWithName:self.eventName.text inManagedObjectContext:self.managedObjectContext];

        
        //add all participants to database; initialize them with info
        if([self.participantNames count] !=0){  //only add people if there are some people listed
            for(NSMutableDictionary *person in self.participantNames){
                
                
                
                [People peopleWithName:[person objectForKey:NAME] withPhoto:[person objectForKey:PIC] withEvent:self.thisEvent withEmail:[person objectForKey:EMAIL]inManagedObjectContext:self.managedObjectContext];
            }
        }
      
        //force save once you create an event
        [Shared forceSaveDocument];
        
        
        [self performSegueWithIdentifier:@"Load Event" sender:self];
    
    }
    
}

-(bool)isInvalidEventName:(NSString *)name withExistingNames:(NSArray *)existings{
    //can be overridden for specific logic
    
    for(NSString *eventName in existings){
        if([eventName isEqualToString: name]){
            return TRUE;
            
        }
    }
    return FALSE; //only get here if the proposed name does not exist already
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  //req'd protocol method
{
    return [self.participantNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Participant";  //you have to set this in the storyboard!
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];  //first CREATE the cell
    
    // Configure the cell...
    NSMutableDictionary *personDic = [self.participantNames objectAtIndex:indexPath.row];
    cell.textLabel.text = [personDic objectForKey:NAME];   //set the cell labels and subtitles using abstract methods
   // cell.detailTextLabel.text = @"Pick Photo";
    UIImage *personPic = [personDic objectForKey:PIC];  //by default is just white
    
    UIImage *tempImage = [Shared forceFixedPicSize:personPic];
    cell.imageView.image = tempImage;
  //  cell.accessoryView = [self accessoryModifyButton]; //allow selection of photo
    
    return cell;
}

- (IBAction)unwindToEventCreation:(UIStoryboardSegue *)segue {
    
}


- (IBAction)btnSubmit:(UIBarButtonItem *)sender {
    [self submitCreation];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 
    
   
    if ([segue.identifier isEqualToString:@"Add Person"]) {
        self.navigationItem.title = @"Back"; //cheesy way to rename next view's back button
        
        
        if ([segue.destinationViewController respondsToSelector:@selector(setParticipantNames:)])
        {
            [segue.destinationViewController performSelector:@selector(setParticipantNames:) withObject:self.participantNames];
        }
    }
    
}


@end
