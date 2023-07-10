<cfoutput>
<cfif len( trim( message ) )>
	<p class="alert alert-error">#message#</p>
</cfif>

<div class="js-wizard-simple block">

	<ul class="nav nav-tabs nav-justified">
		<li class="active">
			<a href="##tab-database" data-toggle="tab">1. Database</a>
		</li>
		<li>
			<a href="##tab-admin" data-toggle="tab">2. Admin</a>
		</li>
		<li>
			<a href="##tab-options" data-toggle="tab">3. Options</a>
		</li>
	</ul><!-- /.nav-tabs -->

	<form class="form-horizontal" action="index.cfm" method="post">
		<input type="hidden" name="action" value="doSetup" />

		<!-- Progress Bar -->
		<div class="wizard-progress progress progress-mini">
			<div class="progress-bar progress-bar-danger" role="progressbar" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100" style="width: 0"></div>
		</div>
		<!-- /Progress Bar -->


		<!-- Tab Content -->
		<div class="block-content tab-content">

			<!--- TAB-DATABASE --->
			<div class="tab-pane in active" id="tab-database">
					<p class="help-block"><strong>Step 1:</strong> Select the database type to be used, and provide the datasource connection information.</p>

					<div class="mura-control-group">
						<label></label>
						<select name	="production_dbtype"
								id		="production_dbtype" >
							<option value="" <cfif !len(trim(FORM.production_dbtype))>selected</cfif>>Select Database Type...</option>
							<option value="mysql" <cfif FORM.production_dbtype IS "mysql">selected</cfif>>MySQL</option>
							<option value="mssql" <cfif FORM.production_dbtype IS "mssql">selected</cfif>>MSSQL</option>
							<option value="nuodb" <cfif FORM.production_dbtype IS "nuodb">selected</cfif>>NuoDB</option>
							<option value="oracle" <cfif FORM.production_dbtype IS "oracle">selected</cfif>>Oracle</option>
							<option value="postgresql" <cfif FORM.production_dbtype IS "postgresql">selected</cfif>>PostgreSQL</option>
							</select>
					</div>

					<div class="mura-control-group database-config" >
						<label class="css-input switch switch-sm switch-primary">
							<input type="checkbox" id="auto_create" name="auto_create" value="1"
							<cfif len(trim(form.auto_create)) and val(form.auto_create)>checked</cfif>
							><span></span> <label>Create a new database</label>

								<span data-toggle="popover" title="" data-placement="right"
								  	data-content="If your database already exists, leave this turned off and enter the datasource connection details. To create a new database on the server, turn this option on and complete the required information."
								  	data-original-title="Create a new database"> <i class="mi-question-circle"></i> </span>

						</label>
					</div>

					<div class="mura-control-group database-create-yes">
						<label>#theCFServer# Password</label>
						<input type="password" name="production_cfpassword" value="#FORM.production_cfpassword#" />
						<p class="help-block">Required to create database.</p>
					</div>

					<div class="mura-control-group database-create-yes">
						<label>Database Server</label>
						<input type="text" name="production_databaseserver" value="#FORM.production_databaseserver#" />
					</div>

					<div class="mura-control-group database-create-oracle">
						<label>Oracle Tablespace</label>
						<input type="text" name="production_dbtablespace" value="#FORM.production_dbtablespace#" />
					</div>

					<div class="mura-control-group database-config">
						<label>Datasource Name</label>
						<input type="text" name="production_datasource" value="#FORM.production_datasource#" />
					</div>

					<div class="mura-control-group database-config">
						<label>Database Username</label>
						<input type="text" name="production_dbusername" value="#FORM.production_dbusername#" />
						<p class="help-block database-create-no">Optional if already configured in #theCFServer# admin.</p>
						<p class="help-block database-create-yes">Required to create database.</p>
					</div>

					<div class="mura-control-group database-config">
						<label>Database Password</label>
						<input type="password" name="production_dbpassword" value="#FORM.production_dbpassword#" />
						<p class="help-block database-create-no">Optional if already configured in #theCFServer# admin.</p>
						<p class="help-block database-create-yes">Required to create database.</p>
					</div>

			</div>
			<!--- /TAB-DATABASE --->

			<!-- TAB-ADMIN -->
			<div class="tab-pane" id="tab-admin">

					<p class="help-block"><strong>Step 2:</strong> Enter credentials for the "Super Admin" administrative user account.
					</p>

					<div class="mura-control-group">
						<label>Super Admin Username <span data-toggle="popover" title="" data-placement="right" data-content="This creates a master user account with full access to all Mura features. The password may be changed in the admin area once the site setup is complete. Additional users with various levels of access may also be added from within the Mura administration area. Be sure to use a strong, secure password." data-original-title="Super Admin Username"> <i class="mi-question-circle"></i> </span></label>
						<input type="text" name="admin_username" value="#FORM.admin_username#" />
					</div>

					<div class="mura-control-group">
						<label>Super Admin Password</label>
						<input type="password" name="admin_password" value="#FORM.admin_password#" />
					</div>
					<div class="mura-control-group">
						<label>Super Admin Email</label>
						<input type="text" name="production_adminemail" value="#FORM.production_adminemail#" />
						<p class="help-block">Required: Enter a valid email address.</p>
					</div>

			</div>
			<!-- /TAB-ADMIN -->

			<!-- TAB-OPTIONS -->
			<div class="tab-pane" id="tab-options">

					<p class="help-block"><strong>Step 3:</strong> Select whether "index.cfm" and the Site ID should appear in Mura's navigation links
					</p>

					<div class="mura-control-group" >

						<label class="css-input switch switch-sm switch-primary">
							<input type="checkbox" id="production_siteidinurls" name="production_siteidinurls" value="true" class="build-url-example"
							<cfif val(form.production_siteidinurls)>checked</cfif>
							><span></span> <label>Use /SiteID/ in navigation links</label>
								<span data-toggle="popover" title="" data-placement="right" data-content="If enabled, navigation links and content menus generated by Mura will include the siteid string. (See example url below.) To use Mura with this setting turned off, include the appropriate rewriting rule in a web.config or .htaccess file." data-original-title="Site ID in navigation links"> <i class="mi-question-circle"></i> </span>

						</label>

						<label class="css-input switch switch-sm switch-primary">
							<input type="checkbox" checked="true" id="production_indexfileinurls" name="production_indexfileinurls" value="true" class="build-url-example"
							<cfif val(form.production_indexfileinurls)>checked</cfif>>
							<span></span> <label>Use /index.cfm/ in navigation links</label>
									<span data-toggle="popover" title="" data-placement="right" data-content="If enabled, navigation links and content menus generated by Mura will include the index.cfm filename. (See example url below.) To use Mura with this setting turned off, include the appropriate rewriting rule in a web.config or .htaccess file." data-original-title="index.cfm in navigation links"> <i class="mi-question-circle"></i> </span>
						</label>

					</div>

					<p class="help-block">Example:<br><span id="url_example"><#context#/index.cfm/[siteid]?</span></p>

			</div>
			<!-- /TAB-OPTIONS -->

		</div>
		<!-- END Steps Content -->

		<div class="mura-focus-actions center">

					<button class="wizard-prev btn" type="button"><i class="mi mi-angle-left"></i>Back</button>
					<button class="wizard-next btn" type="button">Next<i class="mi mi-angle-right"></i></button>
					<button class="wizard-finish btn" name="setupSubmitButton" type="submit"><i class="mi mi-check"></i> Submit</button>
		</div>
		<div class="clear-both"></div>

		<input type="hidden" name="production_encryptionkey" value="#FORM.production_encryptionkey#" />
	</form><!-- END Form -->
