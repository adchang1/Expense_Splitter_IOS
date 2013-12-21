//
//  EventListerCDTVC.h
//  IOU
//
//  Created by Allen Chang on 3/3/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "BaseCDTVC.h"

@interface EventListerCDTVC : BaseCDTVC

- (void)tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;  //allow override
@end
