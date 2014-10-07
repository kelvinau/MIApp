/*
 *  ldap.h
 *  ldapsearch
 *
 *  Created by David Syzdek on 11/2/10.
 *  Copyright 2010 David M. Syzdek. All rights reserved.
 *
 */
#include <ldap.h>

//#define MY_LDAP_VERSION    LDAP_VERSION3
//#define MY_LDAP_URI        "ldaps://server.gursimran.net:6636"
//#define MY_LDAP_BINDDN     ""
//#define MY_LDAP_BINDPW     ""
//#define MY_LDAP_BASEDN     "dc=server,dc=gursimran,dc=net"
//#define MY_LDAP_SCOPE      LDAP_SCOPE_SUB
//#define MY_LDAP_FILTER     "(uid=*)"

#define MY_LDAP_VERSION    LDAP_VERSION3
#define MY_LDAP_URI        "ldap://server.gursimran.net"
#define MY_LDAP_BINDDN     "uid=anita,cn=users,dc=server,dc=gursimran,dc=net"
#define MY_LDAP_BINDPW     "anita"
#define MY_LDAP_BASEDN     "cn=groups,dc=server,dc=gursimran,dc=net"
#define MY_LDAP_FILTER     "(memberUid=anita)"
#define MY_LDAP_SCOPE      LDAP_SCOPE_SUB

#define MY_SASL_AUTHUSER   "anita"
#define MY_SASL_REALM      NULL
#define MY_SASL_PASSWD     MY_LDAP_BINDPW
#define MY_SASL_MECH       "DIGEST-MD5"

typedef struct my_ldap_auth MyLDAPAuth;
struct my_ldap_auth
{
   char * mech;
   char * authuser;
   char * user;
   char * realm;
   char * passwd;
};

void test_all_ldap(const char * caFile);

NSString* test_simple_ldap(int version, const char * ldapURI, const char * bindDN,
   const char * bindPW, const char * baseDN, const char * filter, int scope,
   const char * caFile);

NSString* test_sasl_ldap(int version, const char * ldapURI, const char * user,
   const char * realm, const char * pass, const char * mech,
   const char * baseDN, const char * filter, int scope, const char * caFile);

int ldap_sasl_interact(LDAP *ld, unsigned flags, void *defaults,
   void *sasl_interact);

void test_sasl_ldaps(int version, const char * ldapURI, const char * user,
                    const char * realm, const char * pass, const char * mech,
                    const char * baseDN, const char * filter, int scope, const char * caFile);

