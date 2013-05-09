/*
 
 Contact editor by memeller@gmail.com
 isSupported function by https://github.com/mateuszmackowiak
 
 */
#import "ContactEditor.h"
#import "ContactEditorHelper.h"
#import "ContactEditorAddContactHelper.h"
#import "ContactEditorViewDetailsHelper.h"
@implementation ContactEditor

ContactEditorHelper *contactEditorHelper;
ContactEditorViewDetailsHelper *contactEditorViewDetailsHelper;
ContactEditorAddContactHelper *contactEditorAddContactHelper;

FREObject showContactDetailsInWindow(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] )
{
//    DLog(@"showing contact details using native window");
//    if (!contactEditorViewDetailsHelper) {
//        contactEditorViewDetailsHelper = [[ContactEditorViewDetailsHelper alloc] init];
//    }
//    uint32_t recordId;
//    if(FRE_OK==FREGetObjectAsUint32(argv[0], &recordId))
//    {
//        uint32_t boolean;
//        FREGetObjectAsBool(argv[1], &boolean);
//        if(newCreateOwnAddressBook())
//        {
//            ABRecordID abrecordId=recordId;
//            ABRecordRef aRecord = ABAddressBookGetPersonWithRecordID([ContactEditor addressBook], abrecordId);
//            if(aRecord)
//            {
//                [contactEditorViewDetailsHelper setContext:ctx];
//                [contactEditorViewDetailsHelper showContactDetailsInWindow:aRecord isEditable:boolean];
//            }
//        }
//        
//    }
//    [ContactEditor releaseAddressBook];
    return NULL;
}
FREObject addContactInWindow(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] )
{
//    DLog(@"adding contact using native window");
//    if(newCreateOwnAddressBook())
//    {
//        if (!contactEditorAddContactHelper) {
//            contactEditorAddContactHelper = [[ContactEditorAddContactHelper alloc] init];
//        }
//    
//        [contactEditorAddContactHelper setContext:ctx];
//        [contactEditorAddContactHelper addContactInWindow];
//    
//    }
//    [ContactEditor releaseAddressBook];
    return NULL;
}
FREObject showContactPicker(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] )
{
//    if(newCreateOwnAddressBook())
//    {
//        if (!contactEditorHelper) {
//            contactEditorHelper = [[ContactEditorHelper alloc] init];
//        }
//    
//        [contactEditorHelper setContext:ctx];
//        [contactEditorHelper showContactPicker];
//    }
//    [ContactEditor releaseAddressBook];
    return NULL;
}
FREObject removeContact(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
//    FREObject retBool = nil;
//    uint32_t boolean=0;
//    uint32_t recordId;
//    if(FRE_OK==FREGetObjectAsUint32(argv[0], &recordId))
//    {
//        if(newCreateOwnAddressBook())
//        {
//            ABRecordID abrecordId=recordId;
//            ABRecordRef aRecord = ABAddressBookGetPersonWithRecordID([ContactEditor addressBook], abrecordId);
//            if(aRecord)
//            {
//                DLog(@"record found, trying to remove %i",abrecordId);
//                ABAddressBookRemoveRecord([ContactEditor addressBook], aRecord, NULL);
//                    // CFRelease(aRecord);
//                    boolean=1;
//                DLog(@"ContactRemoved");
//            }
//            if(ABAddressBookHasUnsavedChanges)
//                ABAddressBookSave([ContactEditor addressBook], NULL);
//            DLog(@"Release");
////            CFRelease(addressBook);
//            DLog(@"Return data");
//        }
//    }
//    else
//        DLog(@"something wrong with value");
//    DLog(@"setting returned value");
//    FRENewObjectFromBool(boolean, &retBool);
//    return retBool;
    return NULL;
    
}
FREObject contactEditorIsSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] ){
    FREObject retVal;
    if(FRENewObjectFromBool(YES, &retVal) == FRE_OK){
        return retVal;
    }else{
        return nil;
    }
}
FREObject addContact(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
//    if(newCreateOwnAddressBook())
//    {
//	uint32_t usernameLength;
//    const uint8_t *name;
//    uint32_t surnameLength;
//    const uint8_t *surname;
//    uint32_t usercontactLength;
//    const uint8_t *contact;
//    uint32_t usercompanyLength;
//    const uint8_t *company;
//    uint32_t useremailLength;
//    const uint8_t *email;
//	uint32_t websiteLength;
//    const uint8_t *website;
//	DLog(@"Parsing data...");
//    //Turn our actionscrpt code into native code.
//    FREGetObjectAsUTF8(argv[0], &usernameLength, &name);
//    FREGetObjectAsUTF8(argv[1], &surnameLength, &surname);
//    FREGetObjectAsUTF8(argv[2], &usercontactLength, &contact);
//    FREGetObjectAsUTF8(argv[3], &usercompanyLength, &company);
//    FREGetObjectAsUTF8(argv[4], &useremailLength, &email);
//	FREGetObjectAsUTF8(argv[5], &websiteLength, &website);
//    NSString *username = nil;
//    NSString *usersurname=nil;
//    NSString *usercontact = nil;
//    NSString *usercompany = nil;
//    NSString *useremail = nil;
//    NSString *userwebsite = nil;
//    DLog(@"Creating strings");
//    //Create NSStrings from CStrings
//    if (FRE_OK == FREGetObjectAsUTF8(argv[0], &usernameLength, &name)) {
//        username = [NSString stringWithUTF8String:(char*)name];
//    }
//    if (FRE_OK == FREGetObjectAsUTF8(argv[1], &surnameLength, &name)) {
//        usersurname = [NSString stringWithUTF8String:(char*)surname];
//    }
//    if (FRE_OK == FREGetObjectAsUTF8(argv[2], &usercontactLength, &contact)) {
//        usercontact = [NSString stringWithUTF8String:(char*)contact];
//    }
//    
//    if (FRE_OK == FREGetObjectAsUTF8(argv[3], &usercompanyLength, &company)) {
//        usercompany = [NSString stringWithUTF8String:(char*)company];
//    }
//    
//    if (argc >= 4 && (FRE_OK == FREGetObjectAsUTF8(argv[4], &useremailLength, &email))) {
//        useremail = [NSString stringWithUTF8String:(char*)email];
//    }
//    
//    if (argc >= 5 && (FRE_OK == FREGetObjectAsUTF8(argv[5], &websiteLength, &website))) {
//        userwebsite = [NSString stringWithUTF8String:(char*)website];
//    }
//    
//    ABRecordRef aRecord = ABPersonCreate(); 
//    CFErrorRef  anError = NULL;
//    
//    DLog(@"Adding name");
//    // Username
//    ABRecordSetValue(aRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(username), &anError);
//    ABRecordSetValue(aRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(usersurname), &anError);
//    // Phone Number.
//    if(usercontact)
//    {
//        DLog(@"Adding phone number");
//        ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
//        ABMultiValueAddValueAndLabel(multi, (__bridge CFStringRef)usercontact, kABWorkLabel, NULL);
//        ABRecordSetValue(aRecord, kABPersonPhoneProperty, multi, &anError);
//        //    CFRelease(multi);
//    }
//    // Company
//    DLog(@"Adding company");
//    if(usercompany)
//    {
//        ABRecordSetValue(aRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(usercompany), &anError);
//    }
//    //// email
//    DLog(@"Adding email");
//    if(usercompany)
//    {
//        ABMutableMultiValueRef multiemail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
//        ABMultiValueAddValueAndLabel(multiemail, (__bridge CFStringRef)useremail, kABWorkLabel, NULL);
//        ABRecordSetValue(aRecord, kABPersonEmailProperty, multiemail, &anError);
//        //  CFRelease(multiemail);
//    }
//    // website
//    DLog(@"Adding website");
//    //DLog(userwebsite);
//    if(userwebsite)
//    {
//        ABMutableMultiValueRef multiweb = ABMultiValueCreateMutable(kABMultiStringPropertyType);
//        ABMultiValueAddValueAndLabel(multiweb, (__bridge CFStringRef)userwebsite, kABHomeLabel, NULL);
//        ABRecordSetValue(aRecord, kABPersonURLProperty, multiweb, &anError);
//        //  CFRelease(multiweb);
//    }
//    // Function
//    //ABRecordSetValue(aRecord, kABPersonJobTitleProperty, userrole, &anError);
//    CFErrorRef error =nil;
//    DLog(@"Writing values");
//    
//    
//    DLog(@"Saving to contacts");
//    ABAddressBookAddRecord([ContactEditor addressBook], aRecord, &error);
//    if (error != NULL) { 
//		
//		DLog(@"error while creating..");
//	} 
//    if(ABAddressBookHasUnsavedChanges)
//        ABAddressBookSave([ContactEditor addressBook], &error);
//    
//    DLog(@"Releasing data");
//    //CFRelease(aRecord);
//    //[username release];
//    //[usersurname release];
//    //[usercontact release];
//    //[usercompany release];
//    //[useremail release];
//    //[userwebsite release];
//    // CFRelease(addressBook);
//    }
    return NULL;
}

