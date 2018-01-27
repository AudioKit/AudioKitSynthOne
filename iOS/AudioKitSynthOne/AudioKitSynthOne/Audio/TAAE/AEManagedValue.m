//
//  AEManagedValue.m
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 30/03/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "AEManagedValue.h"
#import <libkern/OSAtomic.h>
#import <pthread.h>
#import "AEUtilities.h"
#import "AEWeakRetainingProxy.h"

typedef struct __linkedlistitem_t {
    void * data;
    __unsafe_unretained void (^completionBlock)(void *);
    struct __linkedlistitem_t * next;
} linkedlistitem_t;

static int __atomicUpdateCounter = 0;
static pthread_rwlock_t __atomicUpdateMutex = PTHREAD_RWLOCK_INITIALIZER;
static NSHashTable * __atomicUpdatedDeferredSyncValues = nil;
static BOOL __atomicUpdateWaitingForCommit = NO;

static linkedlistitem_t * __pendingInstances = NULL;
static linkedlistitem_t * __servicedInstances = NULL;
static pthread_mutex_t __pendingInstancesMutex = PTHREAD_MUTEX_INITIALIZER;

#ifdef DEBUG
pthread_t AEManagedValueRealtimeThreadIdentifier = NULL;
#endif

@interface AEManagedValue () {
    void *      _value;
    BOOL        _valueSet;
    void *      _atomicBatchUpdateLastValue;
    BOOL        _wasUpdatedInAtomicBatchUpdate;
    BOOL        _isObjectValue;
    OSQueueHead _pendingReleaseQueue;
    int         _pendingReleaseCount;
    OSQueueHead _releaseQueue;
}
@property (nonatomic, strong) NSTimer * pollTimer;
@end

@implementation AEManagedValue
@dynamic objectValue, pointerValue;

+ (void)initialize {
    __atomicUpdatedDeferredSyncValues = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:0];
}

/*!
 * Some comments about the implementation for atomic batch updates, as it's a bit tricky:
 *
 *  - This works by making the realtime thread read the previously set value, instead of
 *    the new one.
 *
 *  - We need to protect against the scenario where the batch-update-in-progress check on the
 *    realtime thread passes followed immediately by the main thread entering the batch update and
 *    changing the value, as this violates atomicity. To do this, we use a mutex to guard the
 *    realtime thread check-and-return. We use a try lock on the realtime thread, the failure
 *    of which conveniently tells us that a batch update is happening, so it's the only check
 *    we need.
 *
 *  - We need the realtime thread to only return the previously set value between the time an 
 *    update starts, and the time it's committed. Commit happens on the realtime thread at the
 *    start of the main render loop, initiated by the third-party developer, so that batch updates 
 *    occur all together with respect to the main render loop - otherwise, completion of a batch 
 *    update could occur while the render loop is midway through, violating atomicity.
 *
 *  - This mechanism requires the previously set value (_atomicBatchUpdateLastValue) to be
 *    synced correctly to the current value at the time the atomic batch update begins.
 *
 *  - setValue is responsible for maintaining this sync. It can't do this during a batch update
 *    though, or it would defeat the purpose.
 *
 *  - Consequently, this is deferred until the next time sync is required: at the beginning
 *    of the next batch update. We do this by keeping track of those deferrals in a static
 *    NSHashTable, and performing them at the start of the batch update method.
 *
 *  - In order to allow values to be deallocated cleanly, we store weak values in this set, and
 *    remove outgoing instances in dealloc.
 *
 *  - Side note: An alternative deferral implementation is to perform post-batch update sync from
 *    the commit function, on the realtime thread, but this introduces two complications: (1) that
 *    the _atomicBatchUpdateLastValue variable would then be written to from both main and realtime
 *    thread, and (2) that we then need a mechanism to release items in the list, which we can't
 *    do on the realtime thread.
 */
+ (void)performAtomicBatchUpdate:(AEManagedValueUpdateBlock)block {
    
    if ( !__atomicUpdateWaitingForCommit ) {
        // Perform deferred sync to _atomicBatchUpdateLastValue for previously-batch-updated values
        for ( AEManagedValue * value in __atomicUpdatedDeferredSyncValues ) {
            value->_atomicBatchUpdateLastValue = value->_value;
        }
        [__atomicUpdatedDeferredSyncValues removeAllObjects];
    }
    
    if ( __atomicUpdateCounter == 0 ) {
        // Wait for realtime thread to exit any GetValue calls
        pthread_rwlock_wrlock(&__atomicUpdateMutex);
        
        // Mark that we're awaiting a commit
        __atomicUpdateWaitingForCommit = YES;
    }
    
    __atomicUpdateCounter++;
    
    // Perform the updates
    block();
    
    __atomicUpdateCounter--;
    
    if ( __atomicUpdateCounter == 0 ) {
        // Unlock, allowing GetValue to access _value again
        pthread_rwlock_unlock(&__atomicUpdateMutex);
    }
}

