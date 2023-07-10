<cfscript>
    data             = StructNew();
    data.isPublic    = rc.isPublic;
    data.search      = rc.search;
    data.sitedid     = rc.siteid;
    data.it          = rc.it; 
    data.recordCount = rc.it.getRecordCount();
</cfscript>

<cfset var = createObject("component","mura.json").encode(data.recordCount) >

<cfoutput>
#var#
</cfoutput>
<cfabort>