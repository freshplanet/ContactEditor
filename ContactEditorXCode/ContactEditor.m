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
            [ContactEditor dispatchFREEvent:@"NUM_CONTACT_UPDATED" withLevel:numContacts];
        }
        else {
            [ContactEditor dispatchFREEvent:@"ADDRESS_BOOK_ACCESS_DENIED" withLevel:@"ERROR"];
        }
    }];
}

- (void) getSimpleContactsWithRange:(NSValue*)range
{
    
    NSRange rangeValue=[range rangeValue];
    NSUInteger batchStart = rangeValue.location ;
    NSUInteger batchLength = rangeValue.length ;
    
    AppContactsAccessManager *accessManager = [AppContactsAccessManager new];
    [accessManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
        
        // Start by initializaing our contact array
        if (self.simpleContacts == nil)
        {
            self.simpleContacts = [[NSMutableArray alloc] init];
        }
        
        NSString* batchId = [NSString stringWithFormat:@"%i-%i",batchStart,batchLength];
        
        if (available)
        {
            int numContactsProcessed = 0;
            int indexCurrentContact = batchStart;
            
            [ContactEditor log:@"will extract contacts from batchStart %i with batchLength %i", batchStart, batchLength];
            
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
                
                [ContactEditor log:@"Contact # %i processed",indexCurrentContact];
                
                indexCurrentContact++;
                numContactsProcessed++;
            }
            
            [ContactEditor log:@"Extracted contacts.  Currently simpleContacts holds %i entries", [self.simpleContacts count]];
     
            CFRelease(contacts);
            
            [ContactEditor dispatchFREEvent:@"SIMPLE_CONTACTS_UPDATED" withLevel:batchId];
        }
        else
        {
            [ContactEditor dispatchFREEvent:@"ADDRESS_BOOK_ACCESS_DENIED" withLevel:@"ERROR"];
        }
    }];
}

- (void) getDetailedContactWithRecordId:(int)recordId andCompletion:(DetailedContactCompletion) completion
{
    AppContactsAccessManager *accessManager = [AppContactsAccessManager new];
    
    [accessManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
        if (available)
        {
            [ContactEditor log:@"Retrieving ABRecordRef for contact at position %i", recordId];
            
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
                
                // Add to list of detailed contacts
                if (self.detailedContacts == nil) {
                    self.detailedContacts = [[NSMutableArray alloc] init];
                }
                [self.detailedContacts addObject:contactDict];
                
                completion( true ) ;
                
            }
        }
        else
        {
            completion( false ) ;
        }
    }];
    
}

- (void) getDetailedContactsWithRecordIds:(NSArray*)records;
{
    
    [ContactEditor log:@"in getDetailedContactsWithRecordIds"] ;
    
    __block uint32_t batchLength = [records count];
    
    for ( NSNumber *record in records) {
        [[ContactEditor sharedInstance] getDetailedContactWithRecordId:[record intValue]
                                                         andCompletion:^(BOOL success){
                                                             if( success )
                                                             {
                                                                 if( --batchLength == 0)
                                                                 {
                                                                     [ContactEditor dispatchFREEvent:@"DETAILED_CONTACTS_UPDATED" withLevel:@""];
                                                                 }
                                                             }
                                                             else
                                                             {
                                                                 [ContactEditor dispatchFREEvent:@"ADDRESS_BOOK_ACCESS_DENIED" withLevel:@"ERROR"];
                                                             }
                                                         }
         ] ;
    }
    
}