FREObject hasPermission(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    __block FREObject retVal = NULL;
    
    AppContactsAccessManager *accessMgr = [AppContactsAccessManager new];
    [accessMgr requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
        if (available) {
            FRENewObjectFromBool(YES, &retVal);
        } else {
            FRENewObjectFromBool(NO, &retVal);
        }
    }];
    
    return retVal;
}
FREObject getContactDetails(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    ALog(@"Entering getContactDetails");
    
    ALog(@"Extracting recordId arg sent from AS3");
    uint32_t argrecordId;
    __block FREObject contact=NULL;
    FRENewObject((const uint8_t*)"Object", 0, NULL, &contact,NULL);

    if( FREGetObjectAsUint32(argv[0], &argrecordId) == FRE_OK)
    {
        ALog(@"Requesting addressBook access to AppContactAccessManager");
        AppContactsAccessManager * accessMgr = [AppContactsAccessManager new];
        [accessMgr requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
            if( available )
            {
                ALog(@"addressBook access available, extracting data from abAddressBook API");
                FREObject retStr = NULL;
                
                ALog(@"Retrieving ABRecordRef for contact at position %i",argrecordId);
                ABRecordID abrecordId = argrecordId;
                ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBookRef, abrecordId);
                
                // Record ID
                ALog(@"Inserting recordId into AS3 Contact Object");
                int personId = (int)ABRecordGetRecordID(person);
                FREObject recordId;
                FRENewObjectFromInt32(personId, &recordId);
                FRESetObjectProperty(contact, (const uint8_t*)"recordId", recordId, NULL);
                
                // Composite name
                ALog(@"Inserting composite name into AS3 Contact Object");
                CFStringRef personCompositeName = ABRecordCopyCompositeName(person);
                if(personCompositeName)
                {
                    NSString *personCompositeString = [NSString stringWithString:(__bridge NSString *)personCompositeName];
                    FRENewObjectFromUTF8( strlen([personCompositeString UTF8String])+1,
                                         (const uint8_t*)[personCompositeString UTF8String],
                                         &retStr);
                    FRESetObjectProperty(contact, (const uint8_t*)"compositename", retStr, NULL);
                    CFRelease(personCompositeName);
                } else {
                    FRESetObjectProperty(contact, (const uint8_t*)"compositename", retStr, NULL);
                }
                
                retStr=NULL;
                
                // First name
                ALog(@"Inserting first name into AS3 Contact Object");
                CFStringRef personName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
                if(personName)
                {
                    NSString *personNameString = [NSString stringWithString:(__bridge NSString *)personName];
                    ALog(@"Adding first name: %@",personNameString);
                    FRENewObjectFromUTF8(strlen([personNameString UTF8String])+1,
                                         (const uint8_t*)[personNameString UTF8String],
                                         &retStr);
                    FRESetObjectProperty(contact, (const uint8_t*)"name", retStr, NULL);
                    CFRelease(personName);
                } else {
                    FRESetObjectProperty(contact, (const uint8_t*)"name", retStr, NULL);
                }
                
                retStr=NULL;
                
                // Last name or Surname
                ALog(@"Inserting last name into AS3 Contact Object");
                CFStringRef personSurName = ABRecordCopyValue(person, kABPersonLastNameProperty);
                if(personSurName)
                {
                    NSString *personSurNameString = [NSString stringWithString:(__bridge NSString *)personSurName];
                    FRENewObjectFromUTF8(strlen([personSurNameString UTF8String])+1,
                                         (const uint8_t*)[personSurNameString UTF8String],
                                         &retStr);
                    FRESetObjectProperty(contact, (const uint8_t*)"lastname", retStr, NULL);
                    //[personSurNameString release];
                    CFRelease(personSurName);
                } else {
                    FRESetObjectProperty(contact, (const uint8_t*)"lastname", retStr, NULL);
                }
                
                retStr=NULL;
                
                // Birthdate
                ALog(@"Inserting birthdate into AS3 Contact Object");
                NSDate *personBirthdate = CFBridgingRelease(ABRecordCopyValue(person, kABPersonBirthdayProperty));
                if(personBirthdate)
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                    NSString *personBirthdateString = [dateFormatter stringFromDate:personBirthdate];
                    FRENewObjectFromUTF8(strlen([personBirthdateString UTF8String])+1,
                                         (const uint8_t*)[personBirthdateString UTF8String],
                                         &retStr);
                    FRESetObjectProperty(contact, (const uint8_t*)"birthdate", retStr, NULL);
                } else {
                    FRESetObjectProperty(contact, (const uint8_t*)"birthdate", retStr, NULL);
                }
                
                retStr=NULL;
                
                // Emails
                ALog(@"Inserting emails into AS3 Contact Object");
                FREObject emailsArray = NULL;
                FRENewObject( (const uint8_t*) "Array", 0, NULL, &emailsArray, nil);
                ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
                if(emails)
                {
                    for (CFIndex k=0; k < ABMultiValueGetCount(emails); k++)
                    {
                        NSString* email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, k));
                        FRENewObjectFromUTF8(strlen([email UTF8String])+1, (const uint8_t*)[email UTF8String], &retStr);
                        FRESetArrayElementAt(emailsArray, k, retStr);
                    }
                    CFRelease(emails);
                    FRESetObjectProperty(contact, (const uint8_t*)"emails", emailsArray, NULL);
                } else {
                    FRESetObjectProperty(contact, (const uint8_t*)"emails", NULL, NULL);
                }
                
                retStr=NULL;
                
                // Phone Numbers
                ALog(@"Inserting phone numbers into AS3 Contact Object");
                FREObject phonesArray = NULL;
                FRENewObject((const uint8_t*)"Array", 0, NULL, &phonesArray, nil);
                ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                if(phones)
                {
                    for (CFIndex k=0; k < ABMultiValueGetCount(phones); k++)
                    {
                        NSString* phone = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, k));
                        FRENewObjectFromUTF8(strlen([phone UTF8String])+1, (const uint8_t*)[phone UTF8String], &retStr);
                        FRESetArrayElementAt(phonesArray, k, retStr);
                    }
                    CFRelease(phones);
                    FRESetObjectProperty(contact, (const uint8_t*)"phones", phonesArray, NULL);
                } else {
                    FRESetObjectProperty(contact, (const uint8_t*)"phones", NULL, NULL);
                }
                
                retStr=NULL;
                
                // Facebook Information: username
                ALog(@"Inserting Facebook information into AS3 Contact Object");
                ABMultiValueRef socialMulti = ABRecordCopyValue(person, kABPersonSocialProfileProperty);
                if(socialMulti)
                {
                    for (CFIndex i = 0; i < ABMultiValueGetCount(socialMulti); i++)
                    {
                        NSDictionary *socialData = CFBridgingRelease(ABMultiValueCopyValueAtIndex(socialMulti, i));
                        if ([socialData[@"service"] isEqualToString:(__bridge NSString*)kABPersonSocialProfileServiceFacebook])
                        {
                            NSString *facebookInfoString = (NSString*) socialData[@"username"];
                            FRENewObjectFromUTF8( strlen([facebookInfoString UTF8String])+1,
                                                 (const uint8_t*)[facebookInfoString UTF8String],
                                                 &retStr);
                            FRESetObjectProperty(contact, (const uint8_t*)"facebookInfo", retStr, NULL);
                        }
                    }
                    CFRelease(socialMulti);
                } else {
                    FRESetObjectProperty(contact, (const uint8_t*)"facebookInfo", retStr, NULL);
                }
                
                // Address Book Contact Addressses will be added later... (see git history)
                
                ALog(@"Extracted all information from abAddressBook API.  Returning to AS3 side of NativeExtension");
            }
        }];
    }
    
    ALog(@"Exiting getContactDetails");
    return contact;
}
FREObject getBitmapDimensions(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
//    uint32_t argrecordId;
//    FREObject size=NULL;
//    FRENewObject((const uint8_t*)"flash.geom.Point", 0, NULL, &size,NULL);
//    if(FRE_OK==FREGetObjectAsUint32(argv[0], &argrecordId))
//    {
//        if(newCreateOwnAddressBook())
//        {
//        ABRecordID abrecordId=argrecordId;
//        ABRecordRef person = ABAddressBookGetPersonWithRecordID([ContactEditor addressBook], abrecordId);
//        
//        if (ABPersonHasImageData(person))
//        {
//            DLog(@"found image");
//            UIImage *image;
//            //iOS 4.1 and before from http://goddess-gate.com/dc2/index.php/post/421
//            if ( &ABPersonCopyImageDataWithFormat != nil ) {
//                // iOS >= 4.1
//                image= [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)];
//            } else {
//                // iOS < 4.1
//                image= [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(person)];
//            }
//            
//            //FREReleaseByteArray( objectByteArray );
//            UIGraphicsEndImageContext();
//            
//            // Now we'll pull the raw pixels values out of the image data
//            CGImageRef imageRef = [image CGImage];
//            NSUInteger width = CGImageGetWidth(imageRef);
//            NSUInteger height = CGImageGetHeight(imageRef);
//            DLog(@"found image with dimensions %i, %i",width,height);
//            
////            CFRelease(addressBook);
//            FREObject temp;
//            FRENewObjectFromUint32(width, &temp);
//            FRESetObjectProperty(size, (const uint8_t*)"x", temp, NULL);
//            FRENewObjectFromUint32(height, &temp);
//            FRESetObjectProperty(size, (const uint8_t*)"y", temp, NULL);
//            
//        }
//    }
//    }
//    return size;
    return NULL;
}
FREObject setContactImage(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
//    uint32_t argrecordId;
//    if(FRE_OK==FREGetObjectAsUint32(argv[1], &argrecordId))
//    {
//        if(newCreateOwnAddressBook())
//        {
//        ABRecordID abrecordId=argrecordId;
//        ABRecordRef person = ABAddressBookGetPersonWithRecordID([ContactEditor addressBook], abrecordId);
//        FREBitmapData bitmapData;
//        //BitmapData to CGImageRef from http://forums.adobe.com/message/4201451
//        FREAcquireBitmapData(argv[0], &bitmapData);
//        int width       = bitmapData.width;
//        int height      = bitmapData.height;
//
//        
//        // make data provider from buffer
//        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData.bits32, (width * height * 4), NULL);
//        
//        // set up for CGImage creation
//        int                     bitsPerComponent    = 8;
//        int                     bitsPerPixel        = 32;
//        int                     bytesPerRow         = 4 * width;
//        CGColorSpaceRef         colorSpaceRef       = CGColorSpaceCreateDeviceRGB();   
//        CGBitmapInfo            bitmapInfo;
//        
//        if( bitmapData.hasAlpha )
//        {
//            if( bitmapData.isPremultiplied )
//                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
//            else
//                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;           
//        }
//        else
//        {
//            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst; 
//        }
//        
//        CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
//        CGImageRef              imageRef            = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
//        UIImage *myImage = [UIImage imageWithCGImage:imageRef];   
//        NSData * dataRef = UIImagePNGRepresentation(myImage);
//        ABPersonSetImageData(person,(__bridge CFDataRef)dataRef,nil);
//        ABAddressBookAddRecord([ContactEditor addressBook], person, nil);
//        ABAddressBookSave([ContactEditor addressBook], nil);
//        FREReleaseBitmapData(argv[0]);
////        CFRelease(addressBook);
//        CGColorSpaceRelease(colorSpaceRef);
//        CGImageRelease(imageRef);
//        CGDataProviderRelease(provider);   
//        
//    }
//    }
        return NULL;
}
FREObject drawToBitmap(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    // grab the AS3 bitmapData object for writing to
//    uint32_t argrecordId;
//    FREObject contact=NULL;
//    FRENewObject((const uint8_t*)"Object", 0, NULL, &contact,NULL);
//    if(FRE_OK==FREGetObjectAsUint32(argv[1], &argrecordId))
//    {
//        if(newCreateOwnAddressBook())
//        {
//        ABRecordID abrecordId=argrecordId;
//        ABRecordRef person = ABAddressBookGetPersonWithRecordID([ContactEditor addressBook], abrecordId);
//        
//    FREBitmapData bmd;
//    FREAcquireBitmapData(argv[0], &bmd);
//    
//    if (ABPersonHasImageData(person))
//    {
//        DLog(@"found image");
//        UIImage *image;
//        //iOS 4.1 and before from http://goddess-gate.com/dc2/index.php/post/421
//        if ( &ABPersonCopyImageDataWithFormat != nil ) {
//            // iOS >= 4.1
//            image= [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)];
//        } else {
//            // iOS < 4.1
//            image= [UIImage imageWithData:(__bridge NSData *)ABPersonCopyImageData(person)];
//        }
//        
//        //FREReleaseByteArray( objectByteArray );
//    UIGraphicsEndImageContext();
//    //drawing uiimage to as3 bitmapdata from http://tyleregeto.com/drawing-ios-uiviews-to-as3-bitmapdata-via-air
//    // Now we'll pull the raw pixels values out of the image data
//    CGImageRef imageRef = [image CGImage];
//    NSUInteger width = CGImageGetWidth(imageRef);
//    NSUInteger height = CGImageGetHeight(imageRef);
//        DLog(@"found image with dimensions %i, %i",width,height);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    // Pixel color values will be written here 
//    unsigned char *rawData = malloc(height * width * 4);
//    NSUInteger bytesPerPixel = 4;
//    NSUInteger bytesPerRow = bytesPerPixel * width;
//    NSUInteger bitsPerComponent = 8;
//    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
//                                                 bitsPerComponent, bytesPerRow, colorSpace,
//                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
//    CGColorSpaceRelease(colorSpace);
//    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
//    CGContextRelease(context);
//    
//    // Pixels are now in rawData in the format RGBA8888
//    // We'll now loop over each pixel write them into the AS3 bitmapData memory
//    int x, y;
//    // There may be extra pixels in each row due to the value of
//    // bmd.lineStride32, we'll skip over those as needed
//    int offset = bmd.lineStride32 - bmd.width;
//    int offset2 = bytesPerRow - bmd.width*4;
//    int byteIndex = 0;
//    uint32_t *bmdPixels = bmd.bits32;
//    DLog(@"processing image");
//    // NOTE: In this example we are assuming that our AS3 bitmapData and our native UIView are the same dimensions to keep things simple.
//    for(y=0; y<bmd.height; y++) {
//        for(x=0; x<bmd.width; x++, bmdPixels ++, byteIndex += 4) {
//            // Values are currently in RGBA8888, so each colour
//            // value is currently a separate number
//            int red   = (rawData[byteIndex]);
//            int green = (rawData[byteIndex + 1]);
//            int blue  = (rawData[byteIndex + 2]);
//            int alpha = (rawData[byteIndex + 3]);
//            // Combine values into ARGB32
//            * bmdPixels = (alpha << 24) | (red << 16) | (green << 8) | blue;
//        }
//        
//        bmdPixels += offset;
//        byteIndex += offset2;
//    }
//    DLog(@"releasing image");
//    // free the the memory we allocated
//    free(rawData);
//      
//    // Tell Flash which region of the bitmapData changes (all of it here)
//    FREInvalidateBitmapDataRect(argv[0], 0, 0, bmd.width, bmd.height);
//    // Release our control over the bitmapData
//    FREReleaseBitmapData(argv[0]);
//    
//    //CFRelease(addressBook);
//    }
//        }
//    }
    return NULL;
}

