<!--- License goes here --->
<cfsilent>
<cfset event=request.event>
<cfset request.layout=false>
<cfset data=structNew()>

<cfif not isDefined("rc.sortby") or rc.sortby eq "">
 <cfset rc.sortBy=rc.rstop.sortBy>
</cfif>

<cfif not len(rc.sortBy)>
    <cfset rc.sortBy="orderno">
</cfif>

<cfif not isDefined("rc.sortdirection") or rc.sortdirection eq "">
 <cfset rc.sortdirection=rc.rstop.sortdirection>
</cfif>

<cfparam name="rc.sortDirection" default="#rc.rstop.sortDirection#" />
<cfparam name="rc.sorted" default="false" />
<cfparam name="rc.toggle" default="true" />
<cfparam name="session.copyContentID" default="">
<cfparam name="session.copySiteID" default="">
<cfparam name="session.copyAll" default="false">
<cfparam name="session.openSectionList" default="">

<cfset request.tabAssignments=$.getBean("user").loadBy(userID=session.mura.userID, siteID=session.mura.siteID).getContentTabAssignments()>
<cfset request.hasPublishingTab=not len(request.tabAssignments) or listFindNocase(request.tabAssignments,'Publishing')>
<cfset request.hasLayoutObjectsTab=not len(request.tabAssignments) or listFindNocase(request.tabAssignments,'Layout & Objects') or listFindNocase(request.tabAssignments,'Layout')>
<cfset request.rowNum=0>
<cfset request.menulist=rc.topid>
<cfset crumbdata=application.contentManager.getCrumbList(contentid=rc.topid,siteid=rc.siteid,usecache=false)>
<cfset perm=application.permUtility.getnodePerm(crumbdata)>
<cfset r=application.permUtility.setRestriction(crumbdata).restrict>
<cfset hasKids=application.contentManager.getKidsCount(rc.rstop.contentid,rc.rstop.siteid,false)>

<cfinclude template="dsp_nextN.cfm">

<cfif  ((rc.topid eq '00000000000000000000000000000000001' and application.settingsManager.getSite(rc.siteid).getlocking() eq 'none') or (rc.topid neq '00000000000000000000000000000000001')) and application.settingsManager.getSite(rc.siteid).getlocking() neq 'all'>
 <cfset newcontent=perm>
<cfelseif perm neq 'none'>
 <cfset newcontent='read'>
<cfelse>
 <cfset newcontent='none'>
</cfif>

<cfif rc.rsTop.type eq 'File'>
 <cfset icon=application.classExtensionManager.getCustomIconClass(siteid=rc.rstop.siteid,type=rc.rstop.type,subtype=rc.rstop.subtype)>

 <cfif not len(icon)>
   <cfset icon=lcase(rc.rsTop.fileExt)>
 </cfif>

 <cfif r>
   <cfset icon=icon & " locked">
 </cfif>
<cfelse>
 <cfset icon=application.classExtensionManager.getCustomIconClass(siteid=rc.rstop.siteid,type=rc.rstop.type,subtype=rc.rstop.subtype)>
 <cfif not len(icon)>
   <cfset icon='icon-mura-' & lcase(rc.rstop.type)>
 </cfif>
 <cfif r>
   <cfset icon="#icon# locked">
 </cfif>
 <cfset icon=icon & " " & rc.rsTop.subtype>
</cfif>
<cfset isFileIcon= rc.rsTop.type eq 'File' and listFirst(icon,"-") neq "icon" and not listFindNoCase("jpg,jpeg,png,gif,webp",listLast(rc.rsTop.assocfilename,"."))>
<cfparam name="session.flatViewArgs" default="#structNew()#">

<cfif not structKeyExists(session.flatViewArgs,'#rc.siteid#')>
   <cfset session.flatViewArgs['#rc.siteid#']={}>
</cfif>

<cfset session.flatViewArgs["#rc.siteID#"].tab=0>

