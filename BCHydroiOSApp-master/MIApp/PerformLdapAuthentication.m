//
//  PerformLdapAuthentication.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-05.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "PerformLdapAuthentication.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "ldapTest.h"
#import "QuestionList.h"
#import "KeyList.h"

@implementation PerformLdapAuthentication


//get ip address of device
+ (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;    
}

//Log user in
+(NSString*) performLDAP
{
    //check if ldap to use or login with users in plist
    if ([[KeyList sharedInstance] useLDAP]) {
        return [self loginWithLdap];
    }else{
        return [self loginWithoutLDAP];
    }
    
}

//log in using ldap
+(NSString*)loginWithLdap
{
    //Get ldap login info from App's info.plist and data entered by user
    
    NSString* ip = [self getIPAddress];
    NSString* basedn = [[KeyList sharedInstance] basednLdapKey];
    //NSString* sslMechanism = [ldapInfo objectForKey:@"ssl"];
    NSString* uri;
    if ([ip rangeOfString:@"172.16.1."].location != NSNotFound) {
        uri = [[KeyList sharedInstance] uriSslLdapKey];
    }else{
        uri = [[KeyList sharedInstance] uriSslExternalLdapKey];
    }
    int version = [[KeyList sharedInstance] versionLdapKey].intValue;
    NSString* searchScope = [[KeyList sharedInstance] filterSearchQueryByUserLdapKey];
    NSString* binddn = [[KeyList sharedInstance] binddnLdapKey];
    NSString* username = [[QuestionList sharedInstance] username];
    searchScope = [searchScope stringByReplacingOccurrencesOfString:@"*" withString:username];
    binddn = [binddn stringByReplacingOccurrencesOfString:@"*" withString:username];
    NSString *password = [[QuestionList sharedInstance] password];
    
    //Set up ca file
    NSString          * filePath;
    const char        * caFile;
    filePath = [[NSBundle mainBundle] pathForResource:@"ca-certs" ofType:@"pem"];
    caFile   = [filePath UTF8String];
    test_all_ldap(caFile);
    
    //perform authentication
    //NOTE: This method needs to be altered depending on the message from ldap server
    
    NSString* message = test_simple_ldap(version, [uri UTF8String], [binddn UTF8String], [password UTF8String], [basedn UTF8String], [searchScope UTF8String], MY_LDAP_SCOPE, caFile);
    
    //NSString* message = test_sasl_ldap(version, [uri UTF8String], [username UTF8String], NULL, [password UTF8String], [sslMechanism UTF8String], [basedn UTF8String], [searchScope UTF8String], MY_LDAP_SCOPE, caFile);
    
    return message;
    
}

//login using username and password saved in plist
+(NSString*) loginWithoutLDAP
{
    NSString* message = @"";
    
    NSString* username = [[QuestionList sharedInstance] username];
    NSString* passsword = [[QuestionList sharedInstance] password];
    
    //check if user is technician
    if ([[[[KeyList sharedInstance] technicianUsers] objectForKey:username] isEqualToString:passsword]) {
        message = [message stringByAppendingString:@"cn:technician"];
    }
    
    //check if user is foreman
    if ([[[[KeyList sharedInstance] foremanUsers] objectForKey:username] isEqualToString:passsword]) {
        message = [message stringByAppendingString:@"cn:foreman"];
    }
    
    //check if user is engineer
    if ([[[[KeyList sharedInstance] engineerUsers] objectForKey:username] isEqualToString:passsword]) {
        message = [message stringByAppendingString:@"cn:engineer"];
    }
    
    //if credentials are not valid
    if ([message length] == 0) {
        message = [message stringByAppendingString:@"Invalid credentials"];
    }
    
    NSLog(@"%@", message);
    return message;
}

//get all users in ldap
+(NSArray*) getUserList
{
    
    //check if ldap to use or get userlist with users in plist
    if ([[KeyList sharedInstance] useLDAP]) {
        return [self getUserListWithLdap];
    }else{
        return [self getUserListWithOutLdap];
    }
    
}


