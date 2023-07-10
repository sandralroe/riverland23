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
<cfparam name="attributes.nestLevel" default="0">
<cfset rslist=application.categoryManager.getCategories(attributes.siteID,attributes.ParentID) />
<cfif attributes.nestlevel eq 0>
<cfset variables.nestLevel=""/>
<cfelse>
<cfset variables.nestLevel=attributes.nestlevel/>
</cfif>
</cfsilent>
<cfif rslist.recordcount>
<cfif attributes.nestlevel eq 0>
	<cfoutput>
	<table class="mura-table-grid">
	<thead>
	<tr>
	<th class="add"></th>
	<th class="var-width">#application.rbFactory.getKeyValue(session.rb,"categorymanager.category")#</th>
	<th>#application.rbFactory.getKeyValue(session.rb,"categorymanager.assignable")#</th>
	<th>#application.rbFactory.getKeyValue(session.rb,"categorymanager.interestgroup")#</th>
	<th>#application.rbFactory.getKeyValue(session.rb,"categorymanager.active")#</th>
	<th class="actions hide"></th>
	</tr>
	<thead>
	<tbody class="nest">
	</cfoutput>
</cfif>
<cfoutput>
<cfloop query="rslist">
<tr>
<td class="add">
 <a href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="categoryManager.showMenu('newContentMenu',this,'#rslist.categoryid#','#esapiEncode('javascript',attributes.siteid)#');"><i class="mi-ellipsis-v"></i></a></td>
<td class="var-width"><ul <cfif rslist.hasKids>class="nest#variables.nestlevel#on"<cfelse>class="nest#variables.nestlevel#off"</cfif>><li class="Category#iif(rslist.restrictGroups neq '',de('Locked'),de(''))#"><a title="Edit" href="./?muraAction=cCategory.edit&categoryID=#rslist.categoryID#&parentID=#rslist.parentID#&siteid=#esapiEncode('url',attributes.siteid)#">#esapiEncode('html',rslist.name)#</a></li></ul></td>
<td><cfif rslist.isOpen><i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,'categorymanager.#yesnoformat(rslist.isOpen)#')#"></i>
<cfelse><i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,'categorymanager.#yesnoformat(rslist.isOpen)#')#"></i></cfif>
<span>#application.rbFactory.getKeyValue(session.rb,'categorymanager.#yesnoformat(rslist.isOpen)#')#</span></td>

<td>
	<cfif rslist.isInterestGroup>
		<i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,'categorymanager.#yesnoformat(rslist.isInterestGroup)#')#"></i>
	<cfelse>
	<i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,'categorymanager.#yesnoformat(rslist.isInterestGroup)#')#"></i>
	</cfif>
	<span>#application.rbFactory.getKeyValue(session.rb,'categorymanager.#yesnoformat(rslist.isInterestGroup)#')#</span>
</td>

<td>
	<cfif rslist.isActive>
		<i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,'categorymanager.#yesnoformat(rslist.isActive)#')#"></i>
	<cfelse>
	<i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,'categorymanager.#yesnoformat(rslist.isActive)#')#"></i>
	</cfif>
	<span>#application.rbFactory.getKeyValue(session.rb,'categorymanager.#yesnoformat(rslist.isActive)#')#</span>
</td>
<td class="actions hide"><ul><li class="edit"><a title="#application.rbFactory.getKeyValue(session.rb,'categorymanager.edit')#" href="./?muraAction=cCategory.edit&categoryID=#rslist.categoryID#&parentID=#rslist.parentID#&siteid=#esapiEncode('url',attributes.siteid)#"><i class="mi-pencil"></i></a></li><li class="delete"><a title="#application.rbFactory.getKeyValue(session.rb,'categorymanager.delete')#" href="./?muraAction=cCategory.update&action=delete&categoryID=#rslist.categoryID#&siteid=#esapiEncode('url',attributes.siteid)##attributes.muraScope.renderCSRFTokens(context=rslist.categoryid,format="url")#" onClick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'categorymanager.deleteconfirm'))#',this.href)"><i class="mi-trash"></i></a></li></ul></td>
</tr>
<cf_dsp_nest siteID="#attributes.siteID#" parentID="#rslist.categoryID#" nestLevel="#evaluate(attributes.nestLevel +1)#"  muraScope="#attributes.muraScope#">
</cfloop>
</cfoutput>
<cfif attributes.nestlevel eq 0>
	</tbody>
	</table>
</cfif>
<cfelseif attributes.nestlevel eq 0>
	<cfoutput><div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,"categorymanager.nocategories")#</div></cfoutput>
</cfif>
