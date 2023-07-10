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
<cfparam name="attributes.nestLevel" default="1">
<cfset rslist=application.categoryManager.getPublicInterestGroups(attributes.siteID,attributes.ParentID) />
</cfsilent>
<cfif rslist.recordcount>
<ul>
<cfoutput query="rslist">
<li><cfif rslist.isOpen eq 1><input type="checkbox" name="categoryID" class="checkbox" <cfif listfind(session.paramCategories,rslist.CategoryID)>checked</cfif> value="#rslist.categoryID#"> </cfif>#rslist.name#
<cf_dsp_categories_nest_search siteID="#attributes.siteID#" parentID="#rslist.categoryID#" categoryID="#attributes.categoryID#" nestLevel="#evaluate(attributes.nestLevel +1)#" ></li>
</cfoutput>
</ul>
</cfif>
