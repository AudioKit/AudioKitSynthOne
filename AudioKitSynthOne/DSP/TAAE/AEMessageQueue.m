//
//  AEMessageQueue.m
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

#import "AEMessageQueue.h"
#import "AEMainThreadEndpoint.h"
#import "AEAudioThreadEndpoint.h"

AEArgument AEArgumentNone = {NO, NULL, 0};

typedef NS_ENUM(NSInteger, AEMessageQueueMessageType) {
    AEMessageQueueMainThreadMessage,
    AEMessageQueueAudioThreadMessage,
};

// Audio thread message type
typedef struct {
    AEMessageQueueMessageType type;
    __unsafe_unretained void (^block)(void);
    __unsafe_unretained void (^completionBlock)(void);
} audio_thread_message_t;

// Main thread message type
typedef struct {
    AEMessageQueueMessageType type;
    __unsafe_unretained id target;
    size_t selectorLength; // Length of selector including NULL terminator
} main_thread_message_t; // Selector follows, then each argument (main_thread_message_arg_t followed by data)

// Main thread argument header
typedef struct {
    size_t length; // Number of bytes of data
    BOOL isValue;  // Whether to pass by value
} main_thread_message_arg_t; // Data follows

@interface AEMessageQueue ()
@property (nonatomic, strong) AEMainThreadEndpoint * mainThreadEndpoint;
@property (nonatomic, strong) AEAudioThreadEndpoint * audioThreadEndpoint;
@end

@implementation AEMessageQueue

- (instancetype)init {
    return [self initWithBufferCapacity:8192];
}

- (instancetype)initWithBufferCapacity:(size_t)bufferCapacity {
    if ( !(self = [super init]) ) return nil;
    
    // Create main thread endpoint
    self.mainThreadEndpoint = [[AEMainThreadEndpoint alloc] initWithHandler:^(void * _Nullable data, size_t length) {
        const AEMessageQueueMessageType * type = (AEMessageQueueMessageType *)data;
        if ( *type == AEMessageQueueMainThreadMessage ) {
            const main_thread_message_t * message = (const main_thread_message_t *)data;
            id target = message->target;
            const char * selectorString = ((char *)data) + sizeof(main_thread_message_t);
            const char * arguments = ((char *)data) + sizeof(main_thread_message_t) + message->selectorLength;
            const char * argumentEnd = ((char *)data) + length;
            
            // Create invocation
            SEL selector = sel_registerName(selectorString);
            NSMethodSignature * methodSignature;
            if ( !selector || !(methodSignature = [target methodSignatureForSelector:selector]) ) {
                NSLog(@"AEMessageQueue: Invalid selector '%s'", selectorString);
                return;
            }
            NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            invocation.selector = selector;
            
            // Fill in arguments
            for ( int i = 2; i < invocation.methodSignature.numberOfArguments && arguments < argumentEnd; i++ ) {
                const main_thread_message_arg_t * arg = (const main_thread_message_arg_t *)arguments;
                
                // Verify argument
                NSUInteger argLength;
                const char * type = [invocation.methodSignature getArgumentTypeAtIndex:i];
                NSGetSizeAndAlignment(type, &argLength, NULL);
                if ( argLength != (arg->isValue ? arg->length : sizeof(void*)) ) {
                    NSLog(@"AEMessageQueue: Incorrect argument size for selector %s argument %d", selectorString, i-2);
                    return;
                }
                
                // Assign value
                const void * data = arguments + sizeof(main_thread_message_arg_t);
                [invocation setArgument:(void*)(arg->isValue ? data : &data) atIndex:i];
                arguments += sizeof(main_thread_message_arg_t) + arg->length;
            }
            
            [invocation invokeWithTarget:target];
            
        } else if ( *type == AEMessageQueueAudioThreadMessage ) {
            // Clean up audio thread message, and possibly call completion block
            const audio_thread_message_t * message = (const audio_thread_message_t *)data;
            CFBridgingRelease((__bridge CFTypeRef)(message->block));
            
            if ( message->completionBlock ) {
                message->completionBlock();
                CFBridgingRelease((__bridge CFTypeRef)(message->completionBlock));
            }
        }
    } bufferCapacity:bufferCapacity];
    
    // Create audio thread endpoint
    AEMainThreadEndpoint * mainThread = _mainThreadEndpoint;
    self.audioThreadEndpoint = [[AEAudioThreadEndpoint alloc] initWithHandler:^(const void * _Nullable data, size_t length) {
        // Call block
        const audio_thread_message_t * message = (const audio_thread_message_t *)data;
        message->block();
        
        // Enqueue response on main thread, to clean up and possibly call completion block
        AEMainThreadEndpointSend(mainThread, data, length);
    } bufferCapacity:bufferCapacity];
    
    return self;
}

