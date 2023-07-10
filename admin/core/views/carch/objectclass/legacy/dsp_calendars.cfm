<!--- license goes here --->
<cfsilent>
<cfset rc.rsSections = application.contentManager.getSections(rc.siteid, 'Calendar')/>

<cfset pathStrings=arrayNew(1)>
<cfloop query="rc.rsSections">
	<cfset arrayAppend(pathStrings, $.dspZoomText(application.contentGateway.getCrumblist(contentid=rc.rsSections.contentid,siteid=rc.rsSections.siteid, path=rc.rsSections.path)))>
</cfloop>

<cfset queryAddColumn(rc.rsSections, "pathString", "cf_sql_varchar",pathStrings)>

<cfquery name="rc.rsSections" dbtype="query">
	select * from rc.rsSections order by pathString
</cfquery>
</cfsilent>
<cfoutput>
<cfif rc.layoutmanager>
<div class="mura-layout-row">
	<div class="mura-control-group">
		<select name="subClassSelector"
		        onchange="mura.loadObjectClass('#rc.siteid#','calendar',this.value,'#rc.contentid#','#rc.parentid#','#rc.contenthistid#','#rc.instanceid#');">
			<option value="">
				#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.selectcalendar')#
			</option>
			<cfloop query="rc.rsSections">
				<cfsilent>
				<cfset pathString=$.dspZoomText(application.contentGateway.getCrumblist(contentid=rc.rsSections.contentid,siteid=rc.rsSections.siteid, path=rc.rsSections.path))>
			</cfsilent>
				<option value="#rc.rsSections.contentID#" <cfif rc.rsSections.contentID eq rc.subclassid>selected</cfif>>#esapiEncode('html',rc.rsSections.pathString)#</option>
			</cfloop>
		</select>
		<cfif rc.subclassid neq ''>
			<cfloop query="rc.rsSections">
				<cfif rc.rsSections.contentID eq rc.subclassid>
					<cfsilent>
					<cfset pathString=$.dspZoomText(application.contentGateway.getCrumblist(contentid=rc.rsSections.contentid,siteid=rc.rsSections.siteid, path=rc.rsSections.path))>
					</cfsilent>

					<cfset title=rc.rsSections.pathString
						& ' - '
						& application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.categorysummary')>

					#contentRendererUtility.renderObjectClassOption(
						object='category_summary',
						objectid=rc.rsSections.contentid,
						objectname=title
					)#

					<cfset title=rc.rsSections.pathString
						& ' - '
						& application.rbFactory.getKeyValue(session.rb,
					                                    'sitemanager.content.fields.relatedcontent')>

					#contentRendererUtility.renderObjectClassOption(
						object='related_section_content',
						objectid=rc.rsSections.contentid,
						objectname=title
					)#

					<cfset title=rc.rsSections.pathString
						& ' - '
						& application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.calendarnavigation')>


					#contentRendererUtility.renderObjectClassOption(
						object='calendar_nav',
						objectid=rc.rsSections.contentid,
						objectname=title
					)#
				</cfif>
			</cfloop>
		</cfif>
	</div>
<div>

<cfelse>
	<div class="mura-layout-row">
		<div class="mura-control-group">
		<select name="subClassSelector"
		        onchange="siteManager.loadObjectClass('#rc.siteid#','calendar',this.value,'#rc.contentid#','#rc.parentid#','#rc.contenthistid#','#rc.instanceid#');"
		        class="dropdown">
			<option value="">
				#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.selectcalendar')#
			</option>
			<cfloop query="rc.rsSections">
				<cfsilent>
				<cfset pathString=$.dspZoomText(application.contentGateway.getCrumblist(contentid=rc.rsSections.contentid,siteid=rc.rsSections.siteid, path=rc.rsSections.path))>
			</cfsilent>
				<option value="#rc.rsSections.contentID#" <cfif rc.rsSections.contentID eq rc.subclassid>selected</cfif>>#esapiEncode('html',rc.rsSections.pathString)#</option>
			</cfloop>
		</select>
		<cfif rc.subclassid neq ''>
			<div class="mura-control justify">
			<select name="availableObjects" id="availableObjects" class="multiSelect"
			        size="#evaluate((application.settingsManager.getSite(rc.siteid).getcolumnCount() * 6)-4)#">
				<cfloop query="rc.rsSections">
					<cfif rc.rsSections.contentID eq rc.subclassid>
						<cfsilent>
						<cfset pathString=$.dspZoomText(application.contentGateway.getCrumblist(contentid=rc.rsSections.contentid,siteid=rc.rsSections.siteid, path=rc.rsSections.path))>
						</cfsilent>

						<cfset title=rc.rsSections.pathString
							& ' - '
							& application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.categorysummary')>

						<option title="#esapiEncode('html_attr',title)#" value="{'object':'category_summary','name':'#esapiEncode('javascript',title)#','objectid':'#rc.rsSections.contentid#'}">
							#esapiEncode('html',title)#
						</option>

						<cfset title=rc.rsSections.pathString
							& ' - '
							& application.rbFactory.getKeyValue(session.rb,
						                                    'sitemanager.content.fields.relatedcontent')>

						<option title="#esapiEncode('html_attr',title)#" value="{'object':'related_section_content','name':'#esapiEncode('html_attr',title)#','objectid':'#rc.rsSections.contentid#'}">
							#esapiEncode('html',title)#
						</option>

						<cfset title=rc.rsSections.pathString
							& ' - '
							& application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.calendarnavigation')>

						<option title="#esapiEncode('html_attr',title)#" value="calendar_nav~#esapiEncode('html',title)#~#rc.rsSections.contentid#">
						#esapiEncode('html',title)#
						</option>
					</option>
					</cfif>
				</cfloop>
			</select>
			</div>
		</cfif>
		<div>
	</div>
</cfif>
</cfoutput>
