<!--- license goes here --->
<cfoutput>
<div class="mura-header">
	<h1>#rc.$.rbKey('sitemanager.content.importform')#</h1>

	<div class="nav-module-specific btn-group">
	</div>
</div> <!-- /.mura-header -->
</cfoutput>
<form novalidate="novalidate" action="?muraAction=cArch.importcomponent" method="post" enctype="multipart/form-data">

	<div class="block block-constrain" style="min-height: 1052px;">

		<!-- tab content -->
		<div class="block-content tab-content">

<div id="tabBasic" class="tab-pane active">

		<!-- block -->
	  <div class="block block-bordered">
	  	<!-- block header -->

		<div class="block-content">
			<span id="extendset-container-tabbasictop" class="extendset-container"></span>

			<div class="mura-control-group">
				<label>
				Title
				</label>
			<input type="text" id="title" name="title" maxlength="255" required="true" message="The 'Title' field is required">
			</div>

			<div class="mura-control-group">
				<label>
				Component To Import (Zip File)
				</label>
				<input type="file" id="componentzip" name="componentzip" message="The 'Title' field is required">
			</div>
		</div>
	</div>

	<div class="mura-actions">
		<div class="form-actions">

				<button type="submit" class="btn mura-primary">
						<i class="mi-check"></i>Import
				</button>

			</div>
		</div>


	</div><!-- /.block-constrain -->

	</form>
