<!--- license goes here --->
<cfif listLen(rc.subclassid) gt 1>
	<cfset rc.objectid = listLast(rc.subclassid)>
	<cfset rc.subclassid = listFirst(rc.subclassid)>
</cfif>
<cfset rc.rsPlugins = application.pluginManager.getDisplayObjectsBySiteID(siteID=rc.siteid,
                                                                              modulesOnly=true)/>

<cfif rc.layoutmanager>
	<cfoutput>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		<select name="subClassSelector"
		        onchange="mura.loadObjectClass('#rc.siteid#','plugins',this.value,'#rc.contentid#','#rc.parentid#','#rc.contenthistid#','#rc.instanceid#');">
			<option value="">
				#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.selectplugin')#
			</option>
			<cfloop query="rc.rsPlugins">
				<cfif application.permUtility.getModulePerm(rc.rsPlugins.moduleID, rc.siteid)>
					<option title="#esapiEncode('html_attr',rc.rsPlugins.title)#" value="#rc.rsPlugins.moduleID#" <cfif rc.rsPlugins.moduleID eq rc.subclassid>selected</cfif>>#esapiEncode('html',rc.rsPlugins.title)#</option>
				</cfif>
			</cfloop>
		</select>
	</cfoutput>

	<cfif len(rc.subclassid)>

		<cfset prelist = application.pluginManager.getDisplayObjectsBySiteID(siteID=rc.siteid,
		                                                                    moduleID=rc.subclassid)/>
		<cfset customOutputList = "">
		<cfset customOutput = "">
		<cfset customOutput1 = "">
		<cfset customOutput2 = "">
		<cfloop query="prelist">
			<cfif listLast(prelist.displayObjectFile, ".") neq "cfm">
				<cfset displayObject = application.pluginManager.getComponent("plugins.#prelist.directory#.#prelist.displayobjectfile#",
				                                                              prelist.pluginID,
				                                                              rc.siteID,prelist.docache)>
				<cfif structKeyExists(displayObject, "#prelist.displayMethod#OptionsRender")>
					<cfset customOutputList = listAppend(customOutputList, prelist.objectID)>
					<cfif rc.objectID eq prelist.objectID>
						<cfset event = createObject("component", "mura.event").init(rc)>
						<cfset muraScope = event.getValue("muraScope")>
						<cfsavecontent variable="customOutput1">
				<cfinvoke component="#displayObject#" method="#prelist.displaymethod#OptionsRender" returnvariable="customOutput2">
					<cfinvokeargument name="event" value="#event#">
					<cfinvokeargument name="$" value="#muraScope#">
					<cfinvokeargument name="mura" value="#muraScope#">
				</cfinvoke>
				</cfsavecontent>
						<cfif isdefined("customOutput2")>
							<cfset customOutput = trim(customOutput2)>
						<cfelse>
							<cfset customOutput = trim(customOutput1)>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfif len(customOutputList)>
			<cfquery name="rs" dbtype="query">
				select * from prelist where
				objectID in (''
				<cfloop list="#customOutputList#" index="i">
					,'#i#'
				</cfloop>
				)
			</cfquery>
			<cfoutput>
				<select name="customObjectSelector"
				        onchange="mura.loadObjectClass('#rc.siteid#','plugins',this.value,'#rc.contentid#','#rc.parentid#','#rc.contenthistid#','#rc.instanceid#');">
					<option value="">
						#application.rbFactory.getKeyValue(session.rb,
					                                    'sitemanager.content.fields.selectplugindisplayobjectclass')#
					</option>
					<cfloop query="rs">
						<cfif application.permUtility.getModulePerm(rs.moduleID, rc.siteid)>
							<option title="#esapiEncode('html_attr',rs.name)#" value="#rs.moduleID#,#rs.objectID#" <cfif rs.objectID eq rc.objectID>selected</cfif>>#esapiEncode('html',rs.name)#</option>
						</cfif>
					</cfloop>
				</select>
			</cfoutput>
		</cfif>
		<cfif not len(customOutput)>
			<cfquery name="rs" dbtype="query">
				select * from prelist where
				objectID not in (''
				<cfloop list="#customOutputList#" index="i">
					,'#i#'
				</cfloop>
				)
			</cfquery>
			<cfif rs.recordcount>
				<cfoutput query="rs">
					#contentRendererUtility.renderObjectClassOption(
						object='plugin',
						objectid=rs.objectID,
						objectname='#rs.title# - #rs.name#',
						objectlabel=rs.name
					)#
				</cfoutput>
			</cfif>
		<cfelse>
			<cfoutput>#customOutput#</cfoutput>
		</cfif>
	</cfif>
	</div>
	</div>