- (instancetype)init {
    if ( !(self = [super init]) ) return nil;
    return self;
}

- (void)dealloc {
    // Remove self from deferred sync list
    [__atomicUpdatedDeferredSyncValues removeObject:self];
    
    // Remove self from instances awaiting service list
    pthread_mutex_lock(&__pendingInstancesMutex);
    for ( linkedlistitem_t * entry = __pendingInstances, * prior = NULL; entry; prior = entry, entry = entry->next ) {
        if ( entry->data == (__bridge void*)self ) {
            if ( prior ) {
                prior->next = entry->next;
            } else {
                __pendingInstances = entry->next;
            }
            free(entry);
            break;
        }
    }
    pthread_mutex_unlock(&__pendingInstancesMutex);
    
    // Perform any pending releases
    if ( _value ) {
        [self releaseOldValue:_value];
    }
    linkedlistitem_t * release;
    while ( (release = OSAtomicDequeue(&_pendingReleaseQueue, offsetof(linkedlistitem_t, next))) ) {
        OSAtomicEnqueue(&_releaseQueue, release, offsetof(linkedlistitem_t, next));
    }
    [self pollReleaseList];
}

- (id)objectValue {
    NSAssert(!_valueSet || _isObjectValue, @"You can use objectValue or pointerValue, but not both");
    return (__bridge id)_value;
}

- (void)setObjectValue:(id)objectValue {
    [self setObjectValue:objectValue withCompletionBlock:nil];
}

- (void)setObjectValue:(id)objectValue withCompletionBlock:(void (^)(id))completionBlock {
    NSAssert(!_valueSet || _isObjectValue, @"You can use objectValue or pointerValue, but not both");
    _isObjectValue = YES;
    [self setValue:(__bridge_retained void*)objectValue completionBlock:(void (^)(void *))completionBlock];
}

- (void *)pointerValue {
    NSAssert(!_valueSet || !_isObjectValue, @"You can use objectValue or pointerValue, but not both");
    return _value;
}

- (void)setPointerValue:(void *)pointerValue {
    [self setPointerValue:pointerValue withCompletionBlock:nil];
}

- (void)setPointerValue:(void *)pointerValue withCompletionBlock:(void (^)(void *))completionBlock {
    NSAssert(!_valueSet || !_isObjectValue, @"You can use objectValue or pointerValue, but not both");
    [self setValue:pointerValue completionBlock:completionBlock];
}

- (void)setValue:(void *)value completionBlock:(void (^)(void *))completionBlock {
    
    if ( value == _value ) return;
    
    // Assign new value
    void * oldValue = _value;
    _value = value;
    _valueSet = YES;
    
    if ( __atomicUpdateCounter == 0 && !__atomicUpdateWaitingForCommit ) {
        // Sync value for recall on realtime thread during atomic batch update
        _atomicBatchUpdateLastValue = _value;
    } else {
        // Defer value sync
        [__atomicUpdatedDeferredSyncValues addObject:self];
    }
    
    if ( oldValue || completionBlock ) {
        // Mark old value as pending release - it'll be transferred to the release queue by
        // AEManagedValueGetValue on the audio thread
        linkedlistitem_t * release = (linkedlistitem_t*)calloc(1, sizeof(linkedlistitem_t));
        release->data = oldValue;
        if ( completionBlock ) {
            release->completionBlock = (__bridge id)CFBridgingRetain([completionBlock copy]);
        }
        
        OSAtomicEnqueue(&_pendingReleaseQueue, release, offsetof(linkedlistitem_t, next));
        _pendingReleaseCount++;
        
        if ( !self.pollTimer ) {
            // Start polling for pending releases
            double interval = completionBlock ? 0.01 : 0.1;
            self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:[AEWeakRetainingProxy proxyWithTarget:self]
                                                            selector:@selector(pollReleaseList) userInfo:nil repeats:YES];
            if ( !completionBlock ) {
                self.pollTimer.tolerance = 0.5;
            }
        }
        
        // Add self to the list of instances to service on the realtime thread within AEManagedValueCommitPendingUpdates
        pthread_mutex_lock(&__pendingInstancesMutex);
        BOOL alreadyPresent = NO;
        for ( linkedlistitem_t * entry = __pendingInstances; entry; entry = entry->next ) {
            if ( entry->data == (__bridge void*)self ) {
                alreadyPresent = YES;
            }
        }
        if ( !alreadyPresent ) {
            linkedlistitem_t * entry = malloc(sizeof(linkedlistitem_t));
            entry->next = __pendingInstances;
            entry->data = (__bridge void*)self;
            __pendingInstances = entry;
        }
        pthread_mutex_unlock(&__pendingInstancesMutex);
    }
}

