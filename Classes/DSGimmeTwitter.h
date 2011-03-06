//
//  DSGimmeTwitter.h
//  DSGimmeTwitter
//
//  Created by Derek Smith on 3/5/11.
//  Copyright 2011 Dsmitts. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXOAuth2.h"

@interface DSCallback : NSObject <NXOAuth2ConnectionDelegate>
{
    @private
    id delegate;
    SEL successMethod;
    SEL failureMethod;
}

@property (nonatomic, readonly) id delegate;
@property (nonatomic, readonly) SEL successMethod;
@property (nonatomic, readonly) SEL failureMethod;

+ (DSCallback*) callbackWithDelegate:(id)delegate successMethod:(SEL)method failureMethod:(SEL)method;
- (id) initWithDelegate:(id)delegate successMethod:(SEL)method failureMethod:(SEL)method;

@end

@interface DSGimmeTwitter : NXOAuth2Client {
    
    @private
    BOOL flipped;
}

// The key/secret pair should be your consumer key and secret that 
// you were issued when you registered your application with Foursquare.
- (id) initWithKey:(NSString*)key secret:(NSString*)secret delegate:(id<NXOAuth2ClientDelegate>)delegate;

// Direct Messages
- (void) sendDirectMessage:(NSString*)message toUser:(NSString*)userid callback:(DSCallback*)callback;

// Friends
- (void) getFriendsForUser:(NSString*)userid callback:(DSCallback*)callback;

@end

@interface NSString (Dsmitts)

- (NSString*) URLEncodedString;
- (NSString*) MinimalURLEncodedString;
- (NSString*) URLDecodedString;

@end
