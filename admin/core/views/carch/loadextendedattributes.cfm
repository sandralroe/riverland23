<!--- License goes here --->

<cfset request.layout=false />
<cfset returnsets=structNew() />
<cfif isDefined("session.mura.editBean") and isInstanceOf(session.mura.editBean, "mura.content.contentBean") and session.mura.editBean.getContentHistID() eq rc.contentHistID>
	<cfset contentBean=session.mura.editBean />
<cfelse>
	<cfset contentBean=application.contentManager.getcontentVersion(rc.contentHistID,rc.siteID) />
</cfif>
<cfset structDelete(session.mura,"editBean") />
<cfset request.event.setValue('contentBean',contentBean) />
<cfset subtype=application.classExtensionManager.getSubTypeByName(rc.type,rc.subtype,rc.siteid) />

<cfif contentBean.getIsNew()>
	<cfset contentBean.setType(rc.type) />
	<cfset contentBean.setSubType(rc.subtype) />
</cfif>

<cfloop list="#application.contentManager.getTabList(legacyTabs=true)#" index="container">
	<cfif container eq 'Extended Attributes'>
		<cfset container='Default' />
	</cfif>

	<cfset containerID=REreplace(container, "[^\\\w]", "", "all")>
	
	<cfsavecontent variable="returnsets.#containerID#">
	<!--- debug: show container id string in each tab --->
	<!--- <cfdump var="#containerID#"> --->
		<cfset extendSets=subtype.getExtendSets(inherit=true,container=container,activeOnly=true) />
		<cfset started=false />
		<cfoutput>
			<cfif arrayLen(extendSets)>
				<cfloop from="1" to="#arrayLen(extendSets)#" index="s">
					<cfset extendSetBean=extendSets[s] />
					<cfset style=extendSetBean.getStyle()/><cfif not len(style)><cfset started=true/></cfif>
					<span class="extendset" extendsetid="#extendSetBean.getExtendSetID()#" categoryid="#extendSetBean.getCategoryID()#" #style#>
						<input name="extendSetID" type="hidden" value="#extendSetBean.getExtendSetID()#" />
						<h2>#esapiEncode('html', extendSetBean.getName())#</h2>
						<cfsilent>
							<cfset attributesArray=extendSetBean.getAttributes() />
						</cfsilent>
						<cfloop from="1" to="#arrayLen(attributesArray)#" index="a">
							<cfset attributeBean=attributesArray[a] />
							<cfset attributeValue=contentBean.getvalue(attributeBean.getName(), 'useMuraDefault') />
							<cfset readonly = attributeBean.getAdminOnly() and (not $.currentUser().isSuperUser() and not $.currentUser().isAdminUser()) />

							<!---
								Hidden attributes should be editable via the back-end Admin area
							--->
							<cfif attributeBean.getType() eq 'Hidden'>
								<cfset attributeBean.setType('TextBox') />
							</cfif>

							<div class="mura-control-group">
								<label>
									<cfif len(attributeBean.getHint())>
										<span
											data-toggle="popover"
											title=""
											data-placement="right"
											data-content="#esapiEncode('html_attr', attributeBean.getHint())#"
											data-original-title="#esapiEncode('html_attr', attributeBean.getLabel())#">
											#esapiEncode('html', attributeBean.getLabel())# <i class="mi-question-circle"></i>
										</span>
									<cfelse>
										#esapiEncode('html',attributeBean.getLabel())#
									</cfif>
								</label>

								#attributeBean.renderAttribute(theValue=attributeValue, bean=contentBean, compactDisplay=rc.compactDisplay, size='medium', readonly=readonly)#

								<cfif not readonly and attributeBean.getValidation() eq "URL">
									<cfif len(application.serviceFactory.getBean('settingsManager').getSite(session.siteid).getRazunaSettings().getHostname())>
										<div class="btn-group">
											<a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
												<i class="mi-folder-open"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.browseassets')#
											</a>
											<ul class="dropdown-menu">
												<li><a href="##" type="button" data-completepath="false" data-target="#esapiEncode('javascript',attributeBean.getName())#" data-resourcetype="user" class="mura-file-type-selector mura-finder" title="Select a File from Server">
													<i class="mi-folder-open"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.local')#</a></li>
												<li><a href="##" type="button" onclick="renderRazunaWindow('#esapiEncode('javascript',attributeBean.getName())#');return false;" class="mura-file-type-selector btn-razuna-icon" value="URL-Razuna" title="Select a File from Razuna"><i></i> Razuna</a></li>
											</ul>
										</div>
									<cfelse>
										<div class="btn-group">
											<button type="button" data-target="#esapiEncode('javascript',attributeBean.getName())#" data-resourcetype="user" class="btn mura-file-type-selector mura-finder" title="Select a File from Server"><i class="mi-folder-open"></i> Browse Assets</button>
										</div>
									</cfif>
								</cfif>
							</div>
						</cfloop>
					</span>
				</cfloop>
			</cfif>
		</cfoutput>
	</cfsavecontent>
	<cfset returnsets[containerID]=trim(returnsets[containerID]) />
</cfloop>
<cftry>
	<cfparam name="rc.tablist" default="tabPrimary,tabAssoc,tabBasic,tabCategorization,tabExtendedattributes,tabLayoutObjects,tabPublishing,tabRelatedcontent,tabRemote,tabSchedule,tabSummary,tabTags">
	<cfloop list="#rc.tablist#" index="tab">
		<cfloop list="top,bottom" index="context">
			<cfsavecontent variable="returnsets.#tab##context#">
				<cfoutput>
					<cf_dsp_rendertabevents context="#context#" tab="#tab#">
				</cfoutput>
			</cfsavecontent>

			<cfset returnsets[tab & context ]=trim(returnsets[tab & context])>
		</cfloop>
	</cfloop>
	<cfcatch>
		<cfoutput>#cfcatch.message#</cfoutput>
	</cfcatch>
</cftry>

<cfset returnsets.hasSummary=subType.getHasSummary() />
<cfset returnsets.hasBody=subType.getHasBody() />
<cfset returnsets.hasAssocFile=subType.getHasAssocFile() />
<cfset returnsets.hasConfigurator=subType.getHasConfigurator() />

<!--- escape control characters in JSON --->
<cfset result = createObject("component","mura.json").encode(returnsets) />
<cfset result = reReplace(result, "[[:cntrl:]]", "", "all") />
<cfcontent type="application/json; charset=utf-8" reset="true"><cfoutput>#result#</cfoutput><cfabort>
