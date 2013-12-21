//
//  MainMenuVC.m
//  IOU
//
//  Created by Allen Chang on 2/28/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "MainMenuVC.h"

@interface MainMenuVC ()
@property (weak, nonatomic) IBOutlet UIButton *createNewButton;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property  (nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation MainMenuVC

- (IBAction)unwindFromPicker:(UIStoryboardSegue *)segue {
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if(!self.managedObjectContext){  //upon first load, need to assign the shared document
        [self useDemoDocument];
    }
    
    //clear the active event when back at main menu
    [Shared clearActiveEventsWithContext:self.managedObjectContext];
    
    
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

@end
