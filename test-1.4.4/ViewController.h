//
//  ViewController.h
//  test-1.4.4
//
//  Created by Hemant on 25/09/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (void)handleError: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal;
@end

