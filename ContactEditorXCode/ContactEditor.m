/*
 
 Contact editor by memeller@gmail.com
 isSupported function by https://github.com/mateuszmackowiak
 
 */

# import "ContactEditor.h"

FREContext AirCECtx = nil;

@implementation ContactEditor

@synthesize simpleContacts = _simpleContacts;
@synthesize detailedContacts = _detailedContacts;

#pragma mark - Singleton

static ContactEditor *sharedInstance = nil;

+ (ContactEditor *) sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id) copy
{
    return self;
}

#pragma mark - AdressBook methods

- (void) getNumContacts
{
    AppContactsAccessManager *accessManager = [AppContactsAccessManager new];
    [accessManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
        if (available)
        {
            CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            NSString * numContacts = [NSString stringWithFormat:@"%li",CFArrayGetCount(people)];
            CFRelease(people);
            FREDispatchStatusEventAsync(AirCECtx, (const uint8_t*)"NUM_CONTACT_UPDATED",(const uint8_t*) [numContacts UTF8String]);
        }
        else {
            FREDispatchStatusEventAsync(AirCECtx, (const uint8_t*)"ADDRESS_BOOK_ACCESS_DENIED", (const uint8_t*)"ERROR");
        }
    }];
}

- (void) getSimpleContactsWithBatchStart:(NSInteger)batchStart batchLength:(NSInteger)batchLength
{
    AppContactsAccessManager *accessManager = [AppContactsAccessManager new];
    [accessManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
        
        // Start by initializaing our contact array
        self.simpleContacts = [[NSMutableArray alloc] init];
        
        if (available)
        {
            int numContactsProcessed = 0;
            int indexCurrentContact = batchStart;
            
            DLog(@" will extract contacts from batchStart %i with batchLength %i", batchStart, batchLength);
            
            CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            while( numContactsProcessed < batchLength )
            {
                ABRecordRef contact = CFArrayGetValueAtIndex(contacts, indexCurrentContact);
                NSMutableDictionary *contactDict = [[NSMutableDictionary alloc] initWithCapacity:2];
                
                // Record Id
                NSNumber *recordId = [NSNumber numberWithInt:ABRecordGetRecordID(contact)];
                [contactDict setObject:recordId forKey:@"recordId"];
                
                // Composite Name
                CFStringRef compositeName = ABRecordCopyCompositeName(contact);
                if (compositeName) {
                    [contactDict setObject:[NSString stringWithString:CFBridgingRelease(compositeName)] forKey:@"compositename"];
                } else {
                    [contactDict setObject:[NSNull null] forKey:@"compositename"];
                }
                
                [self.simpleContacts addObject:contactDict];
                
                DLog(@"Contact # %i processed",indexCurrentContact);
                
                indexCurrentContact++;
                numContactsProcessed++;
            }
            
            DLog(@"Extracted contacts.  Currently simpleContacts holds %i entries", [self.simpleContacts count]);
     
            CFRelease(contacts);
            FREDispatchStatusEventAsync(AirCECtx, (const uint8_t*)"SIMPLE_CONTACTS_UPDATED", (const uint8_t*)"OK");
        }
        else
        {
            FREDispatchStatusEventAsync(AirCECtx, (const uint8_t*)"ADDRESS_BOOK_ACCESS_DENIED", (const uint8_t*)"ERROR");
        }
    }];
}

