<!--- license goes here --->
<cfset request.layout=false>
<cfparam name="rc.keywords" default="">
<cfparam name="rc.isNew" default="1">
<cfparam name="rc.contentpoolid" default="#rc.siteid#">

<cfset counter=0 />
<cfoutput>
	<div id="contentSearch" class="form-inline">
		<!--- <h2>#application.rbFactory.getKeyValue(session.rb,'collections.contentsearch')#</h2> --->
		<div class="mura-input-set">
			<input class="form-control" id="parentSearch" name="parentSearch" value="#esapiEncode('html_attr',rc.keywords)#" type="text" maxlength="50" placeholder="#application.rbFactory.getKeyValue(session.rb,'collections.search')#" onclick="return false;">
			<button type="button" class="btn btn-default" onclick="feedManager.loadSiteFilters('#rc.siteid#',document.getElementById('parentSearch').value,0,$('##contentPoolID').val());"><i class="mi-search"></i></button>
		</div>	
	</div>
</cfoutput>

<cfif not rc.isNew>
	<cfif listFindNoCase(rc.contentPoolID,rc.siteid) or not len(rc.contentPoolID)>
		<cfset rc.rsList=application.contentManager.getPrivateSearch(rc.siteid,rc.keywords)/>
		<div id="contentResults" class="mura-control justify">
			<table class="mura-table-grid">
				<thead>
					<tr> 
						<th class="actions"></th>
						<th class="var-width">
							<cfoutput>#$.getBean('settingsManager').getSite(rc.siteid).getSite()#: #application.rbFactory.getKeyValue(session.rb,'collections.selectnewsection')#</cfoutput>
						</th>
					</tr>
				</thead>
				<tbody>
					<cfif rc.rslist.recordcount>
						<cfoutput query="rc.rslist" startrow="1" maxrows="100">	
							<cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.siteid)/>
							<cfset zoomText=$.dspZoomNoLinks(crumbdata,"&raquo;")>
							<cfif rc.rslist.type neq 'File' and rc.rslist.type neq 'Link'>
								<cfset counter=counter+1/>
								<tr id="add-#rc.rslist.contentid#" <cfif not(counter mod 2)>class="alt"</cfif>>
									<td class="actions">
										<ul><li class="add"><a title="#application.rbFactory.getKeyValue(session.rb,'collections.add')#" href="javascript:void(0);" onClick="feedManager.addContentFilter.bind(this, '#rc.rslist.contentid#','#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.type.#rc.rslist.type#'))#','#esapiEncode('javascript','mura-opt-#rc.rslist.contentid#')#')(); return false;"><i class="mi-plus-circle"></i></a></li></ul>
									</td>
									<td class="var-width" id="#esapiEncode('html_attr','mura-opt-#rc.rslist.contentid#')#">#zoomText#</td>
								</tr>
							</cfif>
						</cfoutput>
					<cfelse>
						<cfoutput>
							<tr class="alt"> 
								<td class="noResults" colspan="2">#application.rbFactory.getKeyValue(session.rb,'collections.nosearchresults')#</td>
							</tr>
						</cfoutput>
					</cfif>
				</tbody>
			</table>
		</cfif>
		<cfif listLen(rc.contentPoolID) gt 1>
			<cfloop list="#rc.contentPoolID#" index="p">
				<cfif p neq rc.siteid>
					<cfset rc.rsList=application.contentManager.getPrivateSearch(p,rc.keywords)/>
					<table class="mura-table-grid">
						<thead>
							<tr> 
								<th class="actions">&nbsp;</th>
								<th class="var-width">
									<cfoutput>#$.getBean('settingsManager').getSite(p).getSite()#: #application.rbFactory.getKeyValue(session.rb,'collections.selectnewsection')#</cfoutput>
								</th>
							</tr>
						</thead>
						<tbody>
							<cfif rc.rslist.recordcount>
								<cfoutput query="rc.rslist" startrow="1" maxrows="100">	
									<cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, p)/>
									<cfset zoomText=$.dspZoomNoLinks(crumbdata,"&raquo;")>
									<cfif rc.rslist.type neq 'File' and rc.rslist.type neq 'Link'>
										<cfset counter=counter+1/>
										<tr id="add-#rc.rslist.contentid#" <cfif not(counter mod 2)>class="alt"</cfif>>
											<td class="actions" >
												<ul><li class="add"><a title="#application.rbFactory.getKeyValue(session.rb,'collections.add')#" href="javascript:void(0);" onClick="feedManager.addContentFilter.bind(this, '#rc.rslist.contentid#','#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.type.#rc.rslist.type#'))#','#esapiEncode('javascript','mura-opt-#p#-#rc.rslist.contentid#')#')(); return false;"><i class="mi-plus-circle"></i></a></li></ul>
											</td>
											<td class="var-width" id="#esapiEncode('html_attr','mura-opt-#p#-#rc.rslist.contentid#')#" >
												#zoomText#
											</td>
										</tr>
									</cfif>
								</cfoutput>
							<cfelse>
								<cfoutput>
									<tr class="alt"> 
										<td class="noResults" colspan="2">#application.rbFactory.getKeyValue(session.rb,'collections.nosearchresults')#</td>
									</tr>
								</cfoutput>
							</cfif>
						</tbody>
					</table>
				</div><!-- /.mura-control -->	
			</cfif>
		</cfloop>
	</cfif>
</cfif>