<cfelse>
	<cfoutput>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		<select name="subClassSelector"
		        onchange="siteManager.loadObjectClass('#rc.siteid#','plugins',this.value,'#rc.contentid#','#rc.parentid#','#rc.contenthistid#','#rc.instanceid#');"
		        class="dropdown">
			<option value="">
				#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.selectplugin')#
			</option>
			<cfloop query="rc.rsPlugins">
				<cfif application.permUtility.getModulePerm(rc.rsPlugins.moduleID, rc.siteid)>
					<option title="#esapiEncode('html_attr',rc.rsPlugins.title)#" value="#rc.rsPlugins.moduleID#" <cfif rc.rsPlugins.moduleID eq rc.subclassid>selected</cfif>>#esapiEncode('html',rc.rsPlugins.title)#</option>
				</cfif>
			</cfloop>
		</select>
	</cfoutput>

	<cfif len(rc.subclassid)>

		<cfset prelist = application.pluginManager.getDisplayObjectsBySiteID(siteID=rc.siteid,
		                                                                    moduleID=rc.subclassid)/>
		<cfset customOutputList = "">
		<cfset customOutput = "">
		<cfset customOutput1 = "">
		<cfset customOutput2 = "">
		<cfloop query="prelist">
			<cfif listLast(prelist.displayObjectFile, ".") neq "cfm">
				<cfset displayObject = application.pluginManager.getComponent("plugins.#prelist.directory#.#prelist.displayobjectfile#",
				                                                              prelist.pluginID,
				                                                              rc.siteID,prelist.docache)>
				<cfif structKeyExists(displayObject, "#prelist.displayMethod#OptionsRender")>
					<cfset customOutputList = listAppend(customOutputList, prelist.objectID)>
					<cfif rc.objectID eq prelist.objectID>
						<cfset event = createObject("component", "mura.event").init(rc)>
						<cfset muraScope = event.getValue("muraScope")>
						<cfsavecontent variable="customOutput1">
				<cfinvoke component="#displayObject#" method="#prelist.displaymethod#OptionsRender" returnvariable="customOutput2">
					<cfinvokeargument name="event" value="#event#">
					<cfinvokeargument name="$" value="#muraScope#">
					<cfinvokeargument name="mura" value="#muraScope#">
				</cfinvoke>
				</cfsavecontent>
						<cfif isdefined("customOutput2")>
							<cfset customOutput = trim(customOutput2)>
						<cfelse>
							<cfset customOutput = trim(customOutput1)>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfloop>

		<cfif len(customOutputList)>
			<cfquery name="rs" dbtype="query">
				select * from prelist where
				objectID in (''
				<cfloop list="#customOutputList#" index="i">
					,'#i#'
				</cfloop>
				)
			</cfquery>
			<cfoutput>
				<select name="customObjectSelector"
				        onchange="siteManager.loadObjectClass('#rc.siteid#','plugins',this.value,'#rc.contentid#','#rc.parentid#','#rc.contenthistid#','#rc.instanceid#');"
				        class="dropdown">
					<option value="">
						#application.rbFactory.getKeyValue(session.rb,
					                                    'sitemanager.content.fields.selectplugindisplayobjectclass')#
					</option>
					<cfloop query="rs">
						<cfif application.permUtility.getModulePerm(rs.moduleID, rc.siteid)>
							<option title="#esapiEncode('html_attr',rs.name)#" value="#rs.moduleID#,#rs.objectID#" <cfif rs.objectID eq rc.objectID>selected</cfif>>#esapiEncode('html',rs.name)#</option>
						</cfif>
					</cfloop>
				</select>
			</cfoutput>
		</cfif>
		<cfif not len(customOutput)>
			<cfquery name="rs" dbtype="query">
				select * from prelist where
				objectID not in (''
				<cfloop list="#customOutputList#" index="i">
					,'#i#'
				</cfloop>
				)
			</cfquery>
			<cfif rs.recordcount>
				<div class="mura-control justify">
				<cfoutput>
					<select name="availableObjects" id="availableObjects" class="multiSelect"
					        size="#evaluate((application.settingsManager.getSite(rc.siteid).getcolumnCount() * 6)-4)#">
				</cfoutput>
				<cfoutput query="rs">
					<option value="{'object':'plugin','name':'#esapiEncode('javascript','#rs.name#')#','objectid':'#rs.objectID#'}">
						#rs.name#
					</option>
				</cfoutput>
				<cfoutput>
					</select>
				</cfoutput>
				</div>
			</cfif>
		<cfelse>
			<cfoutput>#customOutput#</cfoutput>
		</cfif>
	</cfif>
	</div>
	</div>
</cfif>
