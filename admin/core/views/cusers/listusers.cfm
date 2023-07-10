<!--- License goes here --->
<cfoutput>

	<!--- Header --->
		<cfinclude template="inc/dsp_users_header.cfm" />

	<div class="block block-constrain">

	<!--- Tab Nav (only tabbed for Admin + Super Users) --->
    <cfif rc.isAdmin>
		<ul id="viewTabs" class="mura-tab-links nav-tabs">
          
          <!--- Site Members Tab --->
          <li<cfif rc.ispublic eq 1> class="active"</cfif>>
            <a href="#buildURL(action='cusers.listusers', querystring='siteid=#esapiEncode('url',rc.siteid)#&ispublic=1&unassigned=#esapiEncode('url',rc.unassigned)#')#" onclick="actionModal();">
              #rbKey('user.sitemembers')# <span id="sitemembers-count"></span>
            </a>
          </li>
		  <!--- System Users Tab --->
          <li<cfif rc.ispublic eq 0> class="active"</cfif>>
            <a href="#buildURL(action='cusers.listusers', querystring='siteid=#esapiEncode('url',rc.siteid)#&ispublic=0&unassigned=#esapiEncode('url',rc.unassigned)#&clicked')#" onclick="actionModal();">
              #rbKey('user.systemusers')# <span id="systemusers-count"></span>
            </a>
          </li>
        </ul>
    <cfelse>
      <h3>#rbKey('user.sitemembers')#</h3>
    </cfif>
  <!--- /Tab Nav --->

  <div class="block-content tab-content">

		<!-- start tab -->
		<div id="tab1" class="tab-pane active">

			<div class="block block-bordered">
				<!-- block header -->
				<div class="block-header">
						<h3 class="block-title">#rbKey('user.users')#</h3>
				</div> <!-- /.block header -->
				<div class="block-content">

	<!--- Filters --->
		<div class="mura-control-group">

			<!--- View All / Unassigned Only --->
				<a class="btn" href="#buildURL(action='cusers.listusers', querystring='siteid=#esapiEncode('url',rc.siteid)#&ispublic=#esapiEncode('url',rc.ispublic)#&unassigned=#esapiEncode('url',rc.unassigned)?0:1#')#" onclick="actionModal();">
					<i class="mi-filter"></i>
					<cfif rc.unassigned EQ 0>
						#rbKey('user.viewunassignedonly')#
					<cfelse>
						#rbKey('user.viewall')#
					</cfif>
				</a>

			<!--- Download .CSV --->
        <cfif rc.it.hasNext()>
  				<a class="btn" href="#buildURL(action='cusers.download', querystring='siteid=#esapiEncode('url',rc.siteid)#&ispublic=#esapiEncode('url',rc.ispublic)#&unassigned=#esapiEncode('url',rc.unassigned)#')#">
			  		<i class="mi-download"></i>
  					#rbKey('user.download')#
  				</a>
        </cfif>

		</div>
	<!--- /Filters --->

	<!--- Users List --->
		<cfinclude template="inc/dsp_users_list.cfm" />

				</div> <!-- /.block-content -->
			</div> <!-- /.block-bordered -->
		</div> <!-- /.tab-pane -->


	</div> <!-- /.block-content.tab-content -->
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
