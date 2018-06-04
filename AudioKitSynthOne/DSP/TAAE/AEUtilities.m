//
//  AEUtilities.m
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 23/03/2016.
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

#import "AEUtilities.h"
#import "AETime.h"

AudioComponentDescription AEAudioComponentDescriptionMake(OSType manufacturer, OSType type, OSType subtype) {
    AudioComponentDescription description;
    memset(&description, 0, sizeof(description));
    description.componentManufacturer = manufacturer;
    description.componentType = type;
    description.componentSubType = subtype;
    return description;
}

BOOL AERateLimit(void) {
    static double lastMessage = 0;
    static int messageCount=0;
    double now = AECurrentTimeInSeconds();
    if ( now-lastMessage > 1 ) {
        messageCount = 0;
        lastMessage = now;
    }
    if ( ++messageCount >= 10 ) {
        if ( messageCount == 10 ) {
            NSLog(@"TAAE: Suppressing some messages");
        }
        return NO;
    }
    return YES;
}

void AEError(OSStatus result, const char * _Nonnull operation, const char * _Nonnull file, int line) {
    if ( AERateLimit() ) {
        int fourCC = CFSwapInt32HostToBig(result);
        if ( isascii(((char*)&fourCC)[0]) && isascii(((char*)&fourCC)[1]) && isascii(((char*)&fourCC)[2]) ) {
            NSLog(@"%s:%d: %s: '%4.4s' (%d)", file, line, operation, (char*)&fourCC, (int)result);
        } else {
            NSLog(@"%s:%d: %s: %d", file, line, operation, (int)result);
        }
    }
}

ExtAudioFileRef AEExtAudioFileCreate(NSURL * url, AEAudioFileType fileType, double sampleRate, int channelCount,
                                        NSError ** error) {
    
    AudioStreamBasicDescription asbd = {
        .mChannelsPerFrame = channelCount,
        .mSampleRate = sampleRate,
    };
    AudioFileTypeID fileTypeID;
    
    if ( fileType == AEAudioFileTypeM4A ) {
        // AAC encoding in M4A container
        // Get the output audio description for encoding AAC
        asbd.mFormatID = kAudioFormatMPEG4AAC;
        UInt32 size = sizeof(asbd);
        OSStatus status = AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &size, &asbd);
        if ( !AECheckOSStatus(status, "AudioFormatGetProperty(kAudioFormatProperty_FormatInfo") ) {
            int fourCC = CFSwapInt32HostToBig(status);
            if ( error ) *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                      code:status
                                                  userInfo:@{ NSLocalizedDescriptionKey:
                                                                  [NSString stringWithFormat:NSLocalizedString(@"Couldn't prepare the output format (error %d/%4.4s)", @""), status, (char*)&fourCC]}];
            return NULL;
        }
        fileTypeID = kAudioFileM4AType;
        
    } else if ( fileType == AEAudioFileTypeAIFFFloat32 ) {
        // 32-bit floating point
        asbd.mFormatID = kAudioFormatLinearPCM;
        asbd.mFormatFlags = kLinearPCMFormatFlagIsFloat | kAudioFormatFlagIsPacked | kAudioFormatFlagIsBigEndian;
        asbd.mBitsPerChannel = sizeof(float) * 8;
        asbd.mBytesPerPacket = asbd.mChannelsPerFrame * sizeof(float);
        asbd.mBytesPerFrame = asbd.mBytesPerPacket;
        asbd.mFramesPerPacket = 1;
        fileTypeID = kAudioFileAIFCType;
        
    } else {
        // 16-bit signed integer
        asbd.mFormatID = kAudioFormatLinearPCM;
        asbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked |
                            (fileType == AEAudioFileTypeAIFFInt16 ? kAudioFormatFlagIsBigEndian : 0);
        asbd.mBitsPerChannel = 16;
        asbd.mBytesPerPacket = asbd.mChannelsPerFrame * 2;
        asbd.mBytesPerFrame = asbd.mBytesPerPacket;
        asbd.mFramesPerPacket = 1;
        
        if ( fileType == AEAudioFileTypeAIFFInt16 ) {
            fileTypeID = kAudioFileAIFFType;
        } else {
            fileTypeID = kAudioFileWAVEType;
        }
    }
    
    // Open the file
    ExtAudioFileRef audioFile;
    OSStatus status = ExtAudioFileCreateWithURL((__bridge CFURLRef)url, fileTypeID, &asbd, NULL, kAudioFileFlags_EraseFile,
                                                &audioFile);
    if ( !AECheckOSStatus(status, "ExtAudioFileCreateWithURL") ) {
        if ( error )
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                     code:status
                                 userInfo:@{ NSLocalizedDescriptionKey:
                                                 NSLocalizedString(@"Couldn't open the output file", @"") }];
        return NULL;
    }
    
    // Set the client format
    asbd = AEAudioDescriptionWithChannelsAndRate(channelCount, sampleRate);
    status = ExtAudioFileSetProperty(audioFile,
                                     kExtAudioFileProperty_ClientDataFormat,
                                     sizeof(asbd),
                                     &asbd);
    if ( !AECheckOSStatus(status, "ExtAudioFileSetProperty") ) {
        ExtAudioFileDispose(audioFile);
        if ( error )
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                     code:status
                                 userInfo:@{ NSLocalizedDescriptionKey:
                                                 NSLocalizedString(@"Couldn't configure the file writer", @"") }];
        return NULL;
    }
    
    return audioFile;
}

