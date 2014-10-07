//
//  LDAPTest.m
//  MIApp
//
//  Created by Gursimran Singh on 2/10/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ldapTest.h"

@interface LDAPTest : XCTestCase

@end

@implementation LDAPTest
{
    NSDictionary* ldapInfo;
    NSString* basedn;
    NSString* uri;
    int version;
    NSString* searchScope;
    NSString* binddn;
    NSString* username;
    NSString *password;
    const char *caFile;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    ldapInfo = [[NSBundle mainBundle].infoDictionary objectForKey:@"LDAPLoginDetails"];
    basedn = [ldapInfo objectForKey:@"basedn"];
    uri = [ldapInfo objectForKey:@"urise"];
    version = ((NSNumber*)[ldapInfo objectForKey:@"version"]).intValue;
    searchScope = [ldapInfo objectForKey:@"filterBy"];
    binddn = [ldapInfo objectForKey:@"binddn"];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"ca-certs" ofType:@"pem"];
    caFile   = [filePath UTF8String];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testTechnicianPassed
{
    username = @"moe";
    password = @"moe";
    
    
    searchScope = [searchScope stringByReplacingOccurrencesOfString:@"*" withString:username];
    binddn = [binddn stringByReplacingOccurrencesOfString:@"*" withString:username];
    
    
    test_all_ldap(caFile);
    NSString* message = test_simple_ldap(version, [uri UTF8String], [binddn UTF8String], [password UTF8String], [basedn UTF8String], [searchScope UTF8String], MY_LDAP_SCOPE, caFile);
    
    XCTAssertTrue([message rangeOfString:@"technician"].location != NSNotFound, @"Authentication Test Passed, User logged in as technician (Username:%@)", username);
}

- (void)testTechnicianFailed
{
    username = @"anita";
    password = @"anita";
    
    
    searchScope = [searchScope stringByReplacingOccurrencesOfString:@"*" withString:username];
    binddn = [binddn stringByReplacingOccurrencesOfString:@"*" withString:username];
    
    
    test_all_ldap(caFile);
    NSString* message = test_simple_ldap(version, [uri UTF8String], [binddn UTF8String], [password UTF8String], [basedn UTF8String], [searchScope UTF8String], MY_LDAP_SCOPE, caFile);
    
    XCTAssertFalse([message rangeOfString:@"technician"].location != NSNotFound, @"Authentication Test Passed, User logged in as technician (Username:%@)", username);
}

@end
