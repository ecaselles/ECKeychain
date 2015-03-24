//
//  ECKeychain.h
//
//  Created by Eduardo Caselles on 12/11/2014.
//  Copyright (c) 2014 Eduardo Caselles. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  The `ECKeychain` class is just a simple abstraction layer for managing items
 *  in Keychain.
 */
@interface ECKeychain : NSObject

/**
 *  Retrieves the item in the Keychain, if it exists, related to the given
 *  account, service and access group.
 *
 *  @param account     The account you want to retrieve the data for.
 *  @param service     The service you want to retrieve the data for.
 *  @param accessGroup The access group (iOS only) used to share this item among
 *                     multiple apps.
 *
 *  @return The first item in Keychain for the given parameters, `nil` if no
 *          items were found.
 */
+ (NSData *)dataForAccount:(NSString *)account
                 inService:(NSString *)service
           withAccessGroup:(NSString *)accessGroup;

/**
 *  Adds the item in the Keychain, or updates it if it already exists, related
 *  to the given account, service and access group.
 *
 *  @param data           The item to store/update in Keychain.
 *  @param account        The account you want to store/update the data for.
 *  @param service        The service you want to store/update the data for.
 *  @param accessGroup    The access group (iOS, or OS X if synchronizable
 *                        set to `YES`) used to share this item among multiple
 *                        apps.
 *  @param synchronizable Indicates whether the item can be synchronized among
 *                        multiple devices (iCloud Keychain).
 *
 *  @return `YES` if the item was successfully added or updated, `NO` otherwise.
 */
+ (BOOL)setData:(NSData *)data
     forAccount:(NSString *)account
      inService:(NSString *)service
withAccessGroup:(NSString *)accessGroup
 synchronizable:(BOOL)synchronizable;

/**
 *  Deletes the item in the Keychain related to the given account, service and
 *  access group.
 *
 *  @param account     The account you want to delete the data for.
 *  @param service     The service you want to delete the data for.
 *  @param accessGroup The access group (iOS, or OS X if the item is
 *                     synchronizable) used to share this item among multiple
 *                     apps.
 *
 *  @return `YES` if the item was successfully deleted, `NO` otherwise.
 */
+ (BOOL)deleteDataForAccount:(NSString *)account
                   inService:(NSString *)service
             withAccessGroup:(NSString *)accessGroup;

@end