ExtAudioFileRef _Nullable AEExtAudioFileOpen(NSURL * url, AudioStreamBasicDescription * outAudioDescription,
                                             UInt64 * outLengthInFrames, NSError ** error) {
         
    // Open the file
    ExtAudioFileRef reader;
    OSStatus result = ExtAudioFileOpenURL((__bridge CFURLRef)url, &reader);
    if ( !AECheckOSStatus(result, "ExtAudioFileOpenURL") ) {
        if ( error )
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:result
                                 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't open source file"}];
        return NULL;
    }
    
    // Get the file data format
    AudioStreamBasicDescription fileDescription;
    UInt32 size = sizeof(fileDescription);
    result = ExtAudioFileGetProperty(reader, kExtAudioFileProperty_FileDataFormat, &size, &fileDescription);
    if ( !AECheckOSStatus(result, "ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat)") ) {
        ExtAudioFileDispose(reader);
        if ( error )
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:result
                                 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't read source file"}];
        return NULL;
    }
    
    if ( outLengthInFrames ) {
        // Determine length in frames
        UInt64 fileLengthInFrames;
        AudioFilePacketTableInfo packetInfo;
        UInt32 size = sizeof(packetInfo);
        result = ExtAudioFileGetProperty(reader, kExtAudioFileProperty_PacketTable, &size, &packetInfo);
        if ( result != noErr ) {
            size = 0;
        }
        
        if ( size > 0 ) {
            fileLengthInFrames = packetInfo.mNumberValidFrames;
        } else {
            UInt64 frameCount;
            size = sizeof(frameCount);
            result = ExtAudioFileGetProperty(reader, kExtAudioFileProperty_FileLengthFrames, &size, &frameCount);
            if ( !AECheckOSStatus(result, "ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames)") ) {
                ExtAudioFileDispose(reader);
                if ( error )
                *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:result
                                         userInfo:@{NSLocalizedDescriptionKey: @"Couldn't read source file"}];
                return NULL;
            }
            fileLengthInFrames = frameCount;
        }
        
        *outLengthInFrames = fileLengthInFrames;
    }
    
    // Set the client format
    AudioStreamBasicDescription clientFormat =
        AEAudioDescriptionWithChannelsAndRate(fileDescription.mChannelsPerFrame, fileDescription.mSampleRate);
    result = ExtAudioFileSetProperty(reader, kExtAudioFileProperty_ClientDataFormat, sizeof(clientFormat), &clientFormat);
    if ( !AECheckOSStatus(result, "ExtAudioFileGetProperty(kExtAudioFileProperty_ClientDataFormat)") ) {
        ExtAudioFileDispose(reader);
        if ( error )
            *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:result
                                     userInfo:@{NSLocalizedDescriptionKey: @"Couldn't configure file for reading"}];
        return NULL;
    }
    
    if ( outAudioDescription ) *outAudioDescription = clientFormat;
    
    return reader;
}

