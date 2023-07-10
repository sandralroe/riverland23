<!--- License goes here --->
<cfoutput>

	<!--- User Search --->		
<div class="mura-header">
	<h1>#rbKey('user.groupsandusers')#</h1>
<!--- Buttons --->
	<div class="nav-module-specific btn-group">

		<!--- Add User --->
			<a class="btn" href="#buildURL(action='cusers.edituser', querystring='siteid=#esapiEncode('url',rc.siteid)#&userid=')#" onclick="actionModal();">
				<i class="mi-plus-circle"></i> 
				#rbKey('user.adduser')#
			</a>

	  <!--- Add Group --->
			<a class="btn" href="#buildURL(action='cusers.editgroup', querystring='siteid=#esapiEncode('url',rc.siteid)#&userid=')#" onclick="actionModal();">
				<i class="mi-plus-circle"></i> 
				#rbKey('user.addgroup')#
			</a>

		<cfif rc.muraaction eq 'core:cusers.listusers'>

			<!--- View Groups --->
				<a class="btn" href="#buildURL(action='cusers.default', querystring='siteid=#esapiEncode('url',rc.siteid)#')#" onclick="actionModal();">
					<i class="mi-group"></i>
					#rbKey('user.viewgroups')#
				</a>

	  <cfelse>

			<!--- View Users --->
				<a class="btn" href="#buildURL(action='cusers.listUsers', querystring='siteid=#esapiEncode('url',rc.siteid)#')#" onclick="actionModal();">
					<i class="mi-user"></i>
					#rbKey('user.viewusers')#
				</a>

		</cfif>

		<!--- Permissions --->
			<cfif rc.isAdmin>
				<a class="btn" href="./?muraAction=cPerm.leveledmodule&amp;contentid=00000000000000000000000000000000008&amp;siteid=#esapiEncode('url',rc.siteid)#&amp;moduleid=00000000000000000000000000000000008" onclick="actionModal();">
					<i class="mi-group"></i> 
					#rbKey('user.permissions')#
				</a>
			</cfif>
		</div>

	<div class="mura-item-metadata">
		<cfinclude template="dsp_search_form.cfm" />
	</div><!-- /.mura-item-metadata -->
</div> <!-- /.mura-header -->

</cfoutput>