#pragma mark - Realtime thread

void AEManagedValueCommitPendingUpdates() {
    #ifdef DEBUG
    if ( AEManagedValueRealtimeThreadIdentifier && AEManagedValueRealtimeThreadIdentifier != pthread_self() ) {
        if ( AERateLimit() ) printf("%s called from outside realtime thread\n", __FUNCTION__);
    }
    #endif
    
    // Finish atomic update
    if ( pthread_rwlock_tryrdlock(&__atomicUpdateMutex) == 0 ) {
        __atomicUpdateWaitingForCommit = NO;
        pthread_rwlock_unlock(&__atomicUpdateMutex);
    } else {
        // Still in the middle of an atomic update
        return;
    }
    
    // Service any instances pending an update so we can mark the old value as ready for release
    if ( pthread_mutex_trylock(&__pendingInstancesMutex) == 0 ) {
        linkedlistitem_t * lastEntry = NULL;
        for ( linkedlistitem_t * entry = __pendingInstances; entry; lastEntry = entry, entry = entry->next ) {
            AEManagedValueServiceReleaseQueue((__bridge AEManagedValue*)entry->data);
        }
        
        if ( lastEntry ) {
            // Move pending instances to serviced instances list, ready for cleanup on main thread
            lastEntry->next = __servicedInstances;
            __servicedInstances = __pendingInstances;
            __pendingInstances = NULL;
        }
        pthread_mutex_unlock(&__pendingInstancesMutex);
    }
}

void * AEManagedValueGetValue(__unsafe_unretained AEManagedValue * THIS) {
    if ( !THIS ) return NULL;
    
    if ( __atomicUpdateWaitingForCommit || pthread_rwlock_tryrdlock(&__atomicUpdateMutex) != 0 ) {
        // Atomic update in progress - return previous value
        return THIS->_atomicBatchUpdateLastValue;
    }
    
    if ( !pthread_main_np() ) {
        AEManagedValueServiceReleaseQueue(THIS);
    }
    
    void * value = THIS->_value;
    
    pthread_rwlock_unlock(&__atomicUpdateMutex);
    
    return value;
}

void AEManagedValueServiceReleaseQueue(__unsafe_unretained AEManagedValue * THIS) {
    linkedlistitem_t * release;
    while ( (release = OSAtomicDequeue(&THIS->_pendingReleaseQueue, offsetof(linkedlistitem_t, next))) ) {
        OSAtomicEnqueue(&THIS->_releaseQueue, release, offsetof(linkedlistitem_t, next));
    }
}

#pragma mark - Helpers

- (void)pollReleaseList {
    linkedlistitem_t * release;
    while ( (release = OSAtomicDequeue(&_releaseQueue, offsetof(linkedlistitem_t, next))) ) {
        if ( release->completionBlock ) {
            release->completionBlock(release->data);
            CFBridgingRelease((__bridge CFTypeRef)release->completionBlock);
        }
        if ( release->data ) {
            NSAssert(release->data != _value, @"About to release value still in use");
            [self releaseOldValue:release->data];
        }
        free(release);
        _pendingReleaseCount--;
    }
    if ( _pendingReleaseCount == 0 ) {
        [self.pollTimer invalidate];
        self.pollTimer = nil;
    }
    
    // Remove self from serviced instances list
    pthread_mutex_lock(&__pendingInstancesMutex);
    for ( linkedlistitem_t * entry = __servicedInstances, * prior = NULL; entry; prior = entry, entry = entry->next ) {
        if ( entry->data == (__bridge void*)self ) {
            if ( prior ) {
                prior->next = entry->next;
            } else {
                __servicedInstances = entry->next;
            }
            free(entry);
            break;
        }
    }
    pthread_mutex_unlock(&__pendingInstancesMutex);
}

- (void)releaseOldValue:(void *)value {
    if ( _releaseBlock ) {
        _releaseBlock(value);
    } else if ( _isObjectValue ) {
        CFBridgingRelease(value);
    } else {
        free(value);
    }
    if ( _releaseNotificationBlock ) {
        _releaseNotificationBlock();
    }
}

@end
