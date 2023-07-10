<!--- license goes here --->

<cfsilent><cfparam name="attributes.siteID" default="">
<cfparam name="attributes.parentID" default="">
<cfparam name="attributes.categoryID" default="">
<cfparam name="attributes.nestLevel" default="1">
<cfset variables.rslist=application.categoryManager.getCategories(attributes.siteID,attributes.ParentID,"",true,true) />
</cfsilent>
<cfif variables.rslist.recordcount>
<ul>
<cfoutput query="rslist">
<li><cfif variables.rslist.isOpen eq 1>
<input type="checkbox" name="categoryID" class="#this.categoriesNestCheckboxClass#" <cfif listfind(request.userBean.getCategoryID(),variables.rslist.categoryID) or listfind(attributes.categoryID,variables.rslist.CategoryID)>checked</cfif> value="#variables.rslist.categoryID#"> </cfif>#variables.rslist.name#
<cf_dsp_categories_nest siteID="#attributes.siteID#" parentID="#variables.rslist.categoryID#" categoryID="#attributes.categoryID#" nestLevel="#evaluate(attributes.nestLevel +1)#" >
</li>
</cfoutput>
</ul>
</cfif>