FREObject getContactsSimple(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    ALog(@"Entering getContactsSimple");
    
    __block FREObject returnedArray = NULL;
    __block NSInteger abBatchStartIndexInt;
    __block NSInteger abBatchLengthInt;
    
    // Retrieve parameters from ActionScript side.
    ALog(@"Retrieving parameters from AS3 side");
    FREGetObjectAsInt32(argv[0], &abBatchStartIndexInt);
    FREGetObjectAsInt32(argv[1], &abBatchLengthInt);

    // Attempt to access the AddressBook
    ALog(@"Attempting acesss to AddressBook");
    AppContactsAccessManager *accessManager = [AppContactsAccessManager new];
    [accessManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
        if (available) {
            
            ALog(@"Access Granted, proceeding to retrieve list of contacts");
            // cast integers into Core Foundation objects
            CFIndex abBatchStartIndex = abBatchStartIndexInt;
            CFIndex abBatchLength = abBatchLengthInt;
            
            // Initialize AS3 Array of Contacts
            ALog(@"Initialize AS3 Array of Contacts");
            CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            FRENewObject(((const uint8_t*)"Array"), 0, NULL, &returnedArray, nil);
            FRESetArrayLength(returnedArray, abBatchLength);
            
            FREObject retStr = NULL;
            int32_t currentIndex = 0;
            
            while (currentIndex < abBatchLength)
            {
                FREObject contact = NULL;
                FRENewObject((const uint8_t*)"Object", 0, NULL, &contact, NULL);
                ABRecordRef person = CFArrayGetValueAtIndex(people, abBatchStartIndex);
                ALog(@"Retriving record number %i at position in addrBk %li",currentIndex,abBatchStartIndex);
                
                if (person)
                {
                    // Extract Record id
                    FREObject personId;
                    int recordId = (int) ABRecordGetRecordID(person);
                    FRENewObjectFromInt32(recordId, &personId);
                    FRESetObjectProperty(contact, (const uint8_t*) "recordId", personId, NULL);
                    ALog(@"Extracting record id");
                    
                    // Extract Composite Name
                    CFStringRef compositeName = ABRecordCopyCompositeName(person);
                    if (compositeName)
                    {
                        NSString *personCompositeStr = [NSString stringWithString:CFBridgingRelease(compositeName)];
                        FRENewObjectFromUTF8(strlen([personCompositeStr UTF8String]) + 1,
                                             (const uint8_t*) [personCompositeStr UTF8String],
                                             &retStr);
                        FRESetObjectProperty(contact, (const uint8_t*) "compositeName", retStr, NULL);
                    } else {
                        FRESetObjectProperty(contact, (const uint8_t*) "compositeName", NULL, NULL);
                    }
                    ALog(@"Extracting composite name");
                    
                    // Insert Person AS3 Object into AS3 Array
                    FRESetArrayElementAt(returnedArray, currentIndex, contact);
                    ALog(@"inserting person object into as3 array at position %i",currentIndex);
                }
                
                currentIndex++;
                abBatchStartIndex++;
            }
            
            ALog(@"Finished populating array.  will release CF objects and return");
            
            // Release Core Foundation Objects
            CFRelease(people);
        }
    }];
    
    ALog(@"Exiting getContactsSimple");
    return returnedArray;
}

