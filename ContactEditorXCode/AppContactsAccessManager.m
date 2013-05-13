//
//  AppContactsAccessManager.m
//  ContactEditor
//
//  Created by Daniel Rodriguez on 5/8/13.
//

#import "AppContactsAccessManager.h"

@implementation AppContactsAccessManager

- (BOOL) isStatusAvailable:(AddressBookAuthStatus)theStatus
{
    return (theStatus == kABAuthStatusAuthorized || theStatus == kABAuthStatusRestricted);
}

- (void) requestAddressBookWithCompletionHandler:(AddressBookRequestHandler)handler
{
    DLog(@"Entering requestAddressBookWithCompletionHandler");
    
    if (handler == NULL) {
        DLog(@"Error: AddressBookRequestHandler:handler cannot be null.  Returning.");
        return;
    }
    
    ABAddressBookRef addressBookRef = NULL;
    
    if ([self isIOS6])
    {
        addressBookRef = ABAddressBookCreateWithOptions(nil,nil);
        ABAuthorizationStatus curStatus = ABAddressBookGetAuthorizationStatus();
        if (curStatus == kABAuthStatusNotDetermined)
        {
            status = kABAuthStatusPending;
            ABAddressBookRequestAccessWithCompletion(addressBookRef,^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_current_queue(), ^{
                    status = ABAddressBookGetAuthorizationStatus();
                    handler(addressBookRef, [self isStatusAvailable:status]);
                    CFRelease(addressBookRef);
                });
            });
        }
        else
        {
            status = curStatus;
            handler(addressBookRef, [self isStatusAvailable:status]);
            CFRelease(addressBookRef);
        }
    }
    else
    {
        addressBookRef = ABAddressBookCreate();
        status = kABAuthStatusAuthorized;
        handler(addressBookRef, [self isStatusAvailable:status]);
        CFRelease(addressBookRef);
    }
    
    DLog(@"Exiting requestAddressBookWithCompletionHandler");
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
