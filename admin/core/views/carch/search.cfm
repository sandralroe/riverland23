<!--- license goes here --->
<cfinclude template="js.cfm">
<cfset rc.perm=application.permUtility.getPerm(rc.moduleid,rc.siteid)>
<cfparam name="session.copyContentID" default="">
<cfparam name="session.copySiteID" default="">
<cfparam name="session.copyAll" default="false">
<cfoutput>
<h1>Site Search</h1>

<h2>Keyword Search</h2>
<form class="form-inline" novalidate="novalidate" id="siteSearch" name="siteSearch" method="get">
	<input name="keywords" value="#esapiEncode('html_attr',session.keywords)#" type="text" class="text" maxlength="50" /><input type="button" class="btn" onclick="submitForm(document.forms.siteSearch);" value="Search" />
	<input type="hidden" name="muraAction" value="cArch.search">
	<input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
	<input type="hidden" name="moduleid" value="#rc.moduleid#">
</form>
<script>
siteManager.copyContentID = '#session.copyContentID#';
siteManager.copySiteID = '#session.copySiteID#';
</script>
</cfoutput>
 <table class="mura-table-grid">
    <tr>
	  <th>&nbsp;</th>
      <th class="var-width">Title</th>
      <th>Display</th>
      <th>Update</th>
      <th class="actions">&nbsp;</th>
    </tr>
    <cfif rc.rslist.recordcount>
     <cfoutput query="rc.rslist" maxrows="#rc.nextn.recordsperPage#" startrow="#rc.startrow#">
	<cfsilent>
		<cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.siteid)/>
		<cfset verdict=application.permUtility.getnodePerm(crumbdata)/>

		<cfif application.settingsManager.getSite(rc.siteid).getLocking() neq 'all'>
			<cfset newcontent=verdict>
		<cfelseif verdict neq 'none'>
			<cfset newcontent='read'>
		<cfelse>
			<cfset newcontent='none'>
		</cfif>


		<cfset deletable=((rc.rslist.parentid neq '00000000000000000000000000000000001' and application.settingsManager.getSite(rc.siteid).getLocking() neq 'all') or (rc.rslist.parentid eq '00000000000000000000000000000000001' and application.settingsManager.getSite(rc.siteid).getLocking() eq 'none')) and (verdict eq 'editor')  and rc.rslist.IsLocked neq 1>

	<!--- 	<cfif rc.rslist.type eq 'File'>
			<cfset icon=lcase(rc.rslist.fileExt)>
		<cfelse>
			<cfset icon=rc.rslist.type>
		</cfif> --->

	</cfsilent>
        <tr>
			     <td class="add">
     <!---<cfif (rc.rslist.type eq 'Page') or  (rc.rslist.type eq 'Folder')  or  (rc.rslist.type eq 'Calendar') or (rc.rslist.type eq 'Gallery')>--->
		<a href="javascript:;" ontouchstart="this.onmouseover();" onmouseover="showMenu('newContentMenu','#newcontent#',this,'#rc.rslist.contentid#','#rc.rslist.contentid#','#rc.rslist.parentid#','#rc.siteid#','#rc.rslist.type#','#rc.rslist.moduleid#');">&nbsp;</a>
	<!---<cfelse>
		&nbsp;
	</cfif>---></td>
          <td class="title var-width">#$.dspZoom(crumbdata)#</td>
			   <td>
	    <cfif rc.rslist.Display and (rc.rslist.Display eq 1 and rc.rslist.approved and rc.rslist.approved)>Yes<cfelseif(rc.rslist.Display eq 2 and rc.rslist.approved and rc.rslist.approved)>#LSDateFormat(rc.rslist.displaystart,session.dateKeyFormat)# - #LSDateFormat(rc.rslist.displaystop,session.dateKeyFormat)#<cfelse>No</cfif></td>
		<td>#LSDateFormat(rc.rslist.lastupdate,session.dateKeyFormat)#</td>

 <td class="actions"><ul class="siteSummary five"><cfif not listFindNoCase('none,read',verdict)>
       <li class="edit"><a title="Edit" href="./?muraAction=cArch.edit&contenthistid=#rc.rsList.ContentHistID#&contentid=#rc.rsList.ContentID#&type=#rc.rsList.type#&parentid=#rc.rsList.parentID#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.moduleid#&startrow=#rc.startrow#"><i class="mi-pencil"></i></a></li>
		<li class="preview"><a title="Preview" href="#application.settingsManager.getSite(rc.siteid).getWebPath(complete=1)##$.getContentRenderer().editroute##$.getURLStem(rc.siteid,rc.rsList.filename)#"><i class="mi-globe"></i></a></li>
	   <li class="version-history"><a title="Version History" href="./?muraAction=cArch.hist&contentid=#rc.rsList.ContentID#&type=#rc.rsList.type#&parentid=#rc.rsList.parentID#&topid=#rc.rsList.contentID#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.moduleid#&startrow=#rc.startrow#"><i class="mi-history"></i></a></li>
        <cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
          <li class="permissions"><a title="Permissions" href="./?muraAction=cPerm.main&contentid=#rc.rsList.ContentID#&type=#rc.rsList.type#&parentid=#rc.rsList.parentID#&topid=#rc.rsList.contentID#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.moduleid#&startrow=#rc.startrow#"><i class="mi-group"></i></a></li>
        <cfelse>
		  <li class="permissions disabled"><a>Permissions</a></li>
		</cfif>
        <cfif deletable>
          <li class="delete"><a title="Delete" href="./?muraAction=cArch.update&contentid=#rc.rsList.ContentID#&type=#rc.rsList.type#&action=deleteall&topid=#rc.rsList.contentID#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.moduleid#&parentid=#esapiEncode('url',rc.parentid)#&startrow=#rc.startrow#"
			<cfif listFindNoCase("Page,Folder,Calendar,Gallery,Link,File",rc.rsList.type)><i class="mi-trash"></i></a></li>
          <cfelseif rc.locking neq 'all'>
          <li class="delete disabled">Delete<i class="mi-trash"></i></li>
        </cfif>
        <cfelse>
        <li class="edit disabled">&nbsp;</li>
		<cfswitch expression="#rc.rsList.type#">
		<cfcase value="Page,Folder,Calendar,Gallery">
		<li class="preview"><a title="Preview" href="#application.settingsManager.getSite(rc.siteid).getScheme()#://#application.settingsManager.getSite(rc.siteid).getDomain()##application.configBean.getServerPort()##application.configBean.getContext()##$.getContentRenderer().editroute##$.getURLStem(rc.siteid,rc.rsList.filename)#"><i class="mi-globe"></i></a></li>
		</cfcase>
		<cfcase value="Link">
		<li class="preview"><a title="Preview" href="##" onclick="return preview('#rc.rsList.filename#','#rc.rsList.targetParams#');"><i class="mi-globe"></i></a></li>
		</cfcase>
		<cfcase value="File">
		<li class="preview"><a title="Preview" href="##" onclick="return preview('#application.settingsManager.getSite(rc.siteid).getScheme()#://#application.settingsManager.getSite(rc.siteid).getDomain()##application.configBean.getServerPort()##application.configBean.getContext()##$.getContentRenderer().editroute##$.getURLStem(rc.siteid,rc.rsList.filename)#','#rc.rsList.targetParams#');"><i class="mi-globe"></i></a></li>
		</cfcase>
		</cfswitch>
		<li class="version-history disabled"><a>Version History</a></li>
		<li class="permissions disabled"><a>Permissions</a></li>
		<li class="delete disabled"><a>Delete</a></li>
      </cfif></ul></td>

       </cfoutput>
      <cfelse>
      <tr>
        <td colspan="8" class="results">Your search returned no results.</td>
      </tr>
    </cfif>
	</td></tr></table>
    <cfif rc.nextn.numberofpages gt 1>
    <cfoutput>
   <cfset args=arrayNew(1)>
		<cfset args[1]="#rc.nextn.startrow#-#rc.nextn.through#">
		<cfset args[2]=rc.nextn.totalrecords>
		<div class="mura-results-wrapper">
			<p class="clearfix search-showing">
				#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"sitemanager.paginationmeta"),args)#
			</p>
			<ul class="pagination">
			<cfif rc.nextN.currentpagenumber gt 1>
				<li>
					<a href="./?muraAction=cArch.search&siteid=#esapiEncode('url',rc.siteid)#&keywords=#session.keywords#&startrow=#rc.nextn.previous#&moduleid=#rc.moduleid#"><i class="mi-angle-left"></i></a>
				</li>
			</cfif>
			<cfloop from="#rc.nextN.firstPage#"  to="#rc.nextn.lastPage#" index="i">
				<cfif rc.nextn.currentpagenumber eq i>
					<li class="active"><a href="##">#i#</a></li>
				<cfelse>
					<li><a href="./?muraAction=cArch.search&siteid=#esapiEncode('url',rc.siteid)#&keywords=#session.keywords#&startrow=#evaluate('(#i#*#rc.nextn.recordsperpage#)-#rc.nextn.recordsperpage#+1')#&moduleid=#rc.moduleid#">#i#</a></li>
				</cfif>
			</cfloop>
			<cfif rc.nextN.currentpagenumber lt rc.nextN.NumberOfPages>
				<li>
					<a href="./?muraAction=cArch.search&siteid=#esapiEncode('url',rc.siteid)#&keywords=#session.keywords#&startrow=#rc.nextn.next#&moduleid=#rc.moduleid#"><i class="mi-angle-right"></i></a>
				</li>
			</cfif>
			</cfoutput>
			</ul>
		</div>
	</cfif>
</table>
