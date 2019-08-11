//
//  SMTDemoListController.m
//  JSBridge
//
//  Created by yangyang on 2019/8/4.
//  Copyright © 2019 yangyang. All rights reserved.
//

#import "SMTDemoListController.h"
#import "SMTDemo1Controller.h"
#import "SMTDemo2Controller.h"
#import "SMTDemo3Controller.h"
#import "SVProgressHUD.h"

#import "SMTBridge1Controller.h"

@interface SMTDemoListController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation SMTDemoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    [self setup];
}

- (void)setup {
    self.dataSource = @[
       @{
           @"title": @"基本原理 - scheme",
           @"VC": [SMTDemo1Controller class],
       },
       @{
           @"title": @"基本原理 - jscore",
           @"VC": [SMTDemo2Controller class],
        },
       @{
           @"title": @"基本原理 - wkwebview",
           @"VC": [SMTDemo3Controller class],
        },
       
       @{
           @"title": @"bridge实现",
           @"VC": [SMTBridge1Controller class],
        },
//       @{
//           @"title": @"bridge实现 - 2",
//           @"VC": [SMTBridge1Controller class],
//        },
    ];
    
    [self.tableView registerClass: [UITableViewCell class] forCellReuseIdentifier:@"ListCell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListCell"];
    }
    
    NSDictionary *data = self.dataSource[indexPath.row];
    
    NSLog(@"%@", data);
 
    cell.textLabel.text = data[@"title"];
    cell.textLabel.textColor = [UIColor blackColor];
 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = self.dataSource[indexPath.row];
    UIViewController *VC = [data[@"VC"] new];
    
    [self.navigationController pushViewController:VC animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
