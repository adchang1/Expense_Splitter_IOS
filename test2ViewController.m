//
//  test2ViewController.m
//  IOU
//
//  Created by Allen Chang on 3/9/13.
//  Copyright (c) 2013 CS193p. All rights reserved.
//

#import "test2ViewController.h"

@interface test2ViewController ()

@end

@implementation test2ViewController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    //list all people in the event
    cell.textLabel.text = @"asdasda";
    
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 3;
    
}

@end
