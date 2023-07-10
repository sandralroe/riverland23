<cfscript>
/* license goes here */
param name="session.mura.isLoggedIn" default=false;
param name="session.mura.userID" default="";
param name="session.mura.siteID" default="";
param name="session.mura.subtype" default="Default";
param name="session.mura.username" default="";
param name="session.mura.password" default="";
param name="session.mura.email" default="";
param name="session.mura.fname" default="";
param name="session.mura.lname" default="";
param name="session.mura.company" default="";
param name="session.mura.lastlogin" default="";
param name="session.mura.passwordCreated" default="";
param name="session.mura.remoteID" default="";
param name="session.mura.memberships" default="";
param name="session.mura.membershipids" default="";
param name="session.mura.showTrace" default=false;
param name="session.mura.csrfsecretkey" default=createUUID();
param name="session.mura.csrfusedtokens" default=structNew();
param name="session.rememberMe" default=0;
param name="session.loginAttempts" default=0;
param name="session.blockLoginUntil" default="";
request.doMuraGlobalSessionStart=true;
</cfscript>
