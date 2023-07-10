<!--- license goes here --->
<cfoutput>
	<cfinclude template="js.cfm">
	<cfset rslist=application.classExtensionManager.getSubTypes(siteID=rc.siteID,activeOnly=false) />
	<cfset subType=application.classExtensionManager.getSubTypeByID(rc.subTypeID)>
	<cfset extendSets=subType.getExtendSets()/>

	<cfset showRelatedContentSets = not listFindNoCase("1,2,User,Group,Address,Site,Component,Form", subType.getType())>

	<cfif showRelatedContentSets>
		<cfset relatedContentsets = subType.getRelatedContentSets(includeInheritedSets=false)>
	</cfif>

<div class="mura-header">
	<h1>#rc.$.rbKey('sitemanager.extension.classextensionoverview')#</h1>

	<div class="nav-module-specific btn-group">
		<a class="btn" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.listSubTypes&amp;siteid=#esapiEncode('url',rc.siteid)#">
						<i class="mi-arrow-circle-left"></i>
			#rc.$.rbKey('sitemanager.extension.backtoclassextensions')#
		</a>
		<a class="btn" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.editSubType&amp;subTypeID=#esapiEncode('url',rc.subTypeID)#&amp;siteid=#esapiEncode('url',rc.siteid)#">
						<i class="mi-pencil"></i>
			#rc.$.rbKey('sitemanager.extension.editclassextension')#
		</a>

		<!--- Export --->
		<cfif rc.$.currentUser().isSuperUser()>
			<a class="btn" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.export&amp;exportClassExtensionID=#esapiEncode('url',rc.subTypeID)#&amp;siteid=#esapiEncode('url',rc.siteid)#">
							<i class="mi-sign-out"></i>
				#rc.$.rbKey('sitemanager.extension.exportclassextension')#
			</a>
		</cfif>

		<div class="btn-group">
			<a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
							<i class="mi-plus-circle"></i>
				#rc.$.rbKey('sitemanager.extension.add')#
				<span class="caret"></span>
			</a>
			<ul class="dropdown-menu">
				<li>
					<a href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.editSet&amp;subTypeID=#esapiEncode('url',rc.subTypeID)#&amp;siteid=#esapiEncode('url',rc.siteid)#&amp;extendSetID=">
						#rc.$.rbKey('sitemanager.extension.addattributeset')#
					</a>
				</li>
				<cfif showRelatedContentSets>
					<li>
						<a href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.editRelatedContentSet&amp;subTypeID=#esapiEncode('url',rc.subTypeID)#&amp;siteid=#esapiEncode('url',rc.siteid)#&amp;relatedContentSetID=">
							#rc.$.rbKey('sitemanager.extension.addrelatedcontentset')#
						</a>
					</li>
				</cfif>
			</ul>
		</div>
	</div>

</div> <!-- /.mura-header -->

<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">

	<h2>
		<i class="#subtype.getIconClass(includeDefault=true)# mi-lg"></i>
		#application.classExtensionManager.getTypeAsString(subType.getType())# / #subType.getSubType()#
	</h2>

	<h3>#rc.$.rbKey('sitemanager.extension.extendedattributesets')#</h3>

	<cfif arrayLen(extendSets) gt 1>
		<ul class="nav nav-pills">
			<li><a href="javascript:;" class="btn" style="display:none;" id="saveSort" onclick="extendManager.saveExtendSetSort('attr-set');return false;">
							<i class="mi-check"></i>
				#rc.$.rbKey('sitemanager.extension.saveorder')#
			</a></li>
			<li><a href="javascript:;" class="btn" id="showSort" onclick="extendManager.showSaveSort('attr-set');return false;">
				<i class="mi-arrows"></i>
				#rc.$.rbKey('sitemanager.extension.reorder')#
			</a>
			</li>
		</ul>
	</cfif>

	<cfif arrayLen(extendSets)>
		<ul id="attr-set" class="attr-list">
			<cfloop from="1" to="#arrayLen(extendSets)#" index="s">
				<cfset extendSetBean=extendSets[s]/>
				<li extendSetID="#extendSetBean.getExtendSetID()#">
								<span id="handle#s#" class="handle" style="display:none;"><i class="mi-arrows"></i></span>
					<p>#extendSetBean.getName()#</p>
					<div class="btns">
									<a title="#rc.$.rbKey('sitemanager.extension.edit')#" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.editAttributes&amp;subTypeID=#esapiEncode('url',rc.subTypeID)#&amp;extendSetID=#extendSetBean.getExtendSetID()#&amp;siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i></a>
									<a title="#rc.$.rbKey('sitemanager.extension.delete')#" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.updateSet&amp;action=delete&amp;subTypeID=#esapiEncode('url',rc.subTypeID)#&amp;extendSetID=#extendSetBean.getExtendSetID()#&amp;siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=extendSetBean.getExtendSetID(),format='url')#" onclick="return confirmDialog('Delete  #esapiEncode("javascript","'#extendSetBean.getname()#'")#?',this.href)"><i class="mi-trash"></i></a>
					</div>
				</li>
			</cfloop>
		</ul>
	<cfelse>
		<div class="help-block-empty">#rc.$.rbKey('sitemanager.extension.noattributesets')#</div>
	</cfif>

	<cfif showRelatedContentSets>
		<cfif arrayLen(relatedContentsets)>
			<hr />
			<h3>
				#rc.$.rbKey('sitemanager.extension.relatedcontentsets')#
				<cfif arrayLen(relatedContentsets) gt 1>
					(
						<a href="javascript:;" style="display:none;" id="saveRelatedSort" onclick="extendManager.saveRelatedSetSort('related-set');return false;">
										<i class="mi-check"></i>
							#rc.$.rbKey('sitemanager.extension.saveorder')#
						</a>
						<a href="javascript:;" id="showRelatedSort" onclick="extendManager.showRelatedSaveSort('related-set');return false;">
										<i class="mi-arrows"></i>
							#rc.$.rbKey('sitemanager.extension.reorder')#
						</a>
					)
				</cfif>
			</h3>
			<ul id="related-set" class="attr-list">
				<cfloop from="1" to="#arrayLen(relatedContentsets)#" index="s">
					<cfset rcsBean=relatedContentsets[s]/>
					<li relatedContentSetID="#rcsBean.getRelatedContentSetID()#">
									<span id="handleRelated#s#" class="handleRelated" style="display:none;"><i class="mi-arrows"></i></span>
						<p>#rcsBean.getName()#</p>
						<div class="btns">
										<a title="#rc.$.rbKey('sitemanager.extension.edit')#" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.editRelatedContentSet&amp;subTypeID=#esapiEncode('url',rc.subTypeID)#&amp;relatedContentSetID=#rcsBean.getRelatedContentSetID()#&amp;siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i></a>
										<a title="#rc.$.rbKey('sitemanager.extension.delete')#" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.updateRelatedContentSet&amp;action=delete&amp;subTypeID=#esapiEncode('url',rc.subTypeID)#&amp;relatedContentSetID=#rcsBean.getRelatedContentSetID()#&amp;siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=rcsBean.getRelatedContentSetID(),format='url')#" onclick="return confirmDialog('Delete  #esapiEncode("javascript","'#rcsBean.getname()#'")#?',this.href)"><i class="mi-trash"></i></a>
						</div>
					</li>
				</cfloop>
			</ul>
		<cfelse>
			<div class="help-block-empty">#rc.$.rbKey('sitemanager.extension.norelatedcontentsets')#</div>
		</cfif>
	</cfif>
			</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>
