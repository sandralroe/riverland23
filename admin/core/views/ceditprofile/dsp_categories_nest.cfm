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
<cfset rslist=application.categoryManager.getPrivateInterestGroups(attributes.siteID,attributes.ParentID) />
</cfsilent>
<cfif rslist.recordcount>
<ul<cfif not attributes.nestLevel> class="checkboxTree"</cfif>>
<cfoutput query="rslist">
<li>
<cfif rslist.isOpen eq 1><input type="checkbox" name="categoryID" class="checkbox" <cfif listfind(attributes.userBean.getCategoryID(),rslist.categoryID) or listfind(attributes.categoryID,rslist.CategoryID)>checked</cfif> value="#rslist.categoryID#"> </cfif>#esapiEncode('html',rslist.name)#
<cfif rslist.hasKids><cf_dsp_categories_nest siteID="#attributes.siteID#" parentID="#rslist.categoryID#" categoryID="#attributes.categoryID#" nestLevel="#evaluate(attributes.nestLevel +1)#" userBean="#attributes.userBean#" rc="#attributes.rc#"></cfif>
</li>
</cfoutput>
</ul>
<cfelseif attributes.parentID eq ''>
<cfoutput><div class="help-block-empty">#attributes.rc.$.rbKey('user.nointerestcategories')#</div></cfoutput>
</cfif>
