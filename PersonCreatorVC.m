//
//  PersonCreatorVC.m
//  IOU
//
//  Created by Allen Chang on 3/12/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "PersonCreatorVC.h"


@interface PersonCreatorVC ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UITextField *personName;
@property (weak, nonatomic) IBOutlet UITextField *personEmail;
@property (nonatomic) NSMutableArray *participantNames;
@property (nonatomic) UITextField *currentField;
@property (strong, nonatomic) UIImagePickerController *imgPicker;

@property  (nonatomic) UIImage *chosenImage;   //chosen vars are used in setting photos

@end

@implementation PersonCreatorVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Add Person"];
   
    //set up so taps can dismiss keyboard
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    
 
    self.personName.delegate = self;  //set yourself as delegate for all the textFields!
    self.personEmail.delegate = self;  //set yourself as delegate for all the textFields!
    
    
    
    
    if(!self.managedObjectContext){  //upon first load, need to assign the shared document
        [self useDemoDocument];
    }
    
    
    
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.delegate = self;
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    
  
}

-(NSMutableArray *)participantNames{
    if(!_participantNames){
        _participantNames = [[NSMutableArray alloc]init];
    }
    return _participantNames;
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
    [Shared scrollAwayFromKeyboard:self.scrollView withTextField:textField forMainView:self.view];
    
}

- (IBAction)addParticipant:(id)sender{
    
    if([self.personEmail.text isEqualToString:@""]){  //check if email left blank
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please input an email address."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    
    if(![self.personName.text isEqualToString:@""]){  //make sure they didn't leave the space blank while clicking Add!
        
        Event *event = [Shared getCurrentEvent:self.managedObjectContext];  //get currently active Event, if there is one (nil if creating an event)

        if(event ==nil){  //if adding people to not-yet-created event, check names against the list that was passed in
            for(NSMutableDictionary *person in self.participantNames){   //check if the name exists already
                if([[person objectForKey:NAME] isEqualToString:self.personName.text]){
                    [self personExistAlert];
                    
                    return;
                }
            }
        }
        else{  //must be adding people to existing event; check against people list derived from database
            if([Shared doesPersonWithNameExist:self.personName.text inEvent:[Shared getCurrentEvent:self.managedObjectContext] withContext:self.managedObjectContext]){
                //person already exists, return error
                [self personExistAlert];
                
                return;
            }       
        }
        
        
        if(!self.chosenImage){
            self.chosenImage = [UIImage imageNamed:@"white.jpg"]; //default starting picture if none selected
        }
        
        if(event == nil){  //if there is no event specified, we must be creating a new event and adding people.  In that case, use dictionary based creation and pass that back to the event creator. 
            NSMutableDictionary *newPerson = [[NSMutableDictionary alloc]init];
            
            [newPerson setObject:self.personName.text forKey:NAME];  //set the name
            [newPerson setObject:self.chosenImage forKey:PIC];  //set picture
            [newPerson setObject:self.personEmail.text forKey:EMAIL];   //set the email address
            
            [self.participantNames addObject:newPerson];  //finally, add the person dictionary
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:NAME  ascending:YES];
            [self.participantNames sortUsingDescriptors :[NSArray arrayWithObjects:descriptor,nil]];  //sort by name value
            
            [self performSegueWithIdentifier:@"UnwindToEventCreation" sender:self];
        }
        else{  //if there is an event specified, we must be adding more people to an existing event,  
            
            [People peopleWithName:self.personName.text withPhoto:self.chosenImage withEvent:[Shared getCurrentEvent:self.managedObjectContext] withEmail:self.personEmail.text inManagedObjectContext:self.managedObjectContext];
            [self performSegueWithIdentifier:@"UnwindToPeopleList" sender:self];
            
        }
        
        
        
        
    }
    else {  //case where they left it blank
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Please input a valid name"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
        
    }
    

}

-(void)personExistAlert{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Person's name exists already. Please input a different name. "
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    
}

- (IBAction)choosePic:(id)sender {
    [self presentImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

// presents a UIImagePickerController which gets an image from the specified sourceType
// modally


 - (void)presentImagePicker:(UIImagePickerControllerSourceType)sourceType
 {
     if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
     NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
         if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
         UIImagePickerController *picker = [[UIImagePickerController alloc] init];
         picker.sourceType = sourceType;
         picker.mediaTypes = @[(NSString *)kUTTypeImage];
         picker.allowsEditing = NO;
         picker.delegate = self;
         [self presentViewController:picker animated:YES completion:nil];
         
         }
     }
 }
 
 

// UIImagePickerController was canceled, so dismiss it  (required delegate method)

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// called when the user chooses an image in the UIImagePickerController (req method)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.chosenImage = image;
        
    }
    
    if(!self.chosenImage){
        
    }
    else{
        //Load the imageView with the picture
        self.photoView.image = self.chosenImage;
    }

 
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    //pass the updated participant array back if this is for new event creation
    if ([segue.identifier isEqualToString:@"UnwindToEventCreation"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setParticipantNames:)])
        {
            
            NSLog(@"participant name in person creater count is %d",[self.participantNames count]);
            
            [segue.destinationViewController performSelector:@selector(setParticipantNames:) withObject:self.participantNames];
        }
    }
   
}

@end
