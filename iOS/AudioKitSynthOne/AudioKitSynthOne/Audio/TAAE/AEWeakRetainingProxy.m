//
//  AEWeakRetainingProxy.m
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 8/06/2016.
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

#import "AEWeakRetainingProxy.h"

@interface AEWeakRetainingProxy ()
@property (nonatomic, weak, readwrite) id target;
@end

@implementation AEWeakRetainingProxy

+ (instancetype)proxyWithTarget:(id)target {
    AEWeakRetainingProxy * proxy = [AEWeakRetainingProxy alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [_target methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    __strong id target = _target;
    [invocation setTarget:target];
    [invocation invoke];
}

@end
