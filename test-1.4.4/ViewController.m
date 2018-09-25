//
//  ViewController.m
//  test-1.4.4
//
//  Created by Hemant on 25/09/18.
//  Copyright © 2018 Hemant. All rights reserved.
//

#import "ViewController.h"
#import <CouchbaseLite/CouchbaseLite.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSError* error;
    CBLManager *dbManager = [CBLManager sharedInstance];
    if (!dbManager) {
        NSLog(@"Cannot create Manager instance");
    }
    CBLDatabase* database = [dbManager existingDatabaseNamed: @"catalog" error: &error];
    if (!database) {
        NSString* cannedDbPath = [[NSBundle mainBundle] pathForResource: @"catalog"
                                                                 ofType: @"cblite"];
        NSString* cannedAttPath = [[NSBundle mainBundle] pathForResource: @"catalog attachments"
                                                                  ofType: @""];
        BOOL ok = [dbManager replaceDatabaseNamed: @"catalog"
                                 withDatabaseFile: cannedDbPath
                                  withAttachments: cannedAttPath
                                            error: &error];
//        if (!ok) [self handleError: error];
        database = [dbManager existingDatabaseNamed: @"catalog" error: &error];
//        if (!ok) [self handleError: error];
        
        NSString* owner = [@"profile:" stringByAppendingString: @"Hemant"];
        NSDictionary* properties = @{@"type":       @"list",
                                     @"title":      @"Test-doc",
                                     @"created_at": [CBLJSON JSONObjectWithDate: [NSDate date]],
                                     @"owner":      owner,
                                     @"members":    @[]};
        CBLDocument* document = [database createDocument];
        [document putProperties:properties error:nil];
        NSError* error;
//        if (![document putProperties: properties error: &error]) {
//            [self handleError: error];
//        }
        if (![document update: ^BOOL(CBLUnsavedRevision *newRev) {
            newRev[@"title"] = @"new title";
            newRev[@"notes"] = @"notes";
            return YES;
        } error: &error]) {
//            [self handleError: error];
        }
        for (;;) {
            // Setting ttl of 5 and then changing it  just before it expires
            NSDate* ttl = [NSDate dateWithTimeIntervalSinceNow: 5];
            NSDictionary* newProperties = @{@"foo": @"bar"};
            
            [document putProperties:newProperties error:nil];
            document.expirationDate = ttl;
            
            // Sleep timer for running into race condition
            [NSThread sleepForTimeInterval:4.9f];
            @try {
                document.expirationDate = ttl;
            } @catch (NSException *exception) {
                NSLog(@"Exception: %@", exception);
            } @finally {
                NSLog(@"Finally");
            }
            
        }

    }
}

- (void)handleError: (NSString*)message error: (NSError*)error fatal: (BOOL)fatal {
    if (error) {
        message = [message stringByAppendingFormat: @"\n\n%@", error.localizedDescription];
    }
    NSLog(@"ALERT: %@ (error=%@)", message, error);
}

@end
