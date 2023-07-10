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
<cfparam name="attributes.useID" default="1">
<cfparam name="attributes.elementName" default="categoryID">
<cfset rslist=application.categoryManager.getCategories(attributes.siteID,attributes.ParentID,"") />
</cfsilent>
<cfif rslist.recordcount>
<ul<cfif not attributes.nestLevel and attributes.useID> id="mura-nodes"</cfif> class="categories<cfif not attributes.nestLevel> checkboxTree</cfif>">
<cfoutput query="rslist">
<li><cfif rslist.isOpen eq 1><input type="checkbox" name="#attributes.elementName#" class="checkbox" <cfif listfind(attributes.categoryID,rslist.CategoryID)>checked</cfif> value="#rslist.categoryID#"/> </cfif>#esapiEncode('html',rslist.name)#
<cfif rslist.hasKids>
<cf_dsp_categories_nest siteID="#attributes.siteID#" parentID="#rslist.categoryID#" categoryID="#attributes.categoryID#" nestLevel="#evaluate(attributes.nestLevel +1)#" useID="#attributes.useID#" elementName="#attributes.elementName#">
</cfif>
</li>
</cfoutput>
</ul>
</cfif>
