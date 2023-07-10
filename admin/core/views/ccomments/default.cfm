<cfsilent>
<!--- License goes here --->
</cfsilent>
<style>
</style>
<script>
	$(document).ready(function(){
		commentManager.loadSearch('');
	});	
</script>
<cfoutput>
	

<div id="commentsManagerWrapper">

	<div class="mura-header">
		<h1>#rbKey('comments.commentsmanager')#</h1>

		<cfif listFind(session.mura.memberships,'Admin;#application.settingsManager.getSite(rc.siteid).getPrivateUserPoolID()#;0') or listFind(session.mura.memberships,'S2')>
			<div class="nav-module-specific btn-group">
					<cfif rc.$.globalConfig('purgecomments') and rc.$.currentUser().isSuperUser()>
								<a id="purge-comments" class="btn btn-default" data-alertmessage="#application.rbFactory.getKeyValue(session.rb,'comments.message.confirm.purge')#"><i class="mi-trash-o"></i> #application.rbFactory.getKeyValue(session.rb,'comments.purgedeletedcomments')#</a>
					</cfif>
								<a class="btn" href="./?muraAction=cPerm.module&contentid=00000000000000000000000000000000015&siteid=#esapiEncode('url',rc.siteid)#&moduleid=00000000000000000000000000000000015"><i class="mi-group"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.permissions')#</a>
			</div>
		</cfif>

	</div> <!-- /.mura-header -->
	
	<!--- MESSAGING --->
	<!--- uses alert-success, alert-error --->
	<cfif StructKeyExists(rc, 'processed') and IsBoolean(rc.processed)>
		<cfset local.class = rc.processed ? 'success' : 'error'>
		<div id="feedback" class="alert alert-#local.class#"><span>
			<button type="button" class="close" data-dismiss="alert"><i class="mi-close"></i></button>
			<cfif rc.processed>
				#rbKey('comments.message.confirmation')#
			<cfelse>
				#rbKey('comments.message.error')#
			</cfif>
		</span>
		</div>
	</cfif>

	<div class="block block-constrain">
		<div class="block block-bordered">
			<div class="block-content">


				<form id="frmSearch" action="index.cfm">
					<div class="tabs-left mura-ui full">
						<div class="tab-content">
							<div id="commentSearch"><!--- target for ajax ---></div>
						</div>
					</div>
				</form>

			</div> <!-- /.block-content -->
		</div> <!-- /.block-bordered -->
	</div> <!-- /.block-constrain -->

</div>
</cfoutput>