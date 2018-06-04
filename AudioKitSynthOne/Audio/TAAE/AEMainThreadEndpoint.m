//
//  AEMainThreadEndpoint.m
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 29/04/2016.
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

#import "AEMainThreadEndpoint.h"
#import "AudioKit/TPCircularBuffer.h"
#import <mach/semaphore.h>
#import <mach/task.h>
#import <mach/mach_init.h>
#import <pthread.h>

static const int kMaxMessagesEachService = 20;
static const int kMaxMessageLengthForCopy = 256;

@class AEMainThreadEndpointThread;

static AEMainThreadEndpointThread * __sharedThread = nil;

@interface AEMainThreadEndpoint () {
    TPCircularBuffer _buffer;
    BOOL _hasPendingMainThreadMessages;
}
@property (nonatomic, copy) AEMainThreadEndpointHandler handler;
@property (nonatomic) semaphore_t semaphore;
@property (nonatomic, strong) AEMainThreadEndpointThread * thread;
@end

@interface AEMainThreadEndpointThread : NSThread
- (void)addEndpoint:(AEMainThreadEndpoint *)endpoint;
- (void)removeEndpoint:(AEMainThreadEndpoint *)endpoint;
@property (nonatomic) semaphore_t semaphore;
@end

@implementation AEMainThreadEndpoint

+ (AEMainThreadEndpointThread *)sharedThread {
    if ( !__sharedThread ) {
        __sharedThread = [AEMainThreadEndpointThread new];
        [__sharedThread start];
    }
    
    return __sharedThread;
}

- (instancetype)initWithHandler:(AEMainThreadEndpointHandler)handler {
    return [self initWithHandler:handler bufferCapacity:8192];
}

- (instancetype)initWithHandler:(AEMainThreadEndpointHandler)handler bufferCapacity:(size_t)bufferCapacity {
    if ( !(self = [super init]) ) return nil;
    
    self.handler = handler;
    
    if ( !TPCircularBufferInit(&_buffer, (int32_t)bufferCapacity) ) {
        return nil;
    }
    
    self.thread = [AEMainThreadEndpoint sharedThread];
    [self.thread addEndpoint:self];
    self.semaphore = self.thread.semaphore;
    
    return self;
}

- (void)dealloc {
    [self.thread removeEndpoint:self];
    TPCircularBufferCleanup(&_buffer);
}

BOOL AEMainThreadEndpointSend(__unsafe_unretained AEMainThreadEndpoint * THIS, const void * data, size_t length) {
    
    // Prepare message
    void * message = AEMainThreadEndpointCreateMessage(THIS, length);
    if ( !message ) {
        return NO;
    }
    
    if ( length ) {
        // Copy data
        memcpy(message, data, length);
    }
    
    // Dispatch
    AEMainThreadEndpointDispatchMessage(THIS);
    
    return YES;
}

void * AEMainThreadEndpointCreateMessage(__unsafe_unretained AEMainThreadEndpoint * THIS, size_t length) {
    
    // Get pointer to writable bytes
    int32_t size = (int32_t)(length + sizeof(size_t));
    int32_t availableBytes;
    void * head = TPCircularBufferHead(&THIS->_buffer, &availableBytes);
    if ( availableBytes < size ) {
        return NULL;
    }
    
    // Write the length of the message
    *((size_t*)head) = length;
    
    // Return the following region ready for writing
    return head + sizeof(size_t);
}

void AEMainThreadEndpointDispatchMessage(__unsafe_unretained AEMainThreadEndpoint * THIS) {

    // Get pointer to writable bytes
    int32_t availableBytes;
    void * head = TPCircularBufferHead(&THIS->_buffer, &availableBytes);
    size_t size = *((size_t*)head) + sizeof(size_t);
    
    // Mark as ready to read
    TPCircularBufferProduce(&THIS->_buffer, (int32_t)size);
    semaphore_signal(THIS->_semaphore);
}

