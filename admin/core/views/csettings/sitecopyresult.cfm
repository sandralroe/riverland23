 <!--- license goes here --->
<cfoutput>
<div class="mura-header">
	<h1>Copy Site</h1>
</div>

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">
			<div class="help-block">The contents of the site '<strong>#application.settingsManager.getSite(rc.fromsiteid).getSite()#</strong>' have been copied into '<strong>#application.settingsManager.getSite(rc.tositeid).getSite()#</strong>'.</div>

			<div class="clearfix"></div>
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->						

</cfoutput>