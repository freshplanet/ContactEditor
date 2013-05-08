//
//  AppContactsAccessManager.h
//  ContactEditor
//
//  Created by Daniel Rodriguez on 5/8/13.
//  Copyright (c) 2013 Randori. All rights reserved.
//

#import <AddressBook/AddressBook.h>

typedef enum
{
    kABAuthStatusNotDetermined = 0,
    kABAuthStatusRestricted,
    kABAuthStatusDenied,
    kABAuthStatusAuthorized,
    kABAuthStatusPending
    
}AddressBookAuthStatus;

typedef void (^AddressBookRequestHandler) (ABAddressBookRef addressBookRef, BOOL available);

@interface AppContactsAccessManager : NSObject
{
    AddressBookAuthStatus status;
}

- (void) requestAddressBookWithCompletionHandler:(AddressBookRequestHandler) handler;
- (AddressBookAuthStatus) addressBookAuthLevel;
- (BOOL) isIOS6;

@end
