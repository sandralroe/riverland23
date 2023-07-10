<!--- license goes here --->
<cfset tabList=listAppend(tabList,"tabSchedule")>
<cfoutput>
<div class="mura-panel" id="tabSchedule">
	<div class="mura-panel-heading" role="tab" id="heading-schedule">
		<h4 class="mura-panel-title">
			<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-schedule" aria-expanded="true" aria-controls="panel-schedule">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.scheduling")# </a>
		</h4>
	</div>
	<div id="panel-schedule" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-schedule" aria-expanded="false" style="height: 0px;">
		<div class="mura-panel-body">

			<span id="extendset-container-tabscheduletop" class="extendset-container"></span>

			<!--- display yes/no/schedule --->
			<cfif ((rc.parentid neq '00000000000000000000000000000000001' and application.settingsManager.getSite(rc.siteid).getlocking() neq 'all') or (rc.parentid eq '00000000000000000000000000000000001' and application.settingsManager.getSite(rc.siteid).getlocking() eq 'none')) and rc.contentid neq '00000000000000000000000000000000001'>

				<cfinclude template="dsp_displaycontent.cfm">

			<cfelse>
				<cfif rc.type neq 'Component' and rc.type neq 'Form'>
					<input type="hidden" name="display" value="#rc.contentBean.getdisplay()#">
					<input type="hidden" name="displayStart" value="">
					<input type="hidden" name="displayStop" value="">
				<cfelse>
					<input type="hidden" name="display" value="1">
				</cfif>

			</cfif>
			<!--- /end display yes/no/schedule --->

			<span id="extendset-container-scheduling" class="extendset-container"></span>

			<span id="extendset-container-tabschedulebottom" class="extendset-container"></span>

		</div>
	</div>
</div>


</cfoutput>
