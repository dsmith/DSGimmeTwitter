//
//  DSGimmeTwitter.m
//  DSGimmeTwitter
//
//  Created by Derek Smith on 3/5/11.
//  Copyright 2011 Dsmitts. All rights reserved.
//

#import "DSGimmeTwitter.h"

static NSString* twitterURL = @"http://api.twitter.com/1.0";

@interface DSGimmeTwitter (Private)

- (void) sendHTTPRequest:(NSString*)type 
                   toURL:(NSString*)url
              withParams:(NSDictionary*)httpBody 
                callback:(DSCallback*)callback;

- (NSString*) normalizeRequestParams:(NSDictionary*)params;
- (void) reloadCache;

@end

@implementation DSGimmeTwitter

- (id) initWithKey:(NSString*)key secret:(NSString*)secret delegate:(id<NXOAuth2ClientDelegate, NSObject>)del
{
    if((self = [super initWithClientID:key
                         clientSecret:secret
                         authorizeURL:[NSURL URLWithString:@"https://api.twitter.com/oauth2/authenticate"]
                             tokenURL:[NSURL URLWithString:@"https://api.twitter.com/oauth2/access_token"]
                             delegate:del])) {
    }
    
    return self;
}

// Direct Messages
- (void) sendDirectMessage:(NSString*)message toUser:(NSString*)userid callback:(DSCallback*)callback
{
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:userid, @"user_id",
                            message, @"text",
                            nil];

    [self sendHTTPRequest:@"POST"
                    toURL:@"direct_messages/new"
               withParams:params
                 callback:callback];
}

// Friends
- (void) getFriendsForUser:(NSString*)userid callback:(DSCallback*)callback
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"user_id", userid, nil];
    
    [self sendHTTPRequest:@"GET"
                    toURL:@"friends/ids"
               withParams:params
                 callback:callback];
}

////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utility methods
////////////////////////////////////////////////////////////////////////////////////////////////

- (void) sendHTTPRequest:(NSString*)type toURL:(NSString*)file withParams:(NSDictionary*)params callback:(DSCallback*)callback
{	
    file = [file stringByAppendingFormat:@".json"];
    NSMutableDictionary* oauthParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        self.accessToken.accessToken, @"oauth_token", nil];
    if(params)
        [oauthParams addEntriesFromDictionary:params];
    
    file = [file stringByAppendingFormat:@"?%@", [self normalizeRequestParams:oauthParams]];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", twitterURL, file]];
    
    NSLog(@"DSGimmeTwitter - Sending %@ to %@", type, file);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:type];
    
    // We probably want to hold onto this object and release
    // it at some point.
    [[[NXOAuth2Connection alloc] initWithRequest:request
                                     oauthClient:self
                                        delegate:callback] autorelease];
}

- (NSString*) normalizeRequestParams:(NSDictionary*)params
{
    NSMutableArray* parameterPairs = [NSMutableArray arrayWithCapacity:([params count])];
    NSString* value;
    for(NSString* param in params) {
        value = [params objectForKey:param];
        param = [NSString stringWithFormat:@"%@=%@", [param URLEncodedString], [value URLEncodedString]];
        [parameterPairs addObject:param];
    }
    
    NSArray* sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    return [sortedPairs componentsJoinedByString:@"&"];
}

@end

@implementation DSCallback
@synthesize delegate, successMethod, failureMethod;

- (id) initWithDelegate:(id)d successMethod:(SEL)sMethod failureMethod:(SEL)fMethod
{
    if((self = [super init])) {
        delegate = d;
        successMethod = sMethod;
        failureMethod = fMethod;
    }
    
    return self;
}

+ (DSCallback*) callbackWithDelegate:(id)delegate successMethod:(SEL)successMethod failureMethod:(SEL)failureMethod
{
    return [[[DSCallback alloc] initWithDelegate:delegate successMethod:successMethod failureMethod:failureMethod] autorelease];
}

- (void) oauthConnection:(NXOAuth2Connection*)connection didFinishWithData:(NSData *)data
{
    [delegate performSelector:successMethod withObject:data];    
}

- (void) oauthConnection:(NXOAuth2Connection*)connection didFailWithError:(NSError *)error
{
    [delegate performSelector:failureMethod withObject:error];
}

@end

@implementation NSString (Dsmitts)

- (NSString*) URLEncodedString 
{
    
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?#[]"),
                                                                           kCFStringEncodingUTF8);
    return result;
}

- (NSString*) MinimalURLEncodedString {
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           CFSTR("%"),             
                                                                           CFSTR("?=&+"),          
                                                                           kCFStringEncodingUTF8); 
    [result autorelease];
    return result;
}

- (NSString*) URLDecodedString
{
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;  
}

@end