- (void)serviceMessages {
    for ( int i=0; i<kMaxMessagesEachService; i++ ) {
        // Get pointer to readable bytes
        int32_t availableBytes;
        void * tail = TPCircularBufferTail(&_buffer, &availableBytes);
        if ( availableBytes == 0 ) return;
        
        // Get length and data
        size_t length = *((size_t*)tail);
        void * data = length > 0 ? (tail + sizeof(size_t)) : NULL;
        
        if ( length < kMaxMessageLengthForCopy ) {
            // Copy data so we can run asynchronously
            void * dataCopy = malloc(length);
            memcpy(dataCopy, data, length);
            dispatch_async(dispatch_get_main_queue(), ^{
                // Run handler
                self.handler(dataCopy, length);
                free(dataCopy);
            });
        } else {
            // Run handler synchronously
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.handler(data, length);
            });
        }
        
        // Mark as read
        TPCircularBufferConsume(&_buffer, (int32_t)(sizeof(size_t) + length));
    }
}

@end

#pragma mark - Handler thread

@interface AEMainThreadEndpointThread () {
    pthread_mutex_t _mutex;
    pthread_mutex_t _deferredMutex;
}
@property (nonatomic, strong) NSHashTable * endpoints;
@property (nonatomic, strong) NSMutableSet * deferredAdditions;
@end

@implementation AEMainThreadEndpointThread

- (instancetype)init {
    if ( !(self = [super init]) ) return nil;
    semaphore_create(mach_task_self(), &_semaphore, SYNC_POLICY_FIFO, 0);
    self.endpoints =
        [[NSHashTable alloc] initWithOptions:NSPointerFunctionsOpaqueMemory|NSPointerFunctionsObjectPointerPersonality
                                    capacity:8];
    
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_mutex, &attr);
    pthread_mutex_init(&_deferredMutex, 0);
    return self;
}

- (void)dealloc {
    semaphore_destroy(mach_task_self(), _semaphore);
    pthread_mutex_destroy(&_mutex);
    pthread_mutex_destroy(&_deferredMutex);
}

- (void)cancel {
    [super cancel];
    semaphore_signal(_semaphore);
}

- (void)addEndpoint:(AEMainThreadEndpoint *)endpoint {
    if ( pthread_mutex_trylock(&_mutex) == 0 ) {
        [self.endpoints addObject:endpoint];
        pthread_mutex_unlock(&_mutex);
        semaphore_signal(_semaphore);
    } else {
        // Defer addition to avoid contention over endpoints list
        pthread_mutex_lock(&_deferredMutex);
        if ( !self.deferredAdditions ) {
            self.deferredAdditions = [NSMutableSet set];
        }
        [self.deferredAdditions addObject:endpoint];
        semaphore_signal(_semaphore);
        pthread_mutex_unlock(&_deferredMutex);
    }
}

- (void)removeEndpoint:(AEMainThreadEndpoint *)endpoint {
    // Endpoints are removed when they are deallocated (as we store weak references)
    // Because we keep a strong reference during servicing in main, they will never happen during servicing,
    // so we should never actually get lock contention.
    pthread_mutex_lock(&_mutex);
    [self.endpoints removeObject:endpoint];
    if ( self.endpoints.count == 0 ) {
        __sharedThread = nil;
        [self cancel];
    }
    pthread_mutex_unlock(&_mutex);
}

- (void)main {
    pthread_setname_np("AEMainThreadEndpoint");
    
    while ( 1 ) {
        pthread_mutex_lock(&_mutex);
        
        @autoreleasepool {
            if ( self.cancelled ) {
                pthread_mutex_unlock(&_mutex);
                break;
            }
            
            // Keep strong reference to all endpoints to avoid deallocation during servicing
            NSArray * endpoints = self.endpoints.allObjects;
            for ( AEMainThreadEndpoint * endpoint in endpoints ) {
                [endpoint serviceMessages];
            }
        
            if ( self.deferredAdditions ) {
                // Apply deferred additions/removals (deferred to avoid contention over the endpoints list)
                pthread_mutex_lock(&_deferredMutex);
                for ( AEMainThreadEndpoint * endpoint in self.deferredAdditions ) {
                    [self.endpoints addObject:endpoint];
                }
                self.deferredAdditions = nil;
                pthread_mutex_unlock(&_deferredMutex);
            }
        }
        
        pthread_mutex_unlock(&_mutex);
        
        if ( self.cancelled ) {
            // We'll be cancelled here if the endpoint was released during servicing, so exit
            break;
        }
        
        semaphore_wait(_semaphore);
    }
}

@end