- (void)performBlockOnAudioThread:(AEMessageQueueBlock)block {
    [self performBlockOnAudioThread:block completionBlock:nil];
}

- (void)performBlockOnAudioThread:(AEMessageQueueBlock)block completionBlock:(AEMessageQueueBlock)completionBlock {
    // Prepare message
    audio_thread_message_t message = {
        .type = AEMessageQueueAudioThreadMessage,
        .block = (__bridge id)CFBridgingRetain([block copy]),
        .completionBlock = completionBlock ? (__bridge id)CFBridgingRetain([completionBlock copy]) : NULL,
    };
    
    // Dispatch
    [self.audioThreadEndpoint sendBytes:&message length:sizeof(message)];
}

BOOL AEMessageQueuePerformSelectorOnMainThread(__unsafe_unretained AEMessageQueue * THIS,
                                               __unsafe_unretained id target,
                                               SEL selector,
                                               AEArgument arguments, ...) {
    // Prepare message buffer: determine size of message
    const char * selectorString = sel_getName(selector);
    int selectorLength = (int)strlen(selectorString) + 1;
    size_t messageSize = sizeof(main_thread_message_t) + selectorLength;
    if ( arguments.length > 0 ) {
        messageSize += sizeof(main_thread_message_arg_t) + arguments.length;
        va_list args;
        va_start(args, arguments);
        AEArgument argument;
        while ( 1 ) {
            argument = va_arg(args, AEArgument);
            if ( argument.length == 0 ) break;
            messageSize += sizeof(main_thread_message_arg_t) + argument.length;
        }
        va_end(args);
    }
    
    // Create message
    void * message = AEMainThreadEndpointCreateMessage(THIS->_mainThreadEndpoint, messageSize);
    if ( !message ) return NO;
    
    // Write header
    main_thread_message_t * header = message;
    header->type = AEMessageQueueMainThreadMessage;
    header->target = target;
    header->selectorLength = selectorLength;
    
    // Copy in selector
    memcpy(message + sizeof(main_thread_message_t), selectorString, selectorLength);
    
    // Copy in arguments
    void * argumentPtr = message + sizeof(main_thread_message_t) + selectorLength;
    if ( arguments.length > 0 ) {
        // Copy first argument
        main_thread_message_arg_t * arg = argumentPtr;
        arg->isValue = arguments.isValue;
        arg->length = arguments.length;
        memcpy(argumentPtr + sizeof(main_thread_message_arg_t), arguments.data, arguments.length);
        argumentPtr += sizeof(main_thread_message_arg_t) + arguments.length;
        
        // Copy remaining arguments
        va_list args;
        va_start(args, arguments);
        AEArgument argument;
        while ( 1 ) {
            argument = va_arg(args, AEArgument);
            if ( argument.length == 0 ) break;
            
            main_thread_message_arg_t * arg = argumentPtr;
            arg->isValue = argument.isValue;
            arg->length = argument.length;
            memcpy(argumentPtr + sizeof(main_thread_message_arg_t), argument.data, argument.length);
            argumentPtr += sizeof(main_thread_message_arg_t) + argument.length;
        }
        va_end(args);
    }
    
    // Dispatch
    AEMainThreadEndpointDispatchMessage(THIS->_mainThreadEndpoint);
    
    return YES;
}

- (void)beginMessageGroup {
    [self.audioThreadEndpoint beginMessageGroup];
}

- (void)endMessageGroup {
    [self.audioThreadEndpoint endMessageGroup];
}

void AEMessageQueuePoll(__unsafe_unretained AEMessageQueue * _Nonnull THIS) {
    AEAudioThreadEndpointPoll(THIS->_audioThreadEndpoint);
}

@end
