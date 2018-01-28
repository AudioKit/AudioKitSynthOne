//
//  AEManagedValue.h
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

#ifdef __cplusplus
extern "C" {
#endif
    
#import <Foundation/Foundation.h>

//! Batch update block
typedef void (^AEManagedValueUpdateBlock)(void);

/*!
 * Release block
 *
 * @param value Original value provided
 */
typedef void (^AEManagedValueReleaseBlock)(void * _Nonnull value);

//! Release notification block
typedef void (^AEManagedValueReleaseNotificationBlock)(void);

/*!
 * Managed value
 *
 *  This class manages a mutable reference to a memory buffer or Objective-C object which is both thread-safe
 *  and realtime safe. It manages the life-cycle of the buffer/object so that it can not be deallocated
 *  while being accessed on the main thread, and does so without locking the realtime thread.
 *
 *  You can use this utility to manage a single module instance, which can be swapped out for
 *  another at any time, for instance.
 *
 *  Remember to use the __unsafe_unretained directive to avoid ARC-triggered retains on the
 *  audio thread if using this class to manage an Objective-C object, and only interact with such objects
 *  via C functions they provide, not via Objective-C methods.
 */
@interface AEManagedValue : NSObject

/*!
 * Update multiple AEManagedValue instances atomically
 *
 *  Any changes made within the block will be applied atomically with respect to the audio thread.
 *  Any value accesses made from the realtime thread while the block is executing will return the
 *  prior value, until the block has completed.
 *
 *  These may be nested safely.
 *
 *  If you are not using AEAudioUnitOutput, then you must call the AEManagedValueCommitPendingUpdates
 *  function at the beginning of your main render loop, particularly if you use this method. This 
 *  ensures batched updates are all committed in sync with your render loop. Until this function is
 *  called, AEManagedValueGetValue returns old values, prior to those set in the given block.
 *
 * @param block Atomic update block
 */
+ (void)performAtomicBatchUpdate:(AEManagedValueUpdateBlock _Nonnull)block;

/*!
 * Get access to the value on the realtime audio thread
 *
 *  The object or buffer returned is guaranteed to remain valid until the next call to this function.
 *
 *  Can also be called safely on the main thread (although the @link objectValue @endlink and
 *  @link pointerValue @endlink properties are easier).
 *
 * @param managedValue The instance
 * @return The value
 */
void * _Nullable AEManagedValueGetValue(__unsafe_unretained AEManagedValue * _Nonnull managedValue);

/*!
 * Commit pending updates on the realtime thread
 *
 *  If you are not using AEAudioUnitOutput, then you should call this function at the start of 
 *  your top-level render loop in order to apply updates in sync. If you are using AEAudioUnitOutput, 
 *  then this function is already called for you within that class, so you don't need to do so yourself.
 *
 *  After this function is called, any updates made within the block passed to performAtomicBatchUpdate:
 *  become available on the render thread, and any old values are scheduled for release on the main thread.
 *
 *  Important: Only call this function on the audio thread. If you call this on the main thread, you
 *  will see sporadic crashes on the audio thread.
 */
void AEManagedValueCommitPendingUpdates(void);

/*!
 * Set object value with a completion block
 *
 * @property objectValue The object value
 * @property completionBlock Block to perform once the old value is to be released
 */
- (void)setObjectValue:(id _Nullable )objectValue withCompletionBlock:(void(^_Nullable)(id _Nullable oldValue))completionBlock;

/*!
 * Set pointer value with a completion block
 *
 * @property pointerValue The pointer value
 * @property completionBlock Block to perform once the old value is to be released
 */
- (void)setPointerValue:(void * _Nullable)pointerValue withCompletionBlock:(void(^_Nullable)(void * _Nullable oldValue))completionBlock;

/*!
 * An object. You can set this property from the main thread. Note that you can use this property, 
 * or pointerValue, but not both.
 */
@property (nonatomic, strong) id _Nullable objectValue;

/*!
 * A pointer to an allocated memory buffer. Old values will be automatically freed when the value 
 * changes. You can set this property from the main thread. Note that you can use this property, 
 * or objectValue, but not both.
 */
@property (nonatomic) void * _Nullable pointerValue;

/*!
 * Block to perform when deleting old items, on main thread. If not specified, will simply use 
 * free() to dispose values set via pointerValue, or CFBridgingRelease() to dispose values set via objectValue.
 */
@property (nonatomic, copy) AEManagedValueReleaseBlock _Nullable releaseBlock;

/*!
 * Block for release notifications. Use this to be informed when an old value has been released.
 */
@property (nonatomic, copy) AEManagedValueReleaseNotificationBlock _Nullable releaseNotificationBlock;

@end

#ifdef __cplusplus
}
#endif
