/*
 Contact editor by memeller@gmail.com
 isSupported function by https://github.com/mateuszmackowiak
 */

#import "FlashRuntimeExtensions.h"
#import "AppContactsAccessManager.h"

typedef void (^DetailedContactCompletion) (BOOL success);

@interface ContactEditor : NSObject

@property (nonatomic, strong) NSMutableArray *simpleContacts;
@property (nonatomic, strong) NSMutableArray *detailedContacts;

+ (id) sharedInstance;

- (void) getNumContacts;
- (void) getSimpleContactsWithRange:(NSValue*)range;
- (void) getDetailedContactWithRecordId:(int)recordId andCompletion:(DetailedContactCompletion) completion;
- (void) getDetailedContactsWithRecordIds:(NSArray*)records;

+ (void) dispatchFREEvent:(NSString *)code withLevel:(NSString *)level;
+ (void) log:(NSString *)format, ...;

@end

NSArray* getFREArrayAsNSArray(FREObject array);

// Main Functions
DEFINE_ANE_FUNCTION(getContactsSimple);
DEFINE_ANE_FUNCTION(getContactDetails);
DEFINE_ANE_FUNCTION(getContactsDetails);
DEFINE_ANE_FUNCTION(getContactCount);

// Functions that return values (Async)
DEFINE_ANE_FUNCTION(retrieveSimpleContacts);
FREObject* contactToFREObject( NSMutableDictionary* contactDict );
DEFINE_ANE_FUNCTION(retrieveContactDetails);
DEFINE_ANE_FUNCTION(retrieveAllDetails);

// utlimate function, returns values by batches
DEFINE_ANE_FUNCTION(getAllContactsDetails);

// ANE Setup
void ContactEditorContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void ContactEditorContextFinalizer(FREContext ctx);
void ContactEditorExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void ContactEditorExtFinalizer(void* extData);