- (void) getDetailedContactWithRecordId:(int)recordId
{
    AppContactsAccessManager *accessManager = [AppContactsAccessManager new];
    [accessManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
        if (available)
        {
            DLog(@"Retrieving ABRecordRef for contact at position %i",recordId);
        
            // Change initWithCapacity parameter as you add/remove parameters
            NSMutableDictionary *contactDict = [[NSMutableDictionary alloc] initWithCapacity:7];
            
            ABRecordRef contact = ABAddressBookGetPersonWithRecordID(addressBookRef, recordId);
            
            if ( contact != NULL )
            {
                // Record ID
                int recordIdInt = (int) ABRecordGetRecordID(contact);
                [contactDict setObject:[NSNumber numberWithInt:recordIdInt] forKey:@"recordId"];
                
                // Composite Name
                CFStringRef compositeName = ABRecordCopyCompositeName(contact);
                if (compositeName) {
                    [contactDict setObject:[NSString stringWithString:CFBridgingRelease(compositeName)]
                                    forKey:@"compositename"];
                } else {
                    [contactDict setObject:[NSNull null] forKey:@"compositename"];
                }
                
                // First Name
                CFStringRef firstName = ABRecordCopyValue(contact, kABPersonFirstNameProperty);
                if (firstName) {
                    [contactDict setObject:[NSString stringWithString:CFBridgingRelease(firstName)]
                                    forKey:@"firstName"];
                } else {
                    [contactDict setObject:[NSNull null] forKey:@"firstName"];
                }
                
                // Last Name
                CFStringRef lastName = ABRecordCopyValue(contact, kABPersonLastNameProperty);
                if (lastName) {
                    [contactDict setObject:[NSString stringWithString:CFBridgingRelease(lastName)]
                                    forKey:@"lastName"];
                } else {
                    [contactDict setObject:[NSNull null] forKey:@"lastName"];
                }
                
                // Emails
                ABMultiValueRef emails = ABRecordCopyValue(contact, kABPersonEmailProperty);
                if (emails) {
                    NSMutableArray *emailArr = [NSMutableArray arrayWithCapacity:ABMultiValueGetCount(emails)];
                    for (CFIndex i =0; i < ABMultiValueGetCount(emails); i++)
                    {
                        [emailArr insertObject:(NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, i))
                                       atIndex:i];
                    }
                    CFRelease(emails);
                    [contactDict setObject:emailArr forKey:@"emails"];
                } else {
                    [contactDict setObject:[NSNull null] forKey:@"emails"];
                }
                
                // Phones
                ABMultiValueRef phones = ABRecordCopyValue(contact, kABPersonPhoneProperty);
                if (phones) {
                    NSMutableArray *phonesArr = [NSMutableArray arrayWithCapacity:ABMultiValueGetCount(phones)];
                    for (CFIndex i =0; i < ABMultiValueGetCount(phones); i++)
                    {
                        [phonesArr insertObject:(NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, i))
                                        atIndex:i];
                    }
                    CFRelease(phones);
                    [contactDict setObject:phonesArr forKey:@"phones"];
                } else {
                    [contactDict setObject:[NSNull null] forKey:@"phones"];
                }
                
                // Facebook Username
                ABMultiValueRef socialNetworkInfo = ABRecordCopyValue(contact, kABPersonSocialProfileProperty);
                if (socialNetworkInfo) {
                    for (CFIndex i =0; i < ABMultiValueGetCount(socialNetworkInfo); i++)
                    {
                        NSDictionary *socialData = CFBridgingRelease(ABMultiValueCopyValueAtIndex(socialNetworkInfo, i));
                        if ([socialData[@"service"] isEqualToString:(__bridge NSString*)kABPersonSocialProfileServiceFacebook])
                        {
                            [contactDict setObject:(NSString*)socialData[@"username"]
                                            forKey:@"facebookInfo"];
                        }
                    }
                    CFRelease(socialNetworkInfo);
                } else {
                    [contactDict setObject:[NSNull null] forKey:@"facebookInfo"];
                }
                
                // Add to list of detailed contacts
                if (self.detailedContacts == nil) {
                    self.detailedContacts = [[NSMutableArray alloc] init];
                }
                [self.detailedContacts addObject:contactDict];
                
                // dispatch event letting the AS3 side know that we are done.
                NSString *recordIsStr = [NSString stringWithFormat:@"%d",recordIdInt];
                FREDispatchStatusEventAsync(AirCECtx,
                                            (const uint8_t*)"DETAILED_CONTACT_UPDATED",
                                            (const uint8_t*)[recordIsStr UTF8String]);
                
            }
        }
        else
        {
            FREDispatchStatusEventAsync(AirCECtx, (const uint8_t*)"ADDRESS_BOOK_ACCESS_DENIED", (const uint8_t*)"ERROR");
        }
    }];
    
}

@end

// C API

DEFINE_ANE_FUNCTION(getContactsSimple)
{
    DLog(@"Entering getContactsSimple");
    
    int batchStartInt;
    FREGetObjectAsInt32(argv[0], &batchStartInt);
    NSInteger batchStart = batchStartInt;
    
    int batchLengthInt;
    FREGetObjectAsInt32(argv[1], &batchLengthInt);
    NSInteger batchLength = batchLengthInt;
    
    [[ContactEditor sharedInstance] getSimpleContactsWithBatchStart:batchStart batchLength:batchLength];
    
    DLog(@"Exiting getContactsSimple");
    return NULL;
}

DEFINE_ANE_FUNCTION(getContactDetails)
{
    DLog(@"Entering getContactDetails");
    
    int recordId ;
    uint32_t argRecordId;
    if (FREGetObjectAsUint32(argv[0], &argRecordId) == FRE_OK)
    {
        recordId = argRecordId;
        [[ContactEditor sharedInstance] getDetailedContactWithRecordId:recordId];
    }
    else
    {
        FREDispatchStatusEventAsync(AirCECtx, (const uint8_t*)"INVALID_RECORD_ID", (const uint8_t*)"not a valid param");
    }
    
    DLog(@"Exiting getContactDetails");
    return NULL;
}