</div>
<!-- END Simple Classic Progress Wizard -->

<script src="#context#/core/setup/js/jquery.bootstrap.wizard.min.js"></script>
<script src="#context#/core/setup/js/jquery.validate.min.js"></script>
<script src="#context#/core/setup/js/base_forms_wizard.js"></script>

<script type="text/javascript" language="javascript">
dtLocale='';
activetab=1;
activepanel=0;
jQuery(document).ready(function(){

	// show DB options on db type select
	$(".database-config").toggle(<cfif len(trim(FORM.production_dbtype)) gt 0>true<cfelse>false</cfif>);
	$('##production_dbtype').on('change',function(){
		$(".database-config").toggle(this.value.length > 0);
		$(".database-create-oracle").toggle($('##production_dbtype option:selected').val() == 'oracle' && $('##auto_create').is(':checked'));
	});

	// existing database y/n
	$(".database-create-yes").toggle(<cfif FORM.auto_create eq 1>true<cfelse>false</cfif>);
	$(".database-create-no").toggle(<cfif FORM.auto_create eq 0>true<cfelse>false</cfif>);
	$(".database-create-oracle").toggle(<cfif FORM.production_dbtype eq 'oracle' and val(FORM.auto_create) eq 1>true<cfelse>false</cfif>);
	$('##auto_create').on('change',function(){
		$(".database-create-yes").toggle(this.checked);
		$(".database-create-no").toggle(!this.checked);
		$(".database-create-oracle").toggle($('##production_dbtype option:selected').val() == 'oracle' && $('##auto_create').is(':checked'));
	});

	// example URL
	$('.build-url-example').on('change',function(){
		var ret = 'domain.com#context#';

		if ($("##production_indexfileinurls").is(':checked')) {
			ret = ret + '/index.cfm';
		}

		if ($("##production_siteidinurls").is(':checked')) {
			ret = ret + '/[siteid]';
		}
		
		ret = ret + '/folder/page/';
		$("##url_example").html(ret);
	});
	// show example URL on page load
	$('.build-url-example').change();

});
</script>
</cfoutput>
