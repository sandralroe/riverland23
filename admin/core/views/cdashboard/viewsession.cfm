 <!--- license goes here --->
<cfoutput>

<div class="mura-header">
		<h1>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.sessionhistory")#</h1>
		<cfinclude template="dsp_secondary_menu.cfm">
</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

			<cfsilent>
			<cfset lastAccessed=application.dashboardManager.getLastSessionDate(rc.rslist.urlToken,rc.rslist.originalUrlToken,rc.rslist.entered) />
			</cfsilent>

			<ul class="metadata">
			<li><strong>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.user")#:</strong> #esapiEncode('html',application.dashboardManager.getUserFromSessionQuery(rc.rslist))#</li>
			<li><strong>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.lastaccessed")#:</strong> <cfif LSisDate(lastAccessed)>#LSDateFormat(lastAccessed,session.dateKeyFormat)#<cfelse>Not Available</cfif></li>
			<cfif LSisDate(lastAccessed)><li><strong>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.timebetweenvisit")#:</strong> #application.dashboardManager.getTimespan(lastAccessed,rc.rslist.entered,"long")#</li></cfif> 
			<li><strong>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.lengthofvisit")#:</strong> #application.dashboardManager.getTimespan(rc.rslist.entered[rc.rslist.recordcount],rc.rslist.entered[1])#</li>
			<li><strong>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.useragent")#:</strong> #esapiEncode('html',application.dashboardManager.getUserAgentFromSessionQuery(rc.rslist))#
			</li>
			<cfset $.event('originalUrlToken',rc.rslist.originalUrlToken)>
			#$.renderEvent('onSessionMetaDataRender')#
			</ul>

			<table class="mura-table-grid"> 
			<tr>
				<th class="actions"></th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.user")#</th>
				<th class="var-width">#application.rbFactory.getKeyValue(session.rb,"dashboard.session.content")#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.requesttime")#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.keywords")#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.locale")#</th>
			</tr>
			<cfloop query="rc.rslist">
			<cfset crumbdata=application.contentManager.getCrumbList(rc.rslist.contentid, rc.siteid)/>
			<tr>
				<td class="actions">
					<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
					<div class="actions-menu hide">	
						<ul class="actions-list">
							<li class="preview">
								<a href="##" onclick="return preview('#application.settingsManager.getSite(rc.siteid).getWebPath(complete=1)##$.getURLStem(rc.siteid,rc.rsList.filename)#');"><i class="mi-globe"></i>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.view")#</a>
							</li>
						</ul>
					</div>	
				</td>
				<td><cfif rc.rslist.fname eq ''>Anonymous<cfelse>#esapiEncode('html',rc.rslist.fname)# #esapiEncode('html',rc.rslist.lname)#<cfif rc.rslist.company neq ''> (#esapiEncode('html',rc.rslist.company)#)</cfif></cfif></td>
				<td class="var-width">#$.dspZoom(crumbdata)#</td>

				<td>#LSDateFormat(rc.rslist.entered,session.dateKeyFormat)# #LSTimeFormat(rc.rslist.entered,"short")#</td>
				<td><cfif rc.rslist.keywords neq ''>#esapiEncode('html',rc.rslist.keywords)#<cfelse>&mdash;</cfif></td>
				<td>#esapiEncode('html',rc.rslist.locale)#</td>
			</tr></cfloop>

			</table>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>

