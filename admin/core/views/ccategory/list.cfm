<!--- license goes here --->
<cfset event=request.event>
<cfinclude template="js.cfm">
<cfoutput>

	<div class="mura-header">
		<h1>#application.rbFactory.getKeyValue(session.rb,"categorymanager")#</h1>

		<cfinclude template="dsp_secondary_menu.cfm">
	</div> <!-- /.mura-header -->

	<div class="block block-constrain">
			<div class="block block-bordered">
				<div class="block-content">
						<cf_dsp_nest siteID="#rc.siteID#" parentID="" nestLevel="0" muraScope="#rc.$#">
				<div class="clearfix"></div>
			</div> <!-- /.block-content -->
		</div> <!-- /.block-bordered -->
	</div> <!-- /.block-constrain -->

</cfoutput>