FREObject getContactCount(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    ALog(@"Entering getContactCount");
    __block FREObject contactCount;
    
    AppContactsAccessManager *accessManager = [AppContactsAccessManager new];
    [accessManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBookRef, BOOL available) {
        if (available) {
            CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
            FRENewObjectFromInt32(CFArrayGetCount(people), &contactCount);
            CFRelease(people);
        } else {
            FRENewObjectFromInt32(0, &contactCount);
        }
    }];
    
    ALog(@"Exiting getContactCount");
    return contactCount;
}

// ContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.

void ContactEditorContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                     uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
	
    ALog(@"Entering ContactEditorContextInitializer()");
    
	*numFunctionsToTest = 13;
	FRENamedFunction* func = (FRENamedFunction*)malloc(sizeof(FRENamedFunction) * (*numFunctionsToTest));
    
	func[0].name = (const uint8_t*)"addContact";
	func[0].functionData = NULL;
	func[0].function = &addContact;
    func[1].name = (const uint8_t*)"hasPermission";
	func[1].functionData = NULL;
	func[1].function = &hasPermission;
    func[2].name = (const uint8_t*)"getContactCount";
	func[2].functionData = NULL;
	func[2].function = &getContactCount;
    func[3].name = (const uint8_t*)"removeContact";
	func[3].functionData = NULL;
	func[3].function = &removeContact;
    func[4].name = (const uint8_t*)"contactEditorIsSupported";
	func[4].functionData = NULL;
	func[4].function = &contactEditorIsSupported;
    func[5].name = (const uint8_t*)"getContactsSimple";
	func[5].functionData = NULL;
	func[5].function = &getContactsSimple;
    func[6].name = (const uint8_t*)"getContactDetails";
	func[6].functionData = NULL;
	func[6].function = &getContactDetails;
    func[7].name = (const uint8_t*)"pickContact";
	func[7].functionData = NULL;
	func[7].function = &showContactPicker;
    func[8].name = (const uint8_t*)"addContactInWindow";
	func[8].functionData = NULL;
	func[8].function = &addContactInWindow;
    func[9].name = (const uint8_t*)"showContactDetailsInWindow";
	func[9].functionData = NULL;
	func[9].function = &showContactDetailsInWindow;
    func[10].name = (const uint8_t*)"drawToBitmap";
	func[10].functionData = NULL;
	func[10].function = &drawToBitmap;
    func[11].name = (const uint8_t*)"getBitmapDimensions";
	func[11].functionData = NULL;
    func[11].function = &getBitmapDimensions;
    func[12].name = (const uint8_t*)"setContactImage";
	func[12].functionData = NULL;
    func[12].function = &setContactImage;
	*functionsToSet = func;
    
    ALog(@"Exiting ContactEditorContextInitializer()");
}



