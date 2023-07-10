<!--- License goes here --->
<cfoutput>
<div class="mura-header">
	<h1>#rbKey('user.groupform')#</h1>
	<!--- Buttons --->
	<div class="nav-module-specific btn-group">
		<!--- Back --->
		<a class="btn" href="##" title="#esapiEncode('html',rbKey('sitemanager.back'))#" onclick="actionModal();window.history.back(); return false;">
					<i class="mi-arrow-circle-left"></i> 
			#esapiEncode('html',rbKey('sitemanager.back'))#
		</a>
		<!--- View All Groups --->
		<a class="btn" href="#buildURL(action='cusers.list')#" onclick="actionModal();">
					<i class="mi-users"></i>
			#rbKey('user.viewallgroups')#
		</a>
		<!--- Edit Group Settings --->
		<a class="btn" href="#buildURL(action='cusers.editgroup', querystring='userid=#rc.userid#&siteid=#esapiEncode('url',rc.siteid)#')#" onclick="actionModal();">
					<i class="mi-pencil"></i>
			#rbKey('user.editgroupsettings')#
		</a>
		<!--- Download Users --->
	    <cfif rc.it.hasNext()>
				<a class="btn" href="#buildURL(action='cusers.downloadgroupmembers', querystring='userid=#rc.userid#')#">
							<i class="mi-download"></i> 
					#rbKey('user.download')#
				</a>
	    </cfif>
	</div>

</div> <!-- /.mura-header -->

<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">

	<h2>
		<strong>#esapiEncode('html', rc.userBean.getgroupname())#</strong> #rbKey('user.users')#
	</h2>

	<cfinclude template="inc/dsp_users_list.cfm" />

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</cfoutput>