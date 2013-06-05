/*
 Contact editor by memeller@gmail.com
 isSupported function by https://github.com/mateuszmackowiak
 */

#import "FlashRuntimeExtensions.h"
#import "AppContactsAccessManager.h"

@interface ContactEditor : NSObject

@property (nonatomic, strong) NSMutableArray *simpleContacts;
@property (nonatomic, strong) NSMutableArray *detailedContacts;

+ (id) sharedInstance;

- (void) getNumContacts;
- (void) getSimpleContactsWithBatchStart:(NSInteger)batchStart batchLength:(NSInteger)batchLength;
- (void) getDetailedContactWithRecordId:(int)recordId;

@end

// Main Functions
DEFINE_ANE_FUNCTION(getContactsSimple);
DEFINE_ANE_FUNCTION(getContactDetails);
DEFINE_ANE_FUNCTION(getContactCount);

// Functions that return values (Async)
DEFINE_ANE_FUNCTION(retrieveSimpleContacts);
DEFINE_ANE_FUNCTION(retrieveContactDetails);

// ANE Setup
void ContactEditorContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void ContactEditorContextFinalizer(FREContext ctx);
void ContactEditorExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void ContactEditorExtFinalizer(void* extData);


