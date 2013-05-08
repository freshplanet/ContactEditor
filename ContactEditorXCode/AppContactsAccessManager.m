//
//  AppContactsAccessManager.m
//  ContactEditor
//
//  Created by Daniel Rodriguez on 5/8/13.
//  Copyright (c) 2013 Randori. All rights reserved.
//

#import "AppContactsAccessManager.h"

@implementation AppContactsAccessManager

- (BOOL) isStatusAvailable:(AddressBookAuthStatus)theStatus
{
    return (theStatus == kABAuthStatusAuthorized || theStatus == kABAuthStatusRestricted);
}

- (void) requestAddressBookWithCompletionHandler:(AddressBookRequestHandler)handler
{
    ALog(@"Entering requestAddressBookWithCompletionHandler");
    
    ABAddressBookRef addressBookRef = NULL;
    
    if ([self isIOS6])
    {
        ALog(@"creating addressbook for iOS 6");
        addressBookRef = ABAddressBookCreateWithOptions(nil,nil);
        ABAuthorizationStatus curStatus = ABAddressBookGetAuthorizationStatus();
        if (curStatus == kABAuthStatusNotDetermined)
        {
            status = kABAuthStatusPending;
            ABAddressBookRequestAccessWithCompletion(addressBookRef,^(bool granted, CFErrorRef error) {
                status = ABAddressBookGetAuthorizationStatus();
                if (handler != NULL) {
                    ALog(@"calling handler");
                    handler(addressBookRef, [self isStatusAvailable:status]);
                }
            });
        }
        else
        {
            status = curStatus;
            dispatch_async(dispatch_get_current_queue(), ^ {
               if (handler != nil) {
                   ALog(@"calling handler");
                   handler(addressBookRef, [self isStatusAvailable:status]);
               }
            });
        }
    }
    else
    {
        ALog(@"creating addressbook for iOS 5 or lower");
        addressBookRef = ABAddressBookCreate();
        status = kABAuthStatusAuthorized;
        if (handler != NULL) {
            ALog(@"calling handler");
            handler(addressBookRef, [self isStatusAvailable:status]);
        }
        else {
            // not using it, so release it.
            CFRelease(addressBookRef);
        }
    }
    
    ALog(@"Exiting requestAddressBookWithCompletionHandler");
}

- (AddressBookAuthStatus) addressBookAuthLevel
{
    return status;
}

- ( BOOL ) isIOS6
{
    float currentVersion = 6.0;
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= currentVersion;
}

@end
