<!--- license goes here --->

<cfsilent>
<cfscript>
	if(server.coldfusion.productname != 'ColdFusion Server'){
		backportdir='';
		include "/mura/backport/backport.cfm";
	} else {
		backportdir='/mura/backport/';
		include "#backportdir#backport.cfm";
	}
</cfscript>
<cfparam name="attributes.siteID" default="">
<cfparam name="attributes.parentID" default="">
<cfparam name="attributes.categoryID" default="">
<cfparam name="attributes.actualParentID" default="">
<cfparam name="attributes.nestLevel" default="0">
<cfset rslist=application.categoryManager.getCategories(attributes.siteID,attributes.ParentID) />
</cfsilent>
<cfif rslist.recordcount>
<cfoutput query="rslist">
 <cfif rslist.categoryID neq attributes.categoryID>
<option value="#rslist.categoryID#" <cfif rslist.categoryID eq attributes.actualParentID>selected</cfif>><cfif attributes.nestlevel><cfloop  from="1" to="#attributes.NestLevel#" index="I">&nbsp;&nbsp;</cfloop></cfif>#esapiEncode('html',rslist.name)#</option>
<cf_dsp_parents siteID="#attributes.siteID#" categoryID="#attributes.categoryID#" parentID="#rslist.categoryID#" actualParentID="#attributes.actualParentID#" nestLevel="#evaluate(attributes.nestLevel +1)#" >
 </cfif>
</cfoutput>
</cfif>