//Get all users from ldap server
+(NSArray*) getUserListWithLdap
{
    //Get ldap login info from App's info.plist and data entered by user
    
    NSString* ip = [self getIPAddress];
    NSString* basedn = [[KeyList sharedInstance] basednLdapKey];
    //NSString* sslMechanism = [ldapInfo objectForKey:@"ssl"];
    NSString* uri;
    if ([ip rangeOfString:@"172.16.1."].location != NSNotFound) {
        uri = [[KeyList sharedInstance] uriSslLdapKey];
    }else{
        uri = [[KeyList sharedInstance] uriSslExternalLdapKey];
    }
    int version = [[KeyList sharedInstance] versionLdapKey].intValue;
    NSString* searchScope = [[KeyList sharedInstance] filterSearchQueryByGroupLdadKey];
    NSString* binddn = [[KeyList sharedInstance] binddnLdapKey];
    NSString* username = [[QuestionList sharedInstance] username];
    
    //set search group as foreman
    searchScope = [searchScope stringByReplacingOccurrencesOfString:@"*" withString:[[KeyList sharedInstance] foremanGroupNameLdapKey]];
    binddn = [binddn stringByReplacingOccurrencesOfString:@"*" withString:username];
    NSString *password = [[QuestionList sharedInstance] password];
    
    //Set up ca file
    NSString          * filePath;
    const char        * caFile;
    filePath = [[NSBundle mainBundle] pathForResource:@"ca-certs" ofType:@"pem"];
    caFile   = [filePath UTF8String];
    test_all_ldap(caFile);
    
    //get message for group technician
    NSString* message = test_simple_ldap(version, [uri UTF8String], [binddn UTF8String], [password UTF8String], [basedn UTF8String], [searchScope UTF8String], MY_LDAP_SCOPE, caFile);
    
    //set search group as technician
    searchScope = [[KeyList sharedInstance] filterSearchQueryByGroupLdadKey];
    searchScope = [searchScope stringByReplacingOccurrencesOfString:@"*" withString:[[KeyList sharedInstance] technicianGroupNameLdapKey]];
    
    //perform authentication
    message = [message stringByAppendingString:test_simple_ldap(version, [uri UTF8String], [binddn UTF8String], [password UTF8String], [basedn UTF8String], [searchScope UTF8String], MY_LDAP_SCOPE, caFile)];
    
    //set search group as engineer
    searchScope = [[KeyList sharedInstance] filterSearchQueryByGroupLdadKey];
    searchScope = [searchScope stringByReplacingOccurrencesOfString:@"*" withString:[[KeyList sharedInstance] engineerGroupNameLdapKey]];
    
    //perform authentication
    message = [message stringByAppendingString:test_simple_ldap(version, [uri UTF8String], [binddn UTF8String], [password UTF8String], [basedn UTF8String], [searchScope UTF8String], MY_LDAP_SCOPE, caFile)];
    
    
    //check if any error occured during any authentications
    if ([message isEqualToString:@"failed"]) {
        return NULL;
    }else if (([message length] > 0) && ((!([message rangeOfString:@"Invalid credentials"].location == NSNotFound)) || (!([message rangeOfString:@"Invalid DN syntax"].location == NSNotFound)))){
        return NULL;
    }else if([message isEqualToString:@"Can't contact LDAP server"]){
        return NULL;
    }
    
    
    //regex pattern
    NSString* pattern = @"memberUid:(\\w+)";
    
    
    NSRegularExpression* regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:NSRegularExpressionCaseInsensitive
                                  error:nil];
    
    
    //regex pattern and get all users and remove duplicates
    NSArray *matches = [regex matchesInString:message
                                      options:0
                                        range:NSMakeRange(0, [message length])];
    
    NSMutableArray *userList = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in matches) {
        NSString* substringForMatch = [message substringWithRange:match.range];
        NSString* user = [[substringForMatch componentsSeparatedByString:@":"] objectAtIndex:1];
        
        [userList addObject:user];
    }
    
    NSSet* noRepeatedUserNames = [[NSSet alloc] initWithArray:userList];
    userList = [NSMutableArray arrayWithArray:[noRepeatedUserNames allObjects]];
    
    return userList;

}

//get all users from info.plist
+(NSArray*) getUserListWithOutLdap
{
    NSMutableArray *userList = [[NSMutableArray alloc] init];
    
    //add all technicians
    for (NSString* user in [[KeyList sharedInstance] technicianUsers]) {
        [userList addObject:user];
    }
    
    //add all foremans
    for (NSString* user in [[KeyList sharedInstance] foremanUsers]) {
        [userList addObject:user];
    }
    
    //add all engineers
    for (NSString* user in [[KeyList sharedInstance] engineerUsers]) {
        [userList addObject:user];
    }
    
    //remove duplicates
    NSSet* noRepeatedUserNames = [[NSSet alloc] initWithArray:userList];
    userList = [NSMutableArray arrayWithArray:[noRepeatedUserNames allObjects]];
    
    return userList;

}

@end
