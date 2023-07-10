<!--- license goes here --->
<cfoutput>
	<cfset rslist=application.classExtensionManager.getSubTypes(siteID=rc.siteID,activeOnly=false) />

<div class="mura-header">
	<h1>#rc.$.rbKey('sitemanager.extension.classextensionmanager')#</h1>

	<div class="nav-module-specific btn-group">
		<a class="btn" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.editSubType&amp;subTypeID=&amp;siteid=#esapiEncode('url',rc.siteid)#">
					<i class="mi-plus-circle"></i>
			#rc.$.rbKey('sitemanager.extension.addclassextension')#
		</a>

		<!--- Actions --->
		<div class="btn-group">
			<a class="btn dropdown-toggle" data-toggle="dropdown" href="##">
						<i class="mi-cogs"></i>
				#rc.$.rbKey('sitemanager.extension.actions')#
				<span class="caret"></span>
			</a>
			<ul class="dropdown-menu">
				<cfif rslist.recordcount>
					<li>
						<a href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.exportSubType&amp;siteid=#esapiEncode('url',rc.siteid)#">
									<i class="mi-sign-out"></i>
							#rc.$.rbKey('sitemanager.extension.export')#
						</a>
					</li>
				</cfif>
				<li>
					<a href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.importSubTypes&amp;siteid=#esapiEncode('url',rc.siteid)#">
								<i class="mi-sign-in"></i>
						#rc.$.rbKey('sitemanager.extension.import')#
					</a>
				</li>
			</ul>
		</div>
		<!--- /Actions --->
	</div>

</div> <!-- /.mura-header -->
</cfoutput>

<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">
			<table class="mura-table-grid">

	<cfif rslist.recordcount>
	<tbody>

			<cfoutput>
				<thead>
					<tr>
						<th class="actions"></th>
						<th>
							#rc.$.rbKey('sitemanager.extension.icon')#
						</th>
						<th class="title">
							#rc.$.rbKey('sitemanager.extension.classextension')#
						</th>
						<th class="var-width">
							#rc.$.rbKey('sitemanager.extension.description')#
						</th>
						<th>
							#rc.$.rbKey('sitemanager.extension.active')#
						</th>
					</tr>
				</thead>
			</cfoutput>
			<cfoutput query="rslist">
				<tr>
					<td class="actions">
						<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
						<div class="actions-menu hide">
							<ul class="actions-list">
								<li class="edit">
									<a href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.editSubType&amp;subTypeID=#rslist.subTypeID#&amp;siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-pencil"></i>#rc.$.rbKey('sitemanager.extension.edit')#</a>
								</li>
								<li class="view-sets">
									<a href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.listSets&amp;subTypeID=#rslist.subTypeID#&amp;siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-list-alt"></i>#rc.$.rbKey('sitemanager.extension.viewsets')#</a>
								</li>
							</ul>
						</div>
					</td>
					<td class="selected-icon">
						<a href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.listSets&amp;subTypeID=#rslist.subTypeID#&amp;siteid=#esapiEncode('url',rc.siteid)#">
							<i class="#application.classExtensionManager.getIconClass(rslist.type,rslist.subtype,rslist.siteid)#" style="font-size:14px;"></i>
						</a>
					</td>
					<td class="title">
						<a title="#rc.$.rbKey('sitemanager.extension.edit')#" href="#rc.$.globalConfig('context')##rc.$.globalConfig('adminDir')#/?muraAction=cExtend.listSets&amp;subTypeID=#rslist.subTypeID#&amp;siteid=#esapiEncode('url',rc.siteid)#">
							#application.classExtensionManager.getTypeAsString(rslist.type)# / #rslist.subtype#
						</a>
					</td>
					<td class="var-width">
						#esapiEncode('html', rslist.description)#
					</td>
					<td>
						#YesNoFormat(rslist.isactive)#
					</td>
				</tr>
			</cfoutput>
		</tbody>
		</table>
		<cfelse>
			<div class="help-block-empty"><cfoutput>#rc.$.rbKey('sitemanager.extension.nosubtypes')#</cfoutput></div>
		</cfif>


			</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
