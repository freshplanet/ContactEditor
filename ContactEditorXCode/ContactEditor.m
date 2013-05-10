/*
 
 Contact editor by memeller@gmail.com
 isSupported function by https://github.com/mateuszmackowiak
 
 */

# import "ContactEditor.h"

FREContext AirCECtx = nil;

@implementation ContactEditor

@synthesize simpleContacts = _simpleContacts;

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
                CFStringRef compositeName = ABRecordCopyCompositeName(contact);
                
                NSMutableDictionary *contactDict = [[NSMutableDictionary alloc] initWithCapacity:2];
                [contactDict setObject:[NSNumber numberWithInt:(int)ABRecordGetRecordID(contact)] forKey:@"contactId"];
                
                if (compositeName) {
                    [contactDict setObject:[NSString stringWithString:CFBridgingRelease(compositeName)] forKey:@"compositeName"];
                } else {
                    [contactDict setObject:@"" forKey:@"compositeName"];
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

@end

// C API

DEFINE_ANE_FUNCTION(getContactsSimple)
{
    ALog(@"Entering getContactsSimple");
    
    int batchStartInt;
    FREGetObjectAsInt32(argv[0], &batchStartInt);
    NSInteger batchStart = batchStartInt;
    
    int batchLengthInt;
    FREGetObjectAsInt32(argv[1], &batchLengthInt);
    NSInteger batchLength = batchLengthInt;
    
    [[ContactEditor sharedInstance] getSimpleContactsWithBatchStart:batchStart batchLength:batchLength];
    
    ALog(@"Exiting getContactsSimple");
    return NULL;
}

DEFINE_ANE_FUNCTION(getContactDetails)
{
    return NULL;
}

DEFINE_ANE_FUNCTION(isSupported)
{
    return NULL;
}

DEFINE_ANE_FUNCTION(getContactCount)
{
    ALog(@"Entering getContactCount");
    
    [[ContactEditor sharedInstance] getNumContacts];
    
    ALog(@"Exiting getContactCount");
    return NULL;
}

// Functions that return values (Async)

DEFINE_ANE_FUNCTION(retrieveSimpleContacts)
{
    ALog(@"Entering retrieveSimpleContacts");
    
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
        int personIdInt = [contactDict valueForKey:@"contactId"];
        FRENewObjectFromInt32(personIdInt, &personId);
        FRESetObjectProperty(contact, (const uint8_t*) "recordId", personId, NULL);
        
        // composite name
        FREObject compositeName;
        NSString *compositeNameStr = [contactDict valueForKey:@"compositeName"];
        FRENewObjectFromUTF8(strlen([compositeNameStr UTF8String]) + 1,
                             (const uint8_t*) [compositeNameStr UTF8String],
                             &compositeName);
        FRESetObjectProperty(contact, (const uint8_t*) "compositeName", compositeName, NULL);
        
        // Add to Array
        FRESetArrayElementAt(simpleContactsArr, i, contact);
    }
    
    ALog(@"Exiting retrieveSimpleContacts");
    return simpleContactsArr;
}

DEFINE_ANE_FUNCTION(retrieveContactDetails)
{
    return NULL;
}