// ContextFinalizer()
//
// The context finalizer is called when the extension's ActionScript code
// calls the ExtensionContext instance's dispose() method.
// If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls
// ContextFinalizer().

void ContactEditorContextFinalizer(FREContext ctx) {
	if(contactEditorHelper)
    {
        [contactEditorHelper setContext:NULL];
        contactEditorHelper = nil;
    }
    if(contactEditorAddContactHelper)
    {
        [contactEditorAddContactHelper setContext:NULL];
        contactEditorHelper = nil;
    }
    if(contactEditorViewDetailsHelper)
    {
        [contactEditorViewDetailsHelper setContext:NULL];
        contactEditorViewDetailsHelper = nil;
    }
        // Nothing to clean up.
    
	return;
}



// ExtInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.

void ContactEditorExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                                 FREContextFinalizer* ctxFinalizerToSet) {
	
  	*extDataToSet = NULL;
	*ctxInitializerToSet = &ContactEditorContextInitializer;
	*ctxFinalizerToSet = &ContactEditorContextFinalizer;
} 



// ExtFinalizer()
//
// The extension finalizer is called when the runtime unloads the extension. However, it is not always called.

void ContactEditorExtFinalizer(void* extData) {
	
    
	// Nothing to clean up.
	
    
    
	return;
}

@end