<cfset variables.pluginEvent=createObject("component","mura.event").init(event.getAllValues())/>
<cfset rsExtend=application.configBean.getClassExtensionManager().getExtendedAttributeList(rc.siteid)>
</cfsilent>

<cfsavecontent variable="data.html">
<cfoutput>
 <form novalidate="novalidate" class="viewUpdate clearfix" name="viewUpdate" method="post" action="./index.cfm?muraAction=cArch.list&siteid=#esapiEncode('url',rc.siteID)#&moduleid=#esapiEncode('url',rc.moduleID)#&topid=#esapiEncode('url',rc.topID)#">

 	<!--- sm-modify-view --->
	<div class="btn-group" id="sm-modify-view">
   <a class="btn dropdown-toggle" data-toggle="dropdown" href="">
	 #application.rbFactory.getKeyValue(session.rb,"sitemanager.modifyview")#
	 <span class="caret"></span>
   </a>
   <div class="dropdown-menu">
	   <!---  <h3>#application.rbFactory.getKeyValue(session.rb,'sitemanager.filterviewdesc')#</h3> --->
	   <div class="mura-control-group">
	   <label>#application.rbFactory.getKeyValue(session.rb,"sitemanager.rowsdisplayed")#:
	   <cfif rc.topid neq '00000000000000000000000000000000001'
			 and (perm eq 'Editor' or
			 		 (perm eq 'Author' and application.configBean.getSortPermission() eq "author")
			 			)>
 				<input name="nextN" value="#session.mura.nextN#" type="text" class="text numeric" size="6" maxlength="4" />
 			</label>
				</div>
				<div class="mura-control-group">

				<label>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sortnavigation")#:<br>
					<select name="sortBy" onchange="siteManager.setAsSorted();">
						<cfif rc.moduleid eq '00000000000000000000000000000000000'>
						 	<option value="orderno" <cfif rc.sortBy eq 'orderno'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.manual")#</option>
							<option value="releaseDate" <cfif rc.sortBy eq 'releaseDate'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.releasedate")#</option>
							<option value="lastUpdate" <cfif rc.sortBy eq 'lastUpdate'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.updatedate")#</option>
							<option value="created" <cfif rc.sortBy eq 'created'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.created")#</option>
							<option value="menuTitle" <cfif rc.sortBy eq 'menuTitle'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.menutitle")#</option>
							<option value="title" <cfif rc.sortBy eq 'title'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.longtitle")#</option>
							<option value="rating" <cfif rc.sortBy eq 'rating'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.rating")#</option>
	                        <cfif rc.$.getServiceFactory().containsBean('marketingManager')>
	                            <option value="mxpRelevance" <cfif rc.sortBy eq 'mxpRelevance'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'params.mxpRelevance')#</option>
	                        </cfif>
	                        <cfif isBoolean(application.settingsManager.getSite(session.siteid).getHasComments()) and application.settingsManager.getSite(session.siteid).getHasComments()>
	                            <option value="comments" <cfif rc.sortBy eq 'comments'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.comments")#</option>
	                        </cfif>
	                        <cfloop query="rsExtend">
								<cfif listFindNoCase('Base,Page,Folder,Link,File,Gallery,Calendar',rsExtend.Type)>
								<option value="#esapiEncode('html_attr',rsExtend.attribute)#" <cfif rc.sortBy eq rsExtend.attribute>selected</cfif>>#esapiEncode('html',rsExtend.Type)#/#esapiEncode('html',rsExtend.subType)# - #esapiEncode('html',rsExtend.attribute)#</option>
								</cfif>
							</cfloop>
						<cfelse>
							<option value="orderno" <cfif rc.sortBy eq 'orderno'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.manual")#</option>
							<option value="lastUpdate" <cfif rc.sortBy eq 'lastUpdate'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.updatedate")#</option>
							<option value="created" <cfif rc.sortBy eq 'created'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.created")#</option>
							<option value="title" <cfif rc.sortBy eq 'title'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.longtitle")#</option>
							<cfsilent>
							  <cfif rc.moduleid eq '00000000000000000000000000000000003'>
							      <cfset typefilter='Component'>
							  <cfelseif rc.moduleid eq '00000000000000000000000000000000004'>
							      <cfset typefilter='Form'>
							  <cfelseif rc.moduleid eq '00000000000000000000000000000000099'>
							      <cfset typefilter='Variation'>
							  <cfelse>
							      <cfset typefilter='undefined'>
							  </cfif>
							</cfsilent>
							<cfloop query="rsExtend">
							  <cfif rsExtend.Type eq typefilter>
							      <option value="#esapiEncode('html_attr',rsExtend.attribute)#" <cfif rc.sortBy eq rsExtend.attribute>selected</cfif>>#esapiEncode('html',rsExtend.Type)#/#esapiEncode('html',rsExtend.subType)# - #esapiEncode('html',rsExtend.attribute)#</option>
							  </cfif>
							</cfloop>
						</cfif>
				 </select><br>
				 <select name="sortDirection"  onchange="siteManager.setAsSorted();">
				   <option value="asc" <cfif rc.sortDirection eq 'asc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.ascending")#</option>
				   <option value="desc" <cfif rc.sortDirection eq 'desc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.sort.descending")#</option>
				 </select>
			 </label>
			 <input type="hidden" name="saveSort" value="true">
		 <cfelse>
		   <input name="nextN" value="#esapiEncode('html_attr',session.mura.nextN)#" type="text" class="text numeric" size="6" maxlength="4" />
		 </label>
		 </cfif>
		 </div>
		 <!---<dd <cfif rc.topid neq '00000000000000000000000000000000001' and perm eq 'Editor'>class="button"</cfif>>--->
		<div class="center">
		 <input type="button" class="btn" onclick="submitForm(document.forms.viewUpdate);" value="#application.rbFactory.getKeyValue(session.rb,"sitemanager.update")#" />
		</div>
	   <input type="hidden" name="startrow" value="#esapiEncode('html_attr',rc.startrow)#">
	   <input type="hidden" name="orderperm" value="#perm#">
	   <input type="hidden" id="sorted" name="sorted" value="false">
   </div>
 </div>
