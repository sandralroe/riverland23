<cfscript>
    data          = StructNew();
    data.isPublic = rc.isPublic;
    data.search   = rc.search;
    data.sitedid  = rc.siteid;
    data.isGroupSearch = rc.isGroupSearch;
    data.rs       = rc.rs;
    QueryDeleteColumn(data.rs,"PASSWORDCREATED");
    QueryDeleteColumn(data.rs,"LASTUPDATE");
    QueryDeleteColumn(data.rs,"CREATED");
    data.it          = rc.it; 
    data.recordCount = rc.it.getRecordCount();
    
</cfscript>

<!---
<cfdump  var="#data.rs#">
<cfabort>
--->

<cfset var = createObject("component","mura.json").encode(data.recordCount) >

<cfoutput>
#var#
</cfoutput>
<cfabort>