DEFINE_ANE_FUNCTION(getContactCount)
{
    DLog(@"Entering getContactCount");
    
    [[ContactEditor sharedInstance] getNumContacts];
    
    DLog(@"Exiting getContactCount");
    return NULL;
}

// Functions that return values (Async)

DEFINE_ANE_FUNCTION(retrieveSimpleContacts)
{
    DLog(@"Entering retrieveSimpleContacts");
    
    // Retrieve the contacts
    NSMutableArray * simpleContacts = [[ContactEditor sharedInstance] simpleContacts];
    
    DLog(@"Retrieved contacts.  Currently simpleContacts holds %i entries", [simpleContacts count]);
    
    // Create the AS3 Array
    FREObject simpleContactsArr;
    FRENewObject((const uint8_t *)"Array", 0, NULL, &simpleContactsArr, nil);
    FRESetArrayLength(simpleContactsArr, [simpleContacts count]);
    
    // Iterate over the contacts
    for ( int i = 0; i < [simpleContacts count]; i++ )
    {
        // Extract the contact
        NSDictionary *contactDict = [simpleContacts objectAtIndex:i];
        
        // Create the ActionScript Contact object
        FREObject contact = NULL;
        FRENewObject((const uint8_t*)"Object", 0, NULL, &contact, NULL);
        
        // record id
        FREObject personId;
        NSNumber *recordId = [contactDict valueForKey:@"recordId"];
        FRENewObjectFromInt32(recordId.integerValue, &personId);
        FRESetObjectProperty(contact, (const uint8_t*) "recordId", personId, NULL);
        
        // composite name
        NSString *compositeNameStr = [contactDict valueForKey:@"compositename"];
        if ( (NSNull*)compositeNameStr != [NSNull null] ) {
            FREObject compositeName;
            FRENewObjectFromUTF8(strlen([compositeNameStr UTF8String]) + 1,
                                 (const uint8_t*) [compositeNameStr UTF8String],
                                 &compositeName);
            FRESetObjectProperty(contact, (const uint8_t*) "compositename", compositeName, NULL);
        } else {
            FRESetObjectProperty(contact, (const uint8_t*) "compositename", NULL, NULL);
        }
        
        // Add to Array
        FRESetArrayElementAt(simpleContactsArr, i, contact);
    }
    
    DLog(@"Exiting retrieveSimpleContacts");
    return simpleContactsArr;
}

