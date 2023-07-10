 <!--- license goes here --->
<cfsilent>
<cfset request.layout=false>
<cfset emailBean=application.emailManager.read(rc.emailID) />
<cfset rsAddresses=application.emailManager.getAddresses(emailBean.getGroupID(),emailBean.getSiteID())/>
<cfset TabChar=chr(9) />
<cfset NewLine=chr(13)&chr(10) />
<cfset prevEmail = "" />
</cfsilent>
<cfheader name="Content-Disposition" value="attachment;filename=#emailBean.getSubject()#.xls"> 
<cfheader name="Expires" value="0">
<cfcontent type="application/msexcel" reset="yes"><cfoutput><cfloop list="email,firstName,lastName,company" index="c">#c##TabChar#</cfloop>#NewLine#</cfoutput><cfoutput query="rsAddresses"><cfif prevEmail neq rsAddresses.email>#rsAddresses.email##TabChar##rsAddresses.fname##TabChar##rsAddresses.lname##TabChar##rsAddresses.company##TabChar##NewLine#<cfset prevEmail=rsAddresses.email /></cfif></cfoutput>
