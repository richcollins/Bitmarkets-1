//
//  MKMarketChannel.m
//  Bitmessage
//
//  Created by Steve Dekorte on 3/13/14.
//  Copyright (c) 2014 Bitmarkets.org. All rights reserved.
//

#import "MKMarketChannel.h"
#import <BitMessageKit/BitMessageKit.h>
#import "MKMsg.h"
#import "MKSell.h"

@implementation MKMarketChannel

- (NSString *)nodeTitle
{
    return @"Channel";
}

- (id)init
{
    self = [super init];
    self.passphrase = @"bitmarkets";
    self.allAsks = [[NavInfoNode alloc] init];
    self.allAsks.nodeSuggestedWidth = 250;
    [self.allAsks setNodeTitle:@"Sells"];
    [self addChild:self.allAsks];
    
    self.validMessages = [[NavInfoNode alloc] init];
    [self.validMessages setNodeTitle:@"Messages"];
    self.validMessages.nodeSuggestedWidth = 250;
    [self addChild:self.validMessages];
    
    return self;
}

- (CGFloat)nodeSuggestedWidth
{
    return 250;
}

- (BMChannel *)channel
{
    if (!_channel)
    {
        _channel = [BMClient.sharedBMClient.channels channelWithPassphraseJoinIfNeeded:self.passphrase];
    }
    
    return _channel;
}

- (void)fetch
{
    // just make sure this is in the fetch chain from BMClient?
    //[[[BMClient sharedBMClient] channels] fetch];

    NSArray *messages = self.channel.children.copy;
    NSMutableArray *newChildren = [NSMutableArray array];
    
    for (BMReceivedMessage *bmMsg in messages)
    {
        MKPostMsg *msg = (MKPostMsg *)[MKMsg withBMMessage:bmMsg];
        
        //[bmMsg delete]; continue;
        
        if (msg && [msg isKindOfClass:MKPostMsg.class])
        {
            MKPost *mkPost = [msg mkPost];
            BOOL couldPlace = [mkPost placeInMarketsPath]; // deals with merging?
            if (couldPlace)
            {
                [newChildren addObject:mkPost];
            }
            else
            {
                [bmMsg delete];
            }
        }
        else
        {
            //[bmMsg delete];
            continue;
        }
        
        //[self.allAsks mergeWithChildren:newChildren];
    }
}


@end