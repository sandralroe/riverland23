<!--- License goes here --->

<cfoutput>
	<cfif listFindNoCase(pageLevelList,rc.type)>
		<div class="mura-control-group mura-type-selector">
			<label>
				#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type")#
			</label>
				<select name="typeSelector" onchange="siteManager.resetExtendedAttributes('#rc.contentBean.getcontentID()#','#rc.contentBean.getcontentHistID()#',this.value,'#esapiEncode("Javascript",rc.siteID)#','#application.configBean.getContext()#','#application.settingsManager.getSite(rc.siteID).getThemeAssetPath()#');">
				<cfset primaryContentTypes=rc.$.getContentRenderer().primaryContentTypes>
				<cfif rc.$.event('moduleid') != '00000000000000000000000000000000000'>
					<cfset primaryContentTypes="Folder">
				</cfif>
				<cfloop list="#baseTypeList#" index="t">
				<cfif t eq rc.contentBean.getType() or (not len(primaryContentTypes) or listFindNoCase(primaryContentTypes,t))>
				<cfsilent>
					<cfquery name="rsst" dbtype="query">
						select * from rsSubTypes where type=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#t#"> and subtype not in ('Default','default')
						<cfif not (rc.$.currentUser().isAdminUser() or rc.$.currentUser().isSuperUser())>
							and (
								adminonly !=1

								or (
									type=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#rc.contentBean.getType()#">
									and subtype=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#rc.contentBean.getSubType()#">
								)
							)

						</cfif>
					</cfquery>
				</cfsilent>
				<cfif not len(subtypefilter) or listFindNoCase(subtypefilter,'#t#/Default')>
					<option value="#t#^Default" <cfif rc.type eq t and rc.contentBean.getSubType() eq "Default">selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#lcase(t)#")#</option>
				</cfif>
					<cfif rsst.recordcount>
						<cfloop query="rsst">
							<cfif not len(subtypefilter) or listFindNoCase(subtypefilter,'#t#/#rsst.subtype#')>
								<option value="#t#^#rsst.subtype#" <cfif rc.type eq t and rc.contentBean.getSubType() eq rsst.subtype>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#lcase(t)#")#  / #rsst.subtype#</option>
							</cfif>
						</cfloop>
					</cfif>
				</cfif>
				</cfloop>
			</select>
			</div>
	<cfelseif rc.type eq 'File'>
		<cfset t="File"/>
		<cfsilent>
			<cfquery name="rsst" dbtype="query">select * from rsSubTypes where type=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#t#"> and subtype not in ('Default','default')</cfquery>
		</cfsilent>
		<cfif rsst.recordcount>
			<div class="mura-control-group">
				<label>
					#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type")#
				</label>
					<select name="typeSelector" onchange="siteManager.resetExtendedAttributes('#rc.contentBean.getcontentID()#','#rc.contentBean.getcontentHistID()#',this.value,'#rc.siteID#','#application.configBean.getContext()#','#application.settingsManager.getSite(rc.siteID).getThemeAssetPath()#');">
						<cfif not len(subtypefilter) or listFindNoCase(subtypefilter,'#t#/Default')>
							<option value="#t#^Default" <cfif rc.type eq t and rc.contentBean.getSubType() eq "Default">selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#t#")#</option>
						</cfif>
						<cfif rsst.recordcount>
							<cfloop query="rsst">
								<cfif not len(subtypefilter) or listFindNoCase(subtypefilter,'#t#/#rsst.subtype#')>
									<option value="#t#^#rsst.subtype#" <cfif rc.type eq t and rc.contentBean.getSubType() eq rsst.subtype>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#lcase(t)#")# / #rsst.subtype#</option>
								</cfif>
							</cfloop>
						</cfif>
				</select>
				</div>
		</cfif>
	<cfelseif rc.type eq 'Link'>
		<cfset t="Link"/>
		<cfsilent>
			<cfquery name="rsst" dbtype="query">select * from rsSubTypes where type=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#t#"> and subtype not in ('Default','default')</cfquery>
		</cfsilent>
		<cfif rsst.recordcount>
			<div class="mura-control-group">
				<label>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type")#</label>
				<select name="typeSelector"  onchange="siteManager.resetExtendedAttributes('#rc.contentBean.getcontentID()#','#rc.contentBean.getcontentHistID()#',this.value,'#rc.siteID#','#application.configBean.getContext()#','#application.settingsManager.getSite(rc.siteID).getThemeAssetPath()#');">
					<cfif not len(subtypefilter) or listFindNoCase(subtypefilter,'#t#/Default')>
						<option value="#t#^Default" <cfif rc.type eq t and rc.contentBean.getSubType() eq "Default">selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#lcase(t)#")#</option>
					</cfif>
					<cfif rsst.recordcount>
						<cfloop query="rsst">
							<cfif not len(subtypefilter) or listFindNoCase(subtypefilter,'#t#/#rsst.subtype#')>
								<cfif rsst.subtype neq 'Default'><option value="#t#^#rsst.subtype#" <cfif rc.type eq t and rc.contentBean.getSubType() eq rsst.subtype>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#lcase(t)#")#  / #rsst.subtype#</option></cfif>
							</cfif>
						</cfloop>
					</cfif>
				</select>
			</div>
		</cfif>
	<cfelseif listFindNoCase('Component,Form',rc.type)>
		<cfset t=rc.type/>
			<cfsilent><cfquery name="rsst" dbtype="query">select * from rsSubTypes where type=<cfqueryparam cfsqltype="cf_sql_varchar"  value="#t#"> and subtype not in ('Default','default')</cfquery>
		</cfsilent>
		<cfif rsst.recordcount>
			<div class="mura-control-group">
				<label>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type")#</label>
				<select name="typeSelector"  onchange="siteManager.resetExtendedAttributes('#rc.contentBean.getcontentID()#','#rc.contentBean.getcontentHistID()#',this.value,'#rc.siteID#','#application.configBean.getContext()#','#application.settingsManager.getSite(rc.siteID).getThemeAssetPath()#');">
					<option value="#t#^Default" <cfif rc.type eq t and rc.contentBean.getSubType() eq "Default">selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#lcase(t)#")#</option>
					<cfif rsst.recordcount>
						<cfloop query="rsst">
							<cfif rsst.subtype neq 'Default'><option value="#t#^#rsst.subtype#" <cfif rc.type eq t and rc.contentBean.getSubType() eq rsst.subtype>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.type.#lcase(t)#")#  / #rsst.subtype#</option></cfif>
						</cfloop>
					</cfif>
				</select>
			</div>
		</cfif>
	</cfif>



</cfoutput>
