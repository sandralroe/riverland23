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
<cfparam name="rc.siteID" default="">
<cfparam name="rc.parentID" default="">
<cfparam name="rc.categoryID" default="">
<cfparam name="rc.nestLevel" default="1">
<cfset rslist=application.categoryManager.getCategories(rc.siteID,rc.ParentID) />
</cfsilent>
<cfif rslist.recordcount>
<ul<cfif not rc.nestLevel> class="checkboxTree"</cfif>>
<cfoutput query="rslist">
<li>
<cfif rslist.isOpen eq 1><input type="checkbox" name="categoryID" class="checkbox" <cfif listfind(rc.extendSetBean.getCategoryID(),rslist.categoryID) or listfind(rc.categoryID,rslist.CategoryID)>checked</cfif> value="#rslist.categoryID#"> </cfif>#esapiEncode('html',rslist.name)#
<cf_dsp_categories_nest siteID="#rc.siteID#" parentID="#rslist.categoryID#" categoryID="#rc.categoryID#" nestLevel="#evaluate(rc.nestLevel +1)#" extendSetBean="#rc.extendSetBean#">
</li>
</cfoutput>
</ul>
</cfif>