DEFINE_ANE_FUNCTION(retrieveContactDetails)
{
    DLog(@"Entering retrieveContactDetails");
    
    NSMutableDictionary *contactDict = [[[ContactEditor sharedInstance] detailedContacts] objectAtIndex:0];
    [[[ContactEditor sharedInstance] detailedContacts] removeObjectAtIndex:0];
    
    FREObject stringValue = NULL;
    FREObject contact = NULL;
    FRENewObject((const uint8_t*)"Object", 0, NULL, &contact, NULL);
    
    // Record ID
    FREObject personId;
    NSNumber *recordId = [contactDict valueForKey:@"recordId"];
    FRENewObjectFromInt32(recordId.integerValue, &personId);
    FRESetObjectProperty(contact, (const uint8_t*) "recordId", personId, NULL);
    
    // Composite Name
    NSString * compositeName = [contactDict valueForKey:@"compositename"];
    if ( (NSNull*)compositeName != [NSNull null] ) {
        DLog(@"compositename = %@",compositeName);
        FRENewObjectFromUTF8(strlen([compositeName UTF8String])+1,
                             (const uint8_t*)[compositeName UTF8String],
                             &stringValue);
        FRESetObjectProperty(contact, (const uint8_t*)"compositename", &stringValue, NULL);
    } else {
        FRESetObjectProperty(contact, (const uint8_t*)"compositename", NULL, NULL);
    }

    // First name
    stringValue = NULL;
    NSString * firstName = [contactDict valueForKey:@"firstName"];
    if ( (NSNull*)firstName != [NSNull null] ) {
        DLog(@"firstName = %@",firstName);
        FRENewObjectFromUTF8(strlen([firstName UTF8String])+1,
                             (const uint8_t*)[firstName UTF8String],
                             &stringValue);
        FRESetObjectProperty(contact, (const uint8_t*)"name", &stringValue, NULL);
    } else {
        FRESetObjectProperty(contact, (const uint8_t*)"name", NULL, NULL);
    }
    
    // Last name
    stringValue = NULL;
    NSString * lastName = [contactDict valueForKey:@"lastName"];
    if ( (NSNull*)lastName != [NSNull null] ) {
        DLog(@"lastName = %@",firstName);
        FRENewObjectFromUTF8(strlen([lastName UTF8String])+1,
                             (const uint8_t*)[lastName UTF8String],
                             &stringValue);
        FRESetObjectProperty(contact, (const uint8_t*)"lastname", &stringValue, NULL);
    } else {
        FRESetObjectProperty(contact, (const uint8_t*)"lastname", NULL, NULL);
    }
    
    // Emails
    stringValue = NULL;
    NSMutableArray *emails = [contactDict valueForKey:@"emails"];
    if ( (NSNull*)emails != [NSNull null] ) {
        FREObject emailsArray = NULL;
        FRENewObject((const uint8_t *)"Array", 0, NULL, &emailsArray, NULL);
        FRESetArrayLength(emailsArray, [emails count]);
        for (int i=0; i < [emails count]; i++)
        {
            NSString *email = [emails objectAtIndex:i];
            DLog(@"email[%d] = %@",i,email);
            if (email) {
                FRENewObjectFromUTF8(strlen([email UTF8String]+1),
                                     (const uint8_t*) [email UTF8String],
                                     &stringValue);
                FRESetArrayElementAt(emailsArray, i, stringValue);
            }
        }
        FRESetObjectProperty(contact, (const uint8_t*) "emails", emailsArray, NULL);
    } else {
        FRESetObjectProperty(contact, (const uint8_t*) "emails", NULL, NULL);
    }
    
    // Phones
    stringValue = NULL;
    NSMutableArray *phones = [contactDict valueForKey:@"phones"];
    if ( (NSNull*)phones != [NSNull null] ) {
        FREObject phonesArray = NULL;
        FRENewObject((const uint8_t *)"Array", 0, NULL, &phonesArray, NULL);
        FRESetArrayLength(phonesArray, [phones count]);
        for (int i=0; i < [phones count]; i++)
        {
            NSString *phone = [phones objectAtIndex:i];
            DLog(@"phone[%d] = %@",i,phone);
            if (phone) {
                FRENewObjectFromUTF8(strlen([phone UTF8String]+1),
                                     (const uint8_t*) [phone UTF8String],
                                     &stringValue);
                FRESetArrayElementAt(phonesArray, i, stringValue);
            }
        }
        FRESetObjectProperty(contact, (const uint8_t*) "phones", phonesArray, NULL);
    } else {
        FRESetObjectProperty(contact, (const uint8_t*) "phones", NULL, NULL);
    }
    
    // Facebook Info
    stringValue = NULL;
    NSString * facebookName = [contactDict valueForKey:@"lastName"];
    if ( (NSNull*)facebookName != [NSNull null] ) {
        DLog(@"facebookName = %@",facebookName);
        FRENewObjectFromUTF8(strlen([facebookName UTF8String])+1,
                             (const uint8_t*)[facebookName UTF8String],
                             &stringValue);
        FRESetObjectProperty(contact, (const uint8_t*)"facebookInfo", &stringValue, NULL);
    } else {
        FRESetObjectProperty(contact, (const uint8_t*)"facebookInfo", NULL, NULL);
    }
    
    DLog(@"Exiting retrieveContactDetails");
    return contact;
}

// ANE SETUP

void ContactEditorContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFunctionsToLink = 5;
    *numFunctionsToTest = nbFunctionsToLink;
    
	FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFunctionsToLink);
    
    func[0].name = (const uint8_t*)"getContactCount";
	func[0].functionData = NULL;
	func[0].function = &getContactCount;
    
    func[1].name = (const uint8_t*)"getContactsSimple";
	func[1].functionData = NULL;
	func[1].function = &getContactsSimple;
    
    func[2].name = (const uint8_t*)"getContactDetails";
	func[2].functionData = NULL;
	func[2].function = &getContactDetails;
        
    func[3].name = (const uint8_t*)"retrieveSimpleContacts";
    func[3].functionData = NULL;
    func[3].function = &retrieveSimpleContacts;
    
    func[4].name = (const uint8_t*)"retrieveDetailedContact";
    func[4].functionData = NULL;
    func[4].function = &retrieveContactDetails;
    
	*functionsToSet = func;
    
    AirCECtx = ctx;
}


void ContactEditorContextFinalizer(FREContext ctx) { }

void ContactEditorExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{	
  	*extDataToSet = NULL;
	*ctxInitializerToSet = &ContactEditorContextInitializer;
	*ctxFinalizerToSet = &ContactEditorContextFinalizer;
} 

void ContactEditorExtFinalizer(void* extData) {}
