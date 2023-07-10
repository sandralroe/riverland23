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
<cfparam name="attributes.groupID" default="">
<cfparam name="attributes.nestLevel" default="1">
<cfset rslist=application.categoryManager.getCategories(attributes.siteID,attributes.ParentID,"",true,true) />
</cfsilent>
<cfif rslist.recordcount><cfset attributes.hasCats=true>
<ul<cfif not attributes.nestLevel> class="checkboxTree"</cfif>>
<cfoutput query="rslist">
<li>
<input type="checkbox" name="groupID" class="checkbox" <cfif listfind(attributes.groupID,rslist.categoryID)>checked</cfif> value="#rslist.categoryID#"> #esapiEncode('html',rslist.name)#
<cf_dsp_categories_nest siteID="#attributes.siteID#" groupid="#attributes.groupID#" parentID="#rslist.categoryID#" nestLevel="#evaluate(attributes.nestLevel +1)#" >
</li>
</cfoutput>
</ul>
</cfif>
