# ECKeychain

The `ECKeychain` class is just a simple abstraction layer for managing items in Apple's Keychain.

It comes with a set of methods for the most common operations done in Keychain (to **set**, to **get** and to **delete** items associated to an account and service).

## Installation

[CocoaPods](http://cocoapods.org/) is the recommended way to import `ECKeychain` into your project. You just need  to add the following to your `Podfile` and run `$ pod install`.

```ruby
pod 'ECKeychain'
```

If you can't use [CocoaPods](http://cocoapods.org/), you can still download `ECKeychain` and manually add the source files under `ECKeychain` folder to your project.

## Usage

`ECKeychain` is implemented as a group of class methods, so they can be called through different parts of the app, without having to create instances of the class.

### Set item in Keychain

```Objective-C
NSString *password = @"This is a password!";
NSData *keychainData = [password dataUsingEncoding:NSUTF8StringEncoding];
BOOL result = [ECKeychain setData:keychainData
                       forAccount:@"account"
                        inService:@"service"
                  withAccessGroup:nil
                   synchronizable:NO];
if (result) {
  NSLog(@"Password was successfully stored in Keychain.");
}
```

### Get item from Keychain

```Objective-C
NSData *keychainData = [ECKeychain dataForAccount:@"account" 
                                        inService:@"service"
                                  withAccessGroup:nil];
if (keychainData) {
  NSString *password = [[NSString alloc] initWithData:keychainData
                                             encoding:NSUTF8StringEncoding];
  if (password) {
    NSLog(@"Password retrieved from Keychain was: %@.", password);
  }
}
```

### Delete item from Keychain

```Objective-C
BOOL result = [ECKeychain deleteDataForAccount:@"account"
                                     inService:@"service"
                               withAccessGroup:nil];
if (result) {
  NSLog(@"Password was succcessfully deleted from Keychain.");
}
```

## License

`ECKeychain` is available under the MIT license. See the LICENSE file for more info.
