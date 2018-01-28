//
//  AEAudioThreadEndpoint.m
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 29/04/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//

#import "AEAudioThreadEndpoint.h"
#import "AudioKit/TPCircularBuffer.h"

@interface AEAudioThreadEndpoint () {
    TPCircularBuffer _buffer;
    int _groupNestCount;
    int32_t _groupLength;
}
@property (nonatomic, copy) AEAudioThreadEndpointHandler handler;
@end

@implementation AEAudioThreadEndpoint

- (instancetype)initWithHandler:(AEAudioThreadEndpointHandler)handler {
    return [self initWithHandler:handler bufferCapacity:8192];
}

- (instancetype)initWithHandler:(AEAudioThreadEndpointHandler)handler bufferCapacity:(size_t)bufferCapacity {
    if ( !(self = [super init]) ) return nil;
    
    self.handler = handler;
    
    if ( !TPCircularBufferInit(&_buffer, (int32_t)bufferCapacity) ) {
        return nil;
    }
    
    return self;
}

- (void)dealloc {
    TPCircularBufferCleanup(&_buffer);
}

void AEAudioThreadEndpointPoll(__unsafe_unretained AEAudioThreadEndpoint * _Nonnull THIS) {
    while ( 1 ) {
        // Get pointer to readable bytes
        int32_t availableBytes;
        void * tail = TPCircularBufferTail(&THIS->_buffer, &availableBytes);
        if ( availableBytes == 0 ) return;
        
        // Get length and data
        size_t length = *((size_t*)tail);
        void * data = length > 0 ? (tail + sizeof(size_t)) : NULL;
        
        // Run handler
        THIS->_handler(data, length);
        
        // Mark as read
        TPCircularBufferConsume(&THIS->_buffer, (int32_t)(sizeof(size_t) + length));
    }
}

- (BOOL)sendBytes:(const void *)bytes length:(size_t)length {
    // Prepare message
    void * message = [self createMessageWithLength:length];
    if ( !message ) {
        return NO;
    }
    
    if ( length ) {
        // Copy data
        memcpy(message, bytes, length);
    }
    
    // Dispatch
    [self dispatchMessage];
    
    return YES;
}

- (void *)createMessageWithLength:(size_t)length {
    // Get pointer to writable bytes
    int32_t size = (int32_t)(length + sizeof(size_t));
    int32_t availableBytes;
    void * head = TPCircularBufferHead(&_buffer, &availableBytes);
    if ( availableBytes < size + (_groupNestCount > 0 ? _groupLength : 0) ) {
        return nil;
    }
    
    if ( _groupNestCount > 0 ) {
        // If we're grouping messages, write to end of group
        head += _groupLength;
    }
    
    // Write to buffer: the length of the message, and the message data
    *((size_t*)head) = length;
    
    // Return the following region ready for writing
    return head + sizeof(size_t);
}

-(void)dispatchMessage {
    // Get pointer to writable bytes
    int32_t availableBytes;
    void * head = TPCircularBufferHead(&_buffer, &availableBytes);
    if ( _groupNestCount > 0 ) {
        // If we're grouping messages, write to end of group
        head += _groupLength;
    }
    
    size_t size = *((size_t*)head) + sizeof(size_t);
    
    if ( _groupNestCount == 0 ) {
        TPCircularBufferProduce(&_buffer, (int32_t)size);
    } else {
        _groupLength += size;
    }
}

- (void)beginMessageGroup {
    _groupNestCount++;
}

- (void)endMessageGroup {
    _groupNestCount--;
    
    if ( _groupNestCount == 0 && _groupLength > 0 ) {
        TPCircularBufferProduce(&_buffer, _groupLength);
        _groupLength = 0;
    }
}

@end
