<!--- license goes here --->
<cfoutput>
<div class="mura-header">
	<h1>#application.rbFactory.getKeyValue(session.rb,'collections.remotefeedimport')#</h1>
	<cfinclude template="dsp_secondary_menu.cfm">
	</div> <!-- /.mura-header -->

	<div class="block block-constrain">
			<div class="block block-bordered">
				<div class="block-content">

						<cfif not rc.theImport.success>
						<h2>#application.rbFactory.getKeyValue(session.rb,'collections.importfailed')#</h2>
						<p>#application.rbFactory.getKeyValue(session.rb,'collections.importfailedtext')#</p>
						<cfelse>
						<h2>#application.rbFactory.getKeyValue(session.rb,'collections.importsuccessful')#</h2>
						<cfset crumbdata=application.contentManager.getCrumbList(rc.theImport.parentBean.getcontentID(), rc.siteid)/>
						#$.dspZoom(crumbdata)#
						</cfif>

				<div class="clearfix"></div>
			</div> <!-- /.block-content -->
		</div> <!-- /.block-bordered -->
	</div> <!-- /.block-constrain -->
</cfoutput>