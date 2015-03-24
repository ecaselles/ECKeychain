//
//  ECKeychain.m
//
//  Created by Eduardo Caselles on 12/11/2014.
//  Copyright (c) 2014 Eduardo Caselles. All rights reserved.
//

#import "ECKeychain.h"

@implementation ECKeychain

#pragma mark - Private methods

+ (NSMutableDictionary *)queryDictionaryForAccount:(NSString *)account
                                         inService:(NSString *)service
                                   withAccessGroup:(NSString *)accessGroup
{
    // Begin Keychain search setup. The genericPasswordQuery leverages the special user
    // defined attribute kSecAttrGeneric to distinguish itself between other generic Keychain
    // items which may be included by the same application.
    NSMutableDictionary *queryDictionary = [[NSMutableDictionary alloc] init];
    
    [queryDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [queryDictionary setObject:account forKey:(__bridge id)kSecAttrAccount];
    [queryDictionary setObject:service forKey:(__bridge id)kSecAttrService];
    
    // The keychain access group attribute determines if this item can be shared
    // amongst multiple apps whose code signing entitlements contain the same keychain access group.
#if !TARGET_IPHONE_SIMULATOR
    if (accessGroup != nil) {
        [queryDictionary setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
    
    // Keychain synchronization available
#if __MAC_10_9 || __IPHONE_7_0
    [queryDictionary setObject:(__bridge id)kSecAttrSynchronizableAny forKey:(__bridge id)kSecAttrSynchronizable];
#endif
    
    return queryDictionary;
}

// Retrieves only the attributes of the item in the keychain, if it exists.
+ (NSDictionary *)attributesForAccount:(NSString *)account
                             inService:(NSString *)service
                       withAccessGroup:(NSString *)accessGroup
{
    NSMutableDictionary *queryDictionary = [self queryDictionaryForAccount:account
                                                                 inService:service
                                                           withAccessGroup:accessGroup];
    
    // Use the proper search constants, return only the attributes of the first match.
    [queryDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [queryDictionary setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    CFDictionaryRef queryOutput = nil;
    OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&queryOutput);
    if (result == errSecSuccess) {
        NSLog(@"Failed to get attributes Keychain item attributes for account \"%@\" in service \"%@\" (Error %li)", account, service, (long int)result);
    }
    
    return (__bridge NSDictionary *)queryOutput;
}

#pragma mark - Public methods

+ (NSData *)dataForAccount:(NSString *)account
                 inService:(NSString *)service
           withAccessGroup:(NSString *)accessGroup
{
    NSMutableDictionary *queryDictionary = [self queryDictionaryForAccount:account
                                                                 inService:service
                                                           withAccessGroup:accessGroup];
    
    // Use the proper search constants, return only the attributes of the first match.
    [queryDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [queryDictionary setObject:@YES forKey:(__bridge id)kSecReturnData];
    
    NSData *data = nil;
    CFDataRef queryOutput = nil;
    OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&queryOutput);
    if (result == errSecSuccess) {
        data = (__bridge_transfer NSData *)queryOutput;
    }
    else {
        NSLog(@"Failed to get Keychain item for account \"%@\" in service \"%@\" (Error %li)", account, service, (long int)result);
    }
    
    return data;
}

+ (BOOL)setData:(NSData *)data
     forAccount:(NSString *)account
      inService:(NSString *)service
withAccessGroup:(NSString *)accessGroup
 synchronizable:(BOOL)synchronizable
{
    NSMutableDictionary *queryDictionary = [self queryDictionaryForAccount:account
                                                                 inService:service
                                                           withAccessGroup:accessGroup];
    OSStatus result;
    
    // Check if the item exists
    NSDictionary *existingDictionary = [self attributesForAccount:account
                                                        inService:service
                                                  withAccessGroup:accessGroup];
    if (existingDictionary) {
#if __IPHONE_7_0 || __MAC_10_9
        // Check if synchronizable is different
        NSNumber *isSyncronizable = [existingDictionary objectForKey:(__bridge id)kSecAttrSynchronizable];
        
        if ([isSyncronizable boolValue] != synchronizable) {
            // Since syncronizability has changed, delete the existing one and will add as a new one.
            // Because SecItemUpdate does not work if setting kSecAttrSynchronizable.
            [self deleteDataForAccount:account
                             inService:service
                       withAccessGroup:accessGroup];
        }
        else {
            // Update item
#endif
            NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
            [updateDictionary setObject:data forKey:(__bridge id)kSecValueData];
            
            result = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateDictionary);
            
            if (result != errSecSuccess) {
                NSLog(@"Failed to update Keychain item for account \"%@\" in service \"%@\" (Error %li)", account, service, (long int)result);
            }
            
            return (result == errSecSuccess);
        }
    }
    
    // Add new item
    [queryDictionary setObject:data forKey:(__bridge id)kSecValueData];
#if __MAC_10_9 || __IPHONE_7_0
    [queryDictionary setObject:@(synchronizable) forKey:(__bridge id)(kSecAttrSynchronizable)];
#endif
    result = SecItemAdd((__bridge CFDictionaryRef)queryDictionary, nil);
    
    if (result != errSecSuccess) {
        NSLog(@"Failed to add Keychain item for account \"%@\" in service \"%@\" (Error %li)", account, service, (long int)result);
    }
    
    return (result == errSecSuccess);
}

+ (BOOL)deleteDataForAccount:(NSString *)account
                   inService:(NSString *)service
             withAccessGroup:(NSString *)accessGroup
{
    NSMutableDictionary *queryDictionary = [self queryDictionaryForAccount:account
                                                                 inService:service
                                                           withAccessGroup:accessGroup];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
    if (result != errSecSuccess) {
        NSLog(@"Failed to delete Keychain item for account \"%@\" in service \"%@\" (Error %li)", account, service, (long int)result);
    }
    
    return (result == errSecSuccess);
}

@end