<!--- /sm-modify-view --->
<cfif rc.type neq 'Component' and rc.type neq 'Creative'  and rc.type neq 'Form'>
   #$.dspZoom(crumbdata=crumbdata,ajax=true,class="breadcrumb")#
</cfif>
 <script>
   $(document).ready(function(){
		 $('##sm-modify-view .dropdown-menu').click(function(e) {
		   e.stopPropagation();
		 })
   })
 </script>

 <cfif rc.sortBy eq 'orderno'>
   <div class="alert help-block" id="sitemgr-reorder" style="display:none">
   <!--- <i class="mi-warning"></i>  --->
   	<a href="##" class="submit btn btn-secondary" id="submitSort" onclick="document.getElementById('sitemgr-reorder').style.display = 'none'; location.reload(); return false;"><i class="mi-ban"></i> Cancel</a>
    <a href="##" class="submit btn btn-primary" id="submitSort" onclick="submitForm(document.forms.viewUpdate); return false;"><i class="mi-check"></i> Save Order</a>
   </div>
 </cfif>

   <!-- Begin Grid Header -->
   <div class="clear-both"></div>
   <div class="overflow-wrap">
   <div class="mura-grid stripe<cfif rc.sortBy neq 'orderno'> no-manual-sort</cfif>">
	 <dl class="mura-grid-hdr">
	   <dt>
		   <span class="add"></span>
			#application.rbFactory.getKeyValue(session.rb,"sitemanager.title")#
	   </dt>
	   <cfif rc.rstop.moduleid eq '00000000000000000000000000000000000' and application.settingsManager.getSite(rc.siteid).getlocking() neq 'all'>
		 <dd class="objects">#application.rbFactory.getKeyValue(session.rb,"sitemanager.objects")#</dd>
		 <dd class="display">#application.rbFactory.getKeyValue(session.rb,"sitemanager.display")#</dd>
		 <dd class="template">#application.rbFactory.getKeyValue(session.rb,"sitemanager.template")#</dd>
	   </cfif>
	   <cfif rc.rstop.moduleid eq '00000000000000000000000000000000000'>
		 <dd class="nav">#application.rbFactory.getKeyValue(session.rb,"sitemanager.nav")#</dd>
	   <cfelse>
		  <dd class="display">#application.rbFactory.getKeyValue(session.rb,"sitemanager.display")#</dd>
	   </cfif>
	   <dd class="updated">#application.rbFactory.getKeyValue(session.rb,"sitemanager.updated")#</dd>
	   <dd class="actions">&nbsp;</dd>
	 </dl>
	 <ul id="mura-nodes"<cfif arrayLen(crumbdata) gt 1 and crumbdata[2].type eq 'Gallery'> class="gallery"</cfif>>
	 <!-- Begin List of Nodes -->
	 <li data-siteid="#esapiEncode('html_attr',rc.siteid)#" data-contentid="#rc.rstop.contentid#" data-contenthistid="#rc.rstop.contenthistid#" data-moduleid="#esapiEncode('html_attr',rc.moduleid)#" data-sortby="<cfif len(rc.rstop.sortby)>#esapiEncode('html_attr',rc.rstop.sortby)#<cfelse>orderno</cfif>" data-sortdirection="#esapiEncode('html_attr',rc.rstop.sortdirection)#" class="#esapiEncode('html_attr',lcase(rc.rstop.type))# mura-node-data<cfif r> restricted</cfif>" data-csrf="#rc.$.renderCSRFTOkens(context=rc.rstop.contentid & 'quickedit',format='url')#">
	  <cfif r><div class="marker"></div></cfif>
	   <dl id="top-node">
	   <dt class="mura-grid-item">

		<a class="add" href="javascript:;" onclick="siteManager.showMenu('newContentMenu','#newcontent#',this,'#rc.rstop.contentid#','#rc.topid#','#rc.rstop.parentid#','#rc.siteid#','#rc.rstop.type#','#rc.rstop.moduleid#');"><i class="mi-ellipsis-v"></i></a>

		 <cfif hasKids>
		 <span class="hasChildren open" onclick="siteManager.loadSiteManager('#esapiEncode('javascript',rc.siteID)#','#esapiEncode('javascript',rc.topid)#','#esapiEncode('javascript',rc.moduleid)#','#esapiEncode('javascript',rc.sortby)#','#esapiEncode('javascript',rc.sortdirection)#','#esapiEncode('javascript',rc.rstop.type)#',1);"></span>
	 </cfif>

	   <cfsilent>
	   <cfif  perm neq 'none' and listFindNoCase("jpg,jpeg,png,gif,webp",listLast(rc.rsTop.assocfilename,"."))>
		 <cfset atooltip=true>
		 <cfset atitle="<img onload='$(this).handlers().tooltip();' onerror='this.onerror=null;$(this).handlers().tooltip();' class='image-preview' src='#$.getURLForImage(fileid=rc.rsTop.fileid,size='small',siteid=rc.rsTop.siteid,fileext=rc.rsTop.fileExt,useProtocol=false)#'>">
	   <cfelse>
		 <cfset atooltip=false>
		 <cfset atitle=application.rbFactory.getKeyValue(session.rb,"sitemanager.edit")>
	   </cfif>
	 </cfsilent>

		 <cfif not listFindNoCase('none,read',perm) and rc.rstop.type neq 'module'>
		   <a class="<cfif isFileIcon>file </cfif>draftprompt title" title="#atitle#" href="./?muraAction=cArch.edit&contenthistid=#rc.rstop.ContentHistID#&siteid=#esapiEncode('url',rc.siteid)#&contentid=#rc.topid#&topid=#esapiEncode('url',rc.topid)#&type=#rc.rstop.type#&parentid=#rc.rstop.parentid#&moduleid=#rc.rstop.moduleid#"<cfif rc.rsTop.type eq 'File'> data-filetype="#lcase(left(rc.rsTop.fileExt,4))#"</cfif> <cfif atooltip>rel="tooltip" data-html="true"</cfif>>
		 <cfelse>
		   <a <cfif rc.rsTop.type eq 'File'> data-filetype="#lcase(left(rc.rsTop.fileExt,4))#"</cfif> <cfif atooltip>rel="tooltip" data-html="true" title="#atitle#"</cfif>>
		 </cfif>
		<cfif not isFileIcon><i class="#lcase(icon)#"></i> </cfif><cfif len(rc.rsTop.menutitle)>#esapiEncode('html',rc.rsTop.menutitle)#<cfelse>#esapiEncode('html',rc.rsTop.title)#</cfif>
		   </a>
	   </dt>
	  <cfif rc.rstop.moduleid eq '00000000000000000000000000000000000' and application.settingsManager.getSite(rc.siteid).getlocking() neq 'all'>
	   <dd class="objects">
		   <cfif perm eq 'editor' and request.hasLayoutObjectsTab>
			 <a class="mura-quickEditItem<cfif rc.rstop.Display eq 2 and rc.rstop.approved> scheduled</cfif>" data-attribute="inheritObjects">
		   </cfif>
		   <cfif rc.rstop.inheritObjects eq 'cascade'>
		 <i class="mi-arrow-down" title="#rc.rstop.inheritObjects#"></i>
		 <cfelseif rc.rstop.inheritObjects eq 'reject'>
		   <i class="mi-ban" title="#rc.rstop.inheritObjects#"></i>
		 <cfelse>
		   <span class="bullet" title="#rc.rstop.inheritObjects#">&bull;</span>
	   </cfif>
		<span>#rc.rstop.inheritObjects#</span>
		   <cfif perm eq 'editor' and request.hasLayoutObjectsTab></a></cfif>
	   </dd>

 		<dd class="display<cfif rc.rstop.Display eq 2 and rc.rstop.approved> scheduled</cfif>">
			<cfif request.hasPublishingTab and rc.topid neq '00000000000000000000000000000000001'>
				<a class="mura-quickEditItem" data-attribute="display">
			</cfif>

			<cfif rc.rstop.Display eq 1 and rc.rstop.approved>
				<i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.true")#"></i><span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.true")#</span>
			<cfelseif rc.rstop.Display eq 2 and rc.rstop.approved>
				<cfif not (perm eq 'editor' and request.hasPublishingTab)>
					<a href="##" rel="tooltip" title="#esapiEncode('html_attr','#LSDateFormat(rc.rstop.displaystart,"short")#&nbsp;-&nbsp;#LSDateFormat(rc.rstop.displaystop,"short")#')#"></a>
				</cfif>
				<i class="mi-calendar"></i>
				<cfif not (perm eq 'editor' and request.hasPublishingTab)></a></cfif>
			<cfelse>
				<i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.false")#"></i><span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.false")#</span>
			</cfif>

			<cfif request.hasPublishingTab and rc.topid neq '00000000000000000000000000000000001'>
				</a>
			</cfif>
		</dd>
 
		<dd class="template">
		 <cfif perm eq 'editor' and request.hasLayoutObjectsTab><a class="mura-quickEditItem<cfif len(rc.rstop.template) or len(rc.rstop.childtemplate)> template-set</cfif>" data-attribute="template"></cfif>
	   <cfif len(rc.rstop.template) or len(rc.rstop.childTemplate)>
		   <i class="mi-list-alt" title="#rc.rstop.template#"></i><span>#rc.rstop.template#</span>
	   <cfelse>
		 <span class="bullet" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.inherit")#">&bull;</span>
			   <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.inherit")#</span>
			</cfif>
	   <cfif perm eq 'editor' and request.hasLayoutObjectsTab></a></cfif>
	 </dd>
	  </cfif>
	  <cfif rc.rstop.moduleid eq '00000000000000000000000000000000000'>
		 <dd class="nav">
		 <cfif perm eq 'editor' and request.hasPublishingTab><a class="mura-quickEditItem" data-attribute="isnav"></cfif>
		 <cfif rc.rstop.isnav><i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.#yesnoformat(rc.rstop.isnav)#")#"></i><cfelse><i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.#yesnoformat(rc.rstop.isnav)#")#"></i></cfif>       <span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.#yesnoformat(rc.rstop.isnav)#")#</span>
		 <cfif perm eq 'editor' and request.hasPublishingTab></a></cfif>
	   </dd>
	   <cfelse>
		 <dd class="display<cfif rc.rstop.Display eq 2 and rc.rstop.approved> scheduled</cfif>">

		<cfif rc.rstop.type neq 'Module' and perm eq 'editor' and request.hasPublishingTab>
		   <a class="mura-quickEditItem<cfif rc.rstop.Display eq 2 and rc.rstop.approved> tooltip</cfif>" data-attribute="display"></cfif>

	   	<cfif rc.rstop.Display eq 1 and rc.rstop.approved >
			   <i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.true")#"></i><span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.true")#</span>
		<cfelseif rc.rstop.Display eq 2 and rc.rstop.approved>
			<cfif not (perm eq 'editor' and request.hasPublishingTab)>
				 <a href="##" rel="tooltip" title="#esapiEncode('html_attr','#LSDateFormat(rc.rstop.displaystart,"short")#&nbsp;-&nbsp;#LSDateFormat(rc.rstop.displaystop,"short")#')#"></a>
			</cfif>
			<i class="mi-calendar"></i>
			<cfif not (perm eq 'editor' and request.hasPublishingTab)></a></cfif>
		<cfelse>
			<i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.false")#"></i><span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.false")#</span>
		</cfif>
	   <cfif perm eq 'editor'and request.hasPublishingTab></a></cfif>
	 </dd>
	  </cfif>
	   	<cfif isDate(rc.rstop.lastupdate)>
		   <dd class="updated" title="#LSDateFormat(rc.rstop.lastupdate,session.dateKeyFormat)# #LSTimeFormat(rc.rstop.lastupdate,"short")#">#LSDateFormat(rc.rstop.lastupdate,session.dateKeyFormat)#</dd>
	   <cfelse>
			 <dd class="updated"></dd>
	   </cfif>
	   <!--- actions hidden w/ css, copied to actions menu w/ js
	   do not delete! --->
	  <dd class="actions">
		<ul>
		<cfif rc.rstop.type neq 'Module' and not listFindNoCase('none,read',perm)>
  	  <cfset isLockedBySomeoneElse=$.siteConfig('hasLockableNodes') and len(rc.rsTop.lockid) and rc.rsTop.lockid neq session.mura.userid>
      <li class="edit<cfif isLockedBySomeoneElse> disabled</cfif>"><a onclick="draftprompt.call(this,event);return false;" data-siteid="#rc.siteid#" data-contentid="#rc.rstop.contentid#" data-contenthistid="#rc.rstop.contenthistid#" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.edit")#" href="" data-href="./?muraAction=cArch.edit&contenthistid=#rc.rstop.ContentHistID#&siteid=#esapiEncode('url',rc.siteid)#&contentid=#rc.topid#&topid=#esapiEncode('url',rc.topid)#&type=#rc.rstop.type#&parentid=#rc.rstop.parentid#&moduleid=#rc.rstop.moduleid#"><i class="mi-pencil"></i></a></li>
     
      <cfif rc.rstop.moduleid eq '00000000000000000000000000000000000' 
      	or (rc.rstop.moduleid eq '00000000000000000000000000000000099' and rc.rstop.type eq 'Variation')>
        <cfswitch expression="#rc.rstop.type#">
					<cfcase value="Page,Folder,Calendar,Gallery">
				  	<cfif $.getContentRenderer().useLayoutManager()>
							<li class="edit-layout"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.edit-layout")#" href="#application.settingsManager.getSite(rc.siteid).getWebPath(complete=1)##$.getContentRenderer().editroute##$.getURLStem(rc.siteid,rc.rstop.filename)#?editlayout=true"><i class="mi-th"></i></a></li>
						</cfif>	
	    		 <li class="preview"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#" href="#application.settingsManager.getSite(rc.siteid).getWebPath(complete=1)##$.getContentRenderer().editroute##$.getURLStem(rc.siteid,rc.rstop.filename)#"><i class="mi-globe"></i></a></li>
    		 	</cfcase>
					<cfcase value="File,Link">
						<li class="preview"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#" href="##" onclick="return preview('#application.settingsManager.getSite(rc.siteid).getWebPath(complete=1)##$.getContentRenderer().editroute##$.getURLStem(rc.siteid,rc.rstop.filename)#','#esapiEncode('javascript',rc.rstop.targetParams)#');"><i class="mi-globe"></i></a></li>
					</cfcase>
					<cfcase value="Variation">
						<li class="preview"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#" href="#esapiEncode('html_attr',rc.rstop.remoteurl)#"><i class="mi-globe"></i></a></li>
					</cfcase>
					<cfdefaultcase>
						<li class="preview disabled"><a><i class="mi-globe"></i></a></li>
					</cfdefaultcase>
				</cfswitch>
      </cfif>

    	<li class="version-history"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.versionhistory")#" href="./?muraAction=cArch.hist&contentid=#rc.rstop.ContentID#&type=#rc.rstop.type#&parentid=#rc.rstop.parentID#&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rstop.moduleid#"><i class="mi-history"></i></a></li>
      <cfif rc.rstop.type eq 'Form'>
    		<li class="manage-data"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.managedata")#"  href="./?muraAction=cArch.datamanager&contentid=#esapiEncode('url',rc.rstop.contentid)#&siteid=#esapiEncode('url',rc.rstop.siteid)#&topid=#esapiEncode('url',rc.topid)#&moduleid=#esapiEncode('url',rc.rstop.moduleid)#&type=Form&parentid=#esapiEncode('url',rc.rstop.parentid)#"><i class="mi-wrench"></i></a></li>
    	</cfif>
      <cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
    		<li class="permissions"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.permissions")#" href="./?muraAction=cPerm.main&contentid=#rc.topid#&parentid=&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rstop.moduleid#&type=#rc.rstop.type#"><i class="mi-group"></i></a></li>
    	<cfelse>
    		<li class="permissions disabled"><a><i class="mi-group"></i></a></li>
    	</cfif>
    	<cfif application.settingsManager.getSite(rc.siteid).getlocking() neq 'all'>
    		<li class="delete disabled"><a><i class="mi-trash"></i></a></li>
    	</cfif>
		<cfelse>
  		<li class="edit disabled"><a><i class="mi-pencil"></i></a></li>
      <cfif rc.rstop.moduleid eq '00000000000000000000000000000000000' or (rc.rstop.moduleid eq '00000000000000000000000000000000099' and rc.rstop.type eq 'Variation')>
  	  <cfswitch expression="#rc.rstop.type#">
    	   <cfcase value="Page,Folder,Calendar,Gallery">
    	   <li class="preview"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#" href="#application.settingsManager.getSite(rc.siteid).getWebPath(complete=1)##$.getContentRenderer().editroute##$.getURLStem(rc.siteid,rc.rstop.filename)#"><i class="mi-globe"></i></a></li>
    	   </cfcase>
    	   <cfcase value="File,Link">
    	   <li class="preview"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#" href="##" onclick="return preview('#application.settingsManager.getSite(rc.siteid).getWebPath(complete=1)##$.getContentRenderer().editroute##$.getURLStem(rc.siteid,rc.rstop.filename)#','#esapiEncode('javascript',rc.rstop.targetParams)#');"><i class="mi-globe"></i></a></li>
    	   </cfcase>
    	   <cfcase value="Variation">
    	   <li class="preview"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.view")#" href="#esapiEncode('html_attr',rc.rstop.remoteurl)#"><i class="mi-globe"></i></a></li>
    	   </cfcase>
    	   <cfdefaultcase>
    	   <li class="preview disabled"><a><i class="mi-globe"></i></a></li>
    	   </cfdefaultcase>
    	   </cfswitch>
      </cfif>
      <cfif rc.rstop.moduleid eq '00000000000000000000000000000000004'>
        <li class="import"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.importnode")#"  href="./?muraAction=cForm.importform&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-upload"></i></a></li>
      <cfelseif rc.rstop.moduleid eq '00000000000000000000000000000000003'>
          <li class="import"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.importnode")#"  href="./?muraAction=cArch.importcomponent&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-upload"></i></a></li>
      </cfif>
		  <li class="version-history disabled"><a><i class="mi-history"></i></a></li>
  		<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
  		  <li class="permissions"><a title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.permissions")#" href="./?muraAction=cPerm.main&contentid=#rc.topid#&parentid=&topid=#esapiEncode('url',rc.topid)#&siteid=#esapiEncode('url',rc.siteid)#&moduleid=#rc.rstop.moduleid#&type=#rc.rstop.type#"><i class="mi-group"></i></a></li>
  		<cfelse>
  		  <li class="permissions disabled"><a><i class="mi-group"></i></a></li>
  		</cfif>
  		<li class="delete disabled"><a><i class="mi-trash"></i></a></li>
		</cfif>
	   <cfset pluginEvent.setValue('type', rc.rstop.type)>
		   <cfset pluginEvent.setValue('filename', rc.rstop.filename)>
		   <cfset pluginEvent.setValue('contentid', rc.rstop.contentid)>
		   <cfset pluginEvent.setValue('contenthistid', rc.rstop.contenthistid)>
	   #application.pluginManager.renderScripts("onContentList",rc.siteid,pluginEvent)# #application.pluginManager.renderScripts("on#rc.rstop.type#List",rc.siteid,pluginEvent)# #application.pluginManager.renderScripts("on#rc.rstop.type##rc.rstop.subtype#List",rc.siteid,pluginEvent)#
		 </ul></dd>
	   </dl>

	   <cfif hasKids>
		 <cf_dsp_nest topid="#rc.topid#" parentid="#rc.topid#" locking="#application.settingsManager.getSite(rc.siteid).getlocking()#" nestlevel="1" perm="#perm#" siteid="#rc.siteid#" moduleid="#rc.rstop.moduleid#" restricted="#r#" viewdepth="1" nextn="#session.mura.nextN#" startrow="#rc.startrow#" sortBy="#rc.sortBy#" sortDirection="#rc.sortDirection#" pluginEvent="#pluginEvent#" muraScope="#rc.$#">
	   </cfif>
	   </li>
	   </ul>
	 </div>
	 </div> <!-- /.overflow-wrap -->
	 <div class="clear=both"></div>
 </form>
 <cfif isMore>
 #pageList#
 </cfif>
</cfoutput>
</cfsavecontent>
<cfset data.perm=perm>
<cfset data.sortBy=rc.sortBy>
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#createObject("component","mura.json").encode(data)#</cfoutput><cfabort>
