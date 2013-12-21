//
//  ExpenseDetailCDTVC.m
//  IOU
//
//  Created by Allen Chang on 3/7/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "ExpenseDetailCDTVC.h"
#import "Expense+Init.h"
#import "People+Init.h"
#import "Shared.h"


@interface ExpenseDetailCDTVC ()
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *expenseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *expenseAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *expenseFronterLabel;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) NSArray *allDebtors;

@property (nonatomic) Expense *expense;

@end

@implementation ExpenseDetailCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setTitle:@"Detail"];
    if(!self.managedObjectContext){  //upon first load, need to assign the shared document cuz this is not subclass of cdtvc
        [self useDemoDocument];
    }
    

     //generate the debtor table using CoreData since you can get it sorted easily that way
    NSArray *retrievedDebtors = [[NSArray alloc]init];
    retrievedDebtors = [self.managedObjectContext executeFetchRequest:[self getDebtorsRequest] error:NULL];
    self.allDebtors=retrievedDebtors;
    
    //set the static label info using the expense info
    self.expenseNameLabel.text = self.expense.expenseName;
    float amount = [self.expense.amount floatValue];
    self.expenseAmountLabel.text = [Shared formatFloatToCurrencyString:amount];
    self.expenseFronterLabel.text = self.expense.fronter.name;
    self.table.frame = CGRectMake(self.table.frame.origin.x, self.table.frame.origin.y, self.table.frame.size.width, self.table.contentSize.height);
    [self.table reloadData];  //refresh, esp if we selected new debtors
    
    
    //map prep
    [self.map removeAnnotations:self.map.annotations];
    NSArray *annotationArray = [NSArray arrayWithObject:self.expense];
    [self.map addAnnotations:annotationArray];
    [self updateRegion];
    
}

-(void)viewDidLayoutSubviews{  //IMPORTANT!! set the scrollview sizes here, because only now are views finally set
    CGSize scrollContentSize = CGSizeMake(self.view.bounds.size.width, 876);
    self.scrollView.contentSize = scrollContentSize;
    self.scrollView.frame = self.view.bounds;
 
}

// when someone touches on a pin, this gets called
// all it does is set the thumbnail (if the annotation has one)
//   in the leftCalloutAccessoryView (if that is a UIImageView)

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        if ([view.annotation respondsToSelector:@selector(thumbnail)]) {
            imageView.image = [view.annotation performSelector:@selector(thumbnail)];
        }
    }
}

// the MKMapView calls this to get the MKAnnotationView for a given id <MKAnnotation>
// our implementation returns a standard MKPinAnnotation
//   which has callouts enabled
//   and which has a leftCalloutAccessory of a UIImageView
//   and a rightCalloutAccessory of a detail disclosure button
//     (but only if delegate responds to mapView:annotationView:calloutAccessoryControlTapped:)

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"MapViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        if ([mapView.delegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]) {
            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        view.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,30,30)];
    }
    
    if ([view.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)(view.leftCalloutAccessoryView);
        imageView.image = nil;
    }
    
    return view;
}

// zooms to a region that encloses the annotations
// kind of a crude version
// (using CGRect for latitude/longitude regions is sorta weird, but CGRectUnion is nice to have!)

- (void)updateRegion
{
    CGRect boundingRect;
    BOOL started = NO;
    for (id <MKAnnotation> annotation in self.map.annotations) {
        CGRect annotationRect = CGRectMake(annotation.coordinate.latitude, annotation.coordinate.longitude, 0, 0);
        if (!started) {
            started = YES;
            boundingRect = annotationRect;
        } else {
            boundingRect = CGRectUnion(boundingRect, annotationRect);
        }
    }
    if (started) {
        boundingRect = CGRectInset(boundingRect, -0.2, -0.2);
        if ((boundingRect.size.width < 20) && (boundingRect.size.height < 20)) {
            MKCoordinateRegion region;
            region.center.latitude = boundingRect.origin.x + boundingRect.size.width / 2;
            region.center.longitude = boundingRect.origin.y + boundingRect.size.height / 2;
            region.span.latitudeDelta = boundingRect.size.width;
            region.span.longitudeDelta = boundingRect.size.height;
            [self.map setRegion:region animated:YES];
        }
    }
}




-(NSArray *)allDebtors{
    if(!_allDebtors){
        _allDebtors = [[NSArray alloc]init];
    }
    return _allDebtors;
}


-(NSFetchRequest *)getDebtorsRequest{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"People"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];

    request.predicate = [NSPredicate predicateWithFormat:@"%@ in expenses",self.expense]; //get the folks that have this expense associated with them
    return request;
}


-(void)setExpense:(Expense *)expense{
    _expense = expense;
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Debtor"];
    People *debtor = self.allDebtors[indexPath.row];
    cell.textLabel.text = debtor.name;
    UIImage *personPic = [UIImage imageWithData:debtor.photo];
    UIImage *tempImage = [Shared forceFixedPicSize:personPic];
    cell.imageView.image = tempImage;

    return cell;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  //req'd protocol method
{
    return [self.allDebtors count];
}




@end
