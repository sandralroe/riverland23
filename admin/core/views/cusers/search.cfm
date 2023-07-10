<!--- License goes here --->
<cfoutput>
	<!--- Page Title --->
<div class="mura-header">
	<h1>#rc.isGroupSearch ? rbkey("user.groupsearchresults") : rbKey('user.usersearchresults')#</h1>

	<!--- Buttons --->
		<div class="nav-module-specific btn-group">

			<!--- Add User --->
				<a class="btn" href="#buildURL(action='cusers.edituser', querystring='siteid=#esapiEncode('url',rc.siteid)#&userid=')#">
					<i class="mi-plus-circle"></i> 
					#rbKey('user.adduser')#
				</a>

		  <!--- Add Group --->
				<a class="btn" href="#buildURL(action='cusers.editgroup', querystring='siteid=#esapiEncode('url',rc.siteid)#&userid=')#">
					<i class="mi-plus-circle"></i> 
					#rbKey('user.addgroup')#
				</a>

			<!--- View Groups --->
				<a class="btn" href="#buildURL(action='cusers.default', querystring='siteid=#esapiEncode('url',rc.siteid)#')#">
					<i class="mi-users"></i>
					#rbKey('user.viewgroups')#
				</a>

			<!--- View Users --->
				<a class="btn" href="#buildURL(action='cusers.listUsers', querystring='siteid=#esapiEncode('url',rc.siteid)#')#">
					<i class="mi-user"></i>
					#rbKey('user.viewusers')#
				</a>

		</div>
	<!--- /Buttons --->

	<div class="mura-item-metadata">

	<!--- User Search --->
	<cfinclude template="inc/dsp_search_form.cfm" />

	</div><!-- /.mura-item-metadata -->
</div> <!-- /.mura-header -->

<div class="block block-constrain">

<!--- Tab Nav (only tabbed for Admin + Super Users) --->
<cfif rc.isAdmin>
  	<ul class="mura-tab-links nav-tabs">
		<!--- Site Members Tab --->
		<li<cfif rc.ispublic eq 1> class="active"</cfif>>
			<cfif rc.isGroupSearch>
				<a href="#buildURL(action='cusers.search', querystring='siteid=#esapiEncode('url',rc.siteid)#&ispublic=1&isGroupSearch=true&search=#esapiEncode('url',rc.search)#')#">
					#rbKey('user.membergroups')# <span id="sitemembers-count"></span>
				</a>
			<cfelse>
				<a href="#buildURL(action='cusers.search', querystring='siteid=#esapiEncode('url',rc.siteid)#&ispublic=1&isGroupSearch=false&search=#esapiEncode('url',rc.search)#')#">
					#rbKey('user.sitemembers')# <span id="sitemembers-count"></span>
				</a>
			</cfif>
        </li>
		 <!--- System Users Tab --->
		<li<cfif rc.ispublic eq 0> class="active"</cfif>>
			<cfif rc.isGroupSearch>
				<a href="#buildURL(action='cusers.search', querystring='siteid=#esapiEncode('url',rc.siteid)#&ispublic=0&isGroupSearch=true&search=#esapiEncode('url',rc.search)#&clicked')#">
					#rbKey('user.systemgroups')# <span id="systemusers-count"></span>
				</a>
			<cfelse>
				<a href="#buildURL(action='cusers.search', querystring='siteid=#esapiEncode('url',rc.siteid)#&ispublic=0&isGroupSearch=false&search=#esapiEncode('url',rc.search)#&clicked')#">
					#rbKey('user.systemusers')# <span id="systemusers-count"></span>
				</a>
			</cfif>
        </li>
    </ul>
	<div class="block-content tab-content">
		<!-- start tab -->
		<div id="tab1" class="tab-pane active">
			<div class="block block-bordered">
				<!-- block header -->					
				<div class="block-header">
					<h3 class="block-title"><cfif rc.ispublic eq 1>#rbKey('user.sitemembers')#<cfelseif rc.isGroupSearch>#rbKey('user.systemgroups')#<cfelse>#rbKey('user.systemusers')#</cfif></h3>
				</div> <!-- /.block header -->						
				<div class="block-content">
					<cfinclude template="inc/dsp_users_list.cfm" />
				</div> <!-- /.block-content -->
			</div> <!-- /.block-bordered -->
		</div> <!-- /.tab-pane -->

	</div> <!-- /.block-content.tab-content -->
<cfelse>
	<div class="block block-bordered">
		<div class="block-content">
			<h3>#rbKey('user.sitemembers')#</h3>
			<cfinclude template="inc/dsp_users_list.cfm" />
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</cfif>
<!--- /Tab Nav --->


</div> <!-- /.block-constrain -->

<script>
	var searchInput=document.getElementById('search');
	var search =(searchInput)? searchInput.value : '';
	var systemUsers = 0;
	var siteMembers = 0;
	$.get('..#application.configBean.getAdminDir()#/?muraAction=cUsers.remoteSearch&ispublic=0&search='+search+'&siteid=#esapiEncode("javascript", session.siteid)#', function(data) {
		systemUsers = parseInt(data.trim());
		$.get('..#application.configBean.getAdminDir()#/?muraAction=cUsers.remoteSearch&ispublic=1&search='+search+'&siteid=#esapiEncode("javascript", session.siteid)#', function(data) {
			siteMembers = parseInt(data.trim());
			processTabs(systemUsers,siteMembers);
		});
	});
	function processTabs(systemUsers,siteMembers) {
		$('##systemusers-count').text('(' + systemUsers + ')');
		$('##sitemembers-count') .text('(' + siteMembers + ')');
	}
</script>
</cfoutput>