+ (void)log:(NSString *)format, ...
{
    @try
    {
        va_list args;
        va_start(args, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(@"[ContactEditor] %@", string);
        [ContactEditor dispatchFREEvent:@"LOGGING"withLevel:string];
    }
    @catch (NSException *exception)
    {
        NSLog(@"[ContactEditor] Couldn't log message. Exception: %@", exception);
    }
}

+ (void)dispatchFREEvent:(NSString *)code withLevel:(NSString *)level
{
    FREDispatchStatusEventAsync(AirCECtx, (const uint8_t *)[code UTF8String], (const uint8_t *)[level UTF8String]);
}

@end

#pragma mark - Utils

NSArray* getFREArrayOfUInt( FREObject array )
{
    
    [ContactEditor log:@"converting FREArray"];
    
    uint32_t arrayLength;
    
    NSMutableArray *nsArray = [[NSMutableArray alloc] init];
    if (FREGetArrayLength(array, &arrayLength) != FRE_OK)
    {
        arrayLength = 0;
    }
    
    for (NSInteger i = arrayLength-1; i >= 0; i--)
    {
        [ContactEditor log:@"convert element #%d",i];
        FREObject el;
        if (FREGetArrayElementAt(array, i, &el) != FRE_OK)
        {
            continue;
        }
        
        // Convert it to int. Skip this index if there's an error.
        uint32_t elInt;
        if (FREGetObjectAsUint32(el, &elInt) != FRE_OK)
        {
            continue;
        }
        
        // Add the element to the array
        [nsArray addObject:[NSNumber numberWithInt:elInt]];
    }
    
    [ContactEditor log:@"end converting FREArray"];
    
    return nsArray;
    
}

#pragma mark - C Interface

DEFINE_ANE_FUNCTION(getContactsSimple)
{
    DLog(@"Entering getContactsSimple");
    
    int batchStartInt;
    FREGetObjectAsInt32(argv[0], &batchStartInt);
    NSUInteger batchStart = batchStartInt;
    
    int batchLengthInt;
    FREGetObjectAsInt32(argv[1], &batchLengthInt);
    NSUInteger batchLength = batchLengthInt;
    
    NSValue *batchRange = [NSValue valueWithRange:NSMakeRange(batchStart, batchLength)] ;
    
    [[ContactEditor sharedInstance] performSelectorInBackground:@selector(getSimpleContactsWithRange:) withObject:batchRange];
    
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
        
        [[ContactEditor sharedInstance] getDetailedContactWithRecordId:recordId andCompletion: ^(BOOL success){
                if ( success )
                {
                    [ContactEditor dispatchFREEvent:@"DETAILED_CONTACT_UPDATED" withLevel:@""];
                }
                else
                {
                    [ContactEditor dispatchFREEvent:@"ADDRESS_BOOK_ACCESS_DENIED" withLevel:@"ERROR"];
                }
            }
         ];
    }
    else
    {
        FREDispatchStatusEventAsync(AirCECtx, (const uint8_t*)"INVALID_RECORD_ID", (const uint8_t*)"not a valid param");
    }
    
    DLog(@"Exiting getContactDetails");
    return NULL;
}

DEFINE_ANE_FUNCTION(getContactsDetails)
{
    DLog(@"Entering getContactsDetails");
    
    [ContactEditor log:@"Entering getContactsDetails"] ;
    
    NSArray *records = getFREArrayOfUInt( argv[0] );
    
    [[ContactEditor sharedInstance] getDetailedContactsWithRecordIds:records];
    //[[ContactEditor sharedInstance] performSelectorInBackground:@selector(getDetailedContactsWithRecordIds:) withObject:records];
    
    DLog(@"Exiting getContactsDetails");
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
    
    // Retrieve the batch's parameters
    int batchStartInt;
    int batchLengthInt;
    FREGetObjectAsInt32(argv[0], &batchStartInt);
    FREGetObjectAsInt32(argv[1], &batchLengthInt);
    
    // Create the AS3 Array
    FREObject simpleContactsArr = NULL;
    FRENewObject((const uint8_t *)"Array", 0, NULL, &simpleContactsArr, NULL);
    if (FRESetArrayLength(simpleContactsArr, batchLengthInt) == FRE_OK)
    {
        // Iterate over the contacts
        int i = batchStartInt;
        int numContactsProcessed = 0;
        while( numContactsProcessed < batchLengthInt )
        {
            // Extract the contact
            NSDictionary *contactDict = [[[ContactEditor sharedInstance] simpleContacts] objectAtIndex:i];
            
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
            FRESetArrayElementAt(simpleContactsArr, numContactsProcessed, contact);
            
            i++;
            numContactsProcessed++;
        }
    }
    else
    {
        DLog(@"something went wrong");
    }
    
    DLog(@"Exiting retrieveSimpleContacts");
    return simpleContactsArr;
}

FREObject* contactToFREObject( NSMutableDictionary* contactDict )
{
    FREObject stringValue = NULL;
    FREObject contact = NULL;
    FRENewObject((const uint8_t*)"Object", 0, NULL, &contact, NULL);
    
    // Record ID
    FREObject personId;
    NSNumber *recordId = [contactDict valueForKey:@"recordId"];
    FRENewObjectFromInt32(recordId.integerValue, &personId);
    FRESetObjectProperty(contact, (const uint8_t*) "recordId", personId, NULL);
    DLog(@"record id = %@",recordId);
    
    // Composite Name
    NSString * compositeName = [contactDict valueForKey:@"compositename"];
    if ( (NSNull*)compositeName != [NSNull null] ) {
        DLog(@"compositename = %@",compositeName);
        FRENewObjectFromUTF8(strlen([compositeName UTF8String])+1,
                             (const uint8_t*)[compositeName UTF8String],
                             &stringValue);
        FRESetObjectProperty(contact, (const uint8_t*)"compositename", stringValue, NULL);
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
        FRESetObjectProperty(contact, (const uint8_t*)"name", stringValue, NULL);
    } else {
        FRESetObjectProperty(contact, (const uint8_t*)"name", NULL, NULL);
    }
    
    // Last name
    stringValue = NULL;
    NSString * lastName = [contactDict valueForKey:@"lastName"];
    if ( (NSNull*)lastName != [NSNull null] ) {
        DLog(@"lastName = %@",lastName);
        FRENewObjectFromUTF8(strlen([lastName UTF8String])+1,
                             (const uint8_t*)[lastName UTF8String],
                             &stringValue);
        FRESetObjectProperty(contact, (const uint8_t*)"lastname", stringValue, NULL);
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
                FRENewObjectFromUTF8(strlen([email UTF8String])+1,
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
                FRENewObjectFromUTF8(strlen([phone UTF8String])+1,
                                     (const uint8_t*) [phone UTF8String],
                                     &stringValue);
                FRESetArrayElementAt(phonesArray, i, stringValue);
            }
        }
        FRESetObjectProperty(contact, (const uint8_t*) "phones", phonesArray, NULL);
    } else {
        FRESetObjectProperty(contact, (const uint8_t*) "phones", NULL, NULL);
    }
    
    DLog(@"Exiting retrieveContactDetails");
    return contact;
}

DEFINE_ANE_FUNCTION(retrieveContactDetails)
{
    DLog(@"Entering retrieveContactDetails");
    
    NSMutableDictionary *contactDict = [[[ContactEditor sharedInstance] detailedContacts] objectAtIndex:0];
    [[[ContactEditor sharedInstance] detailedContacts] removeObjectAtIndex:0];
    
    return contactToFREObject( contactDict );
}

DEFINE_ANE_FUNCTION(retrieveAllDetails)
{
    DLog(@"Entering retrieveContactDetails");
    
    FREObject contacts = NULL;
    FRENewObject((const uint8_t *)"Array", 0, NULL, &contacts, NULL);
    uint32_t contactsLength = [[[ContactEditor sharedInstance] detailedContacts] count];
    FRESetArrayLength(contacts, contactsLength);
    for (int i=0; i < contactsLength; i++)
    {
        NSMutableDictionary *contactDict = [[[ContactEditor sharedInstance] detailedContacts] objectAtIndex:i];
        FRESetArrayElementAt(contacts, i, contactToFREObject(contactDict));
    }
    
    [[[ContactEditor sharedInstance] detailedContacts] removeObjectAtIndex:0];
    
    return contacts;
}

// ANE SETUP

void ContactEditorContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFunctionsToLink = 7;
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
    
    func[3].name = (const uint8_t*)"getContactsDetails";
    func[3].functionData = NULL;
    func[3].function = &getContactsDetails;
    
    func[4].name = (const uint8_t*)"retrieveSimpleContacts";
    func[4].functionData = NULL;
    func[4].function = &retrieveSimpleContacts;
    
    func[5].name = (const uint8_t*)"retrieveDetailedContact";
    func[5].functionData = NULL;
    func[5].function = &retrieveContactDetails;
    
    func[6].name = (const uint8_t*)"retrieveAllDetails";
    func[6].functionData = NULL;
    func[6].function = &retrieveAllDetails;
    
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