//FREObject contactEditorIsSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] ){
//    FREObject retVal;
//    if(FRENewObjectFromBool(YES, &retVal) == FRE_OK){
//        return retVal;
//    }else{
//        return nil;
//    }
//}
//
//FREObject hasPermission(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
//{
//    __block FREObject retVal = NULL;
//
//    AppContactsAccessManager *accessMgr = [AppContactsAccessManager new];
//    [accessMgr requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
//        if (available) {
//            FRENewObjectFromBool(YES, &retVal);
//        } else {
//            FRENewObjectFromBool(NO, &retVal);
//        }
//    }];
//    
//    return retVal;
//}
//FREObject getContactDetails(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
//{
//    DLog(@"Entering getContactDetails");
//    
//    DLog(@"Extracting recordId arg sent from AS3");
//    uint32_t argrecordId;
//    __block FREObject contact=NULL;
//    FRENewObject((const uint8_t*)"Object", 0, NULL, &contact,NULL);
//
//    if( FREGetObjectAsUint32(argv[0], &argrecordId) == FRE_OK)
//    {
//        DLog(@"Requesting addressBook access to AppContactAccessManager");
//        AppContactsAccessManager * accessMgr = [AppContactsAccessManager new];
//        [accessMgr requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
//            if( available )
//            {
//                ALog(@"addressBook access available, extracting data from abAddressBook API");
//                FREObject retStr = NULL;
//                
//                DLog(@"Retrieving ABRecordRef for contact at position %i",argrecordId);
//                ABRecordID abrecordId = argrecordId;
//                ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBookRef, abrecordId);
//                
//                // Record ID
//                DLog(@"Inserting recordId into AS3 Contact Object");
//                int personId = (int)ABRecordGetRecordID(person);
//                FREObject recordId;
//                FRENewObjectFromInt32(personId, &recordId);
//                FRESetObjectProperty(contact, (const uint8_t*)"recordId", recordId, NULL);
//                
//                // Composite name
//                DLog(@"Inserting composite name into AS3 Contact Object");
//                CFStringRef personCompositeName = ABRecordCopyCompositeName(person);
//                if(personCompositeName)
//                {
//                    NSString *personCompositeString = [NSString stringWithString:(__bridge NSString *)personCompositeName];
//                    FRENewObjectFromUTF8( strlen([personCompositeString UTF8String])+1,
//                                         (const uint8_t*)[personCompositeString UTF8String],
//                                         &retStr);
//                    FRESetObjectProperty(contact, (const uint8_t*)"compositename", retStr, NULL);
//                    CFRelease(personCompositeName);
//                } else {
//                    FRESetObjectProperty(contact, (const uint8_t*)"compositename", retStr, NULL);
//                }
//                
//                retStr=NULL;
//                
//                // First name
//                DLog(@"Inserting first name into AS3 Contact Object");
//                CFStringRef personName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
//                if(personName)
//                {
//                    NSString *personNameString = [NSString stringWithString:(__bridge NSString *)personName];
//                    DLog(@"Adding first name: %@",personNameString);
//                    FRENewObjectFromUTF8(strlen([personNameString UTF8String])+1,
//                                         (const uint8_t*)[personNameString UTF8String],
//                                         &retStr);
//                    FRESetObjectProperty(contact, (const uint8_t*)"name", retStr, NULL);
//                    CFRelease(personName);
//                } else {
//                    FRESetObjectProperty(contact, (const uint8_t*)"name", retStr, NULL);
//                }
//                
//                retStr=NULL;
//                
//                // Last name or Surname
//                DLog(@"Inserting last name into AS3 Contact Object");
//                CFStringRef personSurName = ABRecordCopyValue(person, kABPersonLastNameProperty);
//                if(personSurName)
//                {
//                    NSString *personSurNameString = [NSString stringWithString:(__bridge NSString *)personSurName];
//                    FRENewObjectFromUTF8(strlen([personSurNameString UTF8String])+1,
//                                         (const uint8_t*)[personSurNameString UTF8String],
//                                         &retStr);
//                    FRESetObjectProperty(contact, (const uint8_t*)"lastname", retStr, NULL);
//                    //[personSurNameString release];
//                    CFRelease(personSurName);
//                } else {
//                    FRESetObjectProperty(contact, (const uint8_t*)"lastname", retStr, NULL);
//                }
//                
//                retStr=NULL;
//                
//                // Birthdate
//                DLog(@"Inserting birthdate into AS3 Contact Object");
//                NSDate *personBirthdate = CFBridgingRelease(ABRecordCopyValue(person, kABPersonBirthdayProperty));
//                if(personBirthdate)
//                {
//                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//                    NSString *personBirthdateString = [dateFormatter stringFromDate:personBirthdate];
//                    FRENewObjectFromUTF8(strlen([personBirthdateString UTF8String])+1,
//                                         (const uint8_t*)[personBirthdateString UTF8String],
//                                         &retStr);
//                    FRESetObjectProperty(contact, (const uint8_t*)"birthdate", retStr, NULL);
//                } else {
//                    FRESetObjectProperty(contact, (const uint8_t*)"birthdate", retStr, NULL);
//                }
//                
//                retStr=NULL;
//                
//                // Emails
//                DLog(@"Inserting emails into AS3 Contact Object");
//                FREObject emailsArray = NULL;
//                FRENewObject( (const uint8_t*) "Array", 0, NULL, &emailsArray, nil);
//                ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
//                if(emails)
//                {
//                    for (CFIndex k=0; k < ABMultiValueGetCount(emails); k++)
//                    {
//                        NSString* email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, k));
//                        FRENewObjectFromUTF8(strlen([email UTF8String])+1, (const uint8_t*)[email UTF8String], &retStr);
//                        FRESetArrayElementAt(emailsArray, k, retStr);
//                    }
//                    CFRelease(emails);
//                    FRESetObjectProperty(contact, (const uint8_t*)"emails", emailsArray, NULL);
//                } else {
//                    FRESetObjectProperty(contact, (const uint8_t*)"emails", NULL, NULL);
//                }
//                
//                retStr=NULL;
//                
//                // Phone Numbers
//                DLog(@"Inserting phone numbers into AS3 Contact Object");
//                FREObject phonesArray = NULL;
//                FRENewObject((const uint8_t*)"Array", 0, NULL, &phonesArray, nil);
//                ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
//                if(phones)
//                {
//                    for (CFIndex k=0; k < ABMultiValueGetCount(phones); k++)
//                    {
//                        NSString* phone = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, k));
//                        FRENewObjectFromUTF8(strlen([phone UTF8String])+1, (const uint8_t*)[phone UTF8String], &retStr);
//                        FRESetArrayElementAt(phonesArray, k, retStr);
//                    }
//                    CFRelease(phones);
//                    FRESetObjectProperty(contact, (const uint8_t*)"phones", phonesArray, NULL);
//                } else {
//                    FRESetObjectProperty(contact, (const uint8_t*)"phones", NULL, NULL);
//                }
//                
//                retStr=NULL;
//                
//                // Facebook Information: username
//                DLog(@"Inserting Facebook information into AS3 Contact Object");
//                ABMultiValueRef socialMulti = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
//                if(socialMulti)
//                {
//                    for (CFIndex i = 0; i < ABMultiValueGetCount(socialMulti); i++)
//                    {
//                        NSDictionary *socialData = CFBridgingRelease(ABMultiValueCopyValueAtIndex(socialMulti, i));
//                        if ([socialData[@"service"] isEqualToString:(__bridge NSString*)kABPersonSocialProfileServiceFacebook])
//                        {
//                            NSString *facebookInfoString = (NSString*) socialData[@"username"];
//                            FRENewObjectFromUTF8( strlen([facebookInfoString UTF8String])+1,
//                                                 (const uint8_t*)[facebookInfoString UTF8String],
//                                                 &retStr);
//                            FRESetObjectProperty(contact, (const uint8_t*)"facebookInfo", retStr, NULL);
//                        }
//                    }
//                    CFRelease(socialMulti);
//                } else {
//                    FRESetObjectProperty(contact, (const uint8_t*)"facebookInfo", retStr, NULL);
//                }
//                
//                // Address Book Contact Addressses will be added later... (see git history)
//                
//                ALog(@"Extracted all information from abAddressBook API.  Returning to AS3 side of NativeExtension");
//                
//                
//                // Dispatch event
//                detailedContact = contact;
//                FREDispatchStatusEventAsync(ctx, (const uint8_t*)"detailedContactReady", (const uint8_t *)"OK");
//            }
//        }];
//    }
//    
//    DLog(@"Exiting getContactDetails");
//    return NULL;
//}
//
//
//
//
//FREObject retrieveSimpleContacts(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
//{
//    ALog(@"Entering retrieveSimpleContacts");
//    
//    if (simpleContacts != NULL) {
//        ALog(@"Exiting retrieveSimpleContacts");
//        return simpleContacts;
//    } else {
//        ALog(@"Exiting retrieveSimpleContacts (simpleContacts NULL)");
//        return NULL;
//    }
//}
//
//FREObject retrieveDetailedContact(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
//{
//    ALog(@"Entering retrieveDetailedContact");
//    
//    if (detailedContact != NULL) {
//        ALog(@"Exiting retrieveDetailedContact");
//        return detailedContact;
//    } else {
//        ALog(@"Exiting retrieveDetailedContact (detailedContact NULL)");
//        return NULL;
//    }
//}


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
