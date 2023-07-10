<!--- License goes here --->

<cfsilent>
	<cfset request.layout=false />
	<cfset returnsets=structNew() />
	<cfif isDefined("session.mura.editBean") and isInstanceOf(session.mura.editBean, "mura.user.userBean") and session.mura.editBean.getUserID() eq rc.baseID>
		<cfset userBean=session.mura.editBean />
	<cfelse>
		<cfset userBean=application.userManager.read(userid=rc.baseID, siteid=rc.siteid) />
	</cfif>
	<cfset structDelete(session.mura,"editBean") />
	<cfset extendSets=application.classExtensionManager.getSubTypeByName(rc.type,rc.subtype,rc.siteid).getExtendSets(inherit=true,container="Default",activeOnly=true) />
	<cfset started=false />
	<cfset style="" />
</cfsilent>
<cfsavecontent variable="returnsets.extended">
	<cfoutput>
		<cfif arrayLen(extendSets)>
			<cfloop from="1" to="#arrayLen(extendSets)#" index="s">
				<cfset extendSetBean=extendSets[s]/>
				<cfif  userBean.getType() eq 2><cfset style=extendSetBean.getStyle()/><cfif not len(style)><cfset started=true/></cfif></cfif>
				<span class="extendset" extendsetid="#extendSetBean.getExtendSetID()#" categoryid="#extendSetBean.getCategoryID()#" #style#>
					<input name="extendSetID" type="hidden" value="#extendSetBean.getExtendSetID()#" />
					<h2>#esapiEncode('html', extendSetBean.getName())#</h2>
					<cfsilent>
						<cfset attributesArray=extendSetBean.getAttributes() />
					</cfsilent>
					<cfloop from="1" to="#arrayLen(attributesArray)#" index="a">
						<cfset attributeBean=attributesArray[a] />
						<cfset attributeValue=userBean.getvalue(attributeBean.getName(), 'useMuraDefault') />
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
									<span data-toggle="popover"
										title=""
										data-placement="right"
										data-content="#esapiEncode('html_attr',attributeBean.getHint())#"
										data-original-title="#esapiEncode('html_attr',attributeBean.getLabel())#">
										#esapiEncode('html',attributeBean.getLabel())# <i class="mi-question-circle"></i>
									</span>
								<cfelse>
									#esapiEncode('html',attributeBean.getLabel())#
								</cfif>
							</label>

							#attributeBean.renderAttribute(theValue=attributeValue, bean=userBean, compactDisplay=rc.compactDisplay, size='medium', readonly=readonly)#

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

<cfset returnsets.extended=trim(returnsets.extended)>
<cfsilent>
	<cfset extendSets=application.classExtensionManager.getSubTypeByName(rc.type,rc.subtype,rc.siteid).getExtendSets(inherit=true,container="Basic",activeOnly=true) />
	<cfif userBean.getType() eq 2>
		<cfset started=false />
	<cfelse>
		<cfset started=true />
	</cfif>
	<cfset style="" />
</cfsilent>
<cfsavecontent variable="returnsets.basic">
	<cfoutput>
		<cfif arrayLen(extendSets)>
			<cfloop from="1" to="#arrayLen(extendSets)#" index="s">
				<cfset extendSetBean=extendSets[s] />
				<cfif  userBean.getType() eq 2><cfset style=extendSetBean.getStyle()/><cfif not len(style)><cfset started=true/></cfif></cfif>
				<span class="extendset" extendsetid="#extendSetBean.getExtendSetID()#" categoryid="#extendSetBean.getCategoryID()#" #style#>
					<input name="extendSetID" type="hidden" value="#extendSetBean.getExtendSetID()#" />
					<h2>#esapiEncode('html', extendSetBean.getName())#</h2>
					<cfsilent>
						<cfset attributesArray=extendSetBean.getAttributes() />
					</cfsilent>

					<cfloop from="1" to="#arrayLen(attributesArray)#" index="a">
						<cfset attributeBean=attributesArray[a] />
						<cfset attributeValue=userBean.getvalue(attributeBean.getName(),'useMuraDefault') />
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
									<span data-toggle="popover"
										title=""
										data-placement="right"
										data-content="#esapiEncode('html_attr', attributeBean.gethint())#"
										data-original-title="#esapiEncode('html_attr', attributeBean.getLabel())#">
										#esapiEncode('html', attributeBean.getLabel())# <i class="mi-question-circle"></i>
									</span>
								<cfelse>
									#esapiEncode('html', attributeBean.getLabel())#
								</cfif>
							</label>

							#attributeBean.renderAttribute(theValue=attributeValue, bean=userBean, compactDisplay=rc.compactDisplay, size='medium', readonly=readonly)#

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
<cfset returnsets.basic=trim(returnsets.basic)>
<cfoutput>#createObject("component","mura.json").encode(returnsets)#</cfoutput>
