<!--- license goes here --->

<cfset endpoint=rc.$.siteConfig().getApi('feed','v1').getEndpoint()>
<div class="mura-header">
	<cfoutput><h1>#application.rbFactory.getKeyValue(session.rb,'collections')#</h1>
	<cfinclude template="dsp_secondary_menu.cfm">
</div> <!-- /.mura-header -->



<div class="block block-constrain">
		<div class="block block-bordered">
		  <div class="block-content">
	<h2>#application.rbFactory.getKeyValue(session.rb,'collections.localcontentindexes')#</h2>
	<cfif rc.rsLocal.recordcount>
	<table class="mura-table-grid">
		<tr>
		<th class="actions"></th>
		<th class="var-width">#application.rbFactory.getKeyValue(session.rb,'collections.index')#</th>
		<th class="hidden-xs">#application.rbFactory.getKeyValue(session.rb,'collections.language')#</th>
		<th class="hidden-xs">#application.rbFactory.getKeyValue(session.rb,'collections.maxitems')#</th>
		<th>#application.rbFactory.getKeyValue(session.rb,'collections.featuresonly')#</th>
		<th>#application.rbFactory.getKeyValue(session.rb,'collections.restricted')#</th>
		<th>#application.rbFactory.getKeyValue(session.rb,'collections.active')#</th>
		</tr>
		<cfloop query="rc.rsLocal">
		<tr>
			<td class="actions">
					<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
					<div class="actions-menu hide">
					<ul class="actions-list">
						<li class="edit"><a href="./?muraAction=cFeed.edit&feedID=#rc.rsLocal.feedID#&siteid=#esapiEncode('url',rc.siteid)#&type=Local"><i class="mi-pencil"></i>#application.rbFactory.getKeyValue(session.rb,'collections.edit')#</a></li>
						<li class="rss"><a href="#endpoint#/?feedID=#rc.rslocal.feedid#" target="_blank"><i class="mi-rss"></i>#application.rbFactory.getKeyValue(session.rb,'collections.viewrss')#</a></li>
						<li class="delete"><a href="./?muraAction=cFeed.update&action=delete&feedID=#rc.rsLocal.feedID#&siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=rc.rslocal.feedid,format='url')#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'collections.deletelocalconfirm'))#',this.href)"><i class="mi-trash"></i>#application.rbFactory.getKeyValue(session.rb,'collections.delete')#</a></li>
					</ul>
				</div>
			</td>
			<td class="var-width"><a title="Edit" href="./?muraAction=cFeed.edit&feedID=#rc.rsLocal.feedID#&siteid=#esapiEncode('url',rc.siteid)#&type=Local">#rc.rsLocal.name#</a></td>
			<td class="hidden-xs">#rc.rsLocal.lang#</td>
			<td class="hidden-xs">#rc.rsLocal.maxItems#</td>
			<td>
				<cfif rc.rsLocal.isFeaturesOnly>
								<i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,'collections.#yesnoFormat(rc.rsLocal.isFeaturesOnly)#')#"></i>
				<cfelse>
								<i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,'collections.#yesnoFormat(rc.rsLocal.isFeaturesOnly)#')#"></i>
				</cfif>
				<span>#application.rbFactory.getKeyValue(session.rb,'collections.#yesnoFormat(rc.rsLocal.isFeaturesOnly)#')#</span>
			</td>
			<td>
				<cfif rc.rsLocal.restricted>
								<i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,'collections.#yesnoFormat(rc.rsLocal.restricted)#')#"></i>
				<cfelse>
								<i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,'collections.#yesnoFormat(rc.rsLocal.restricted)#')#"></i>
				</cfif>
				<span>#application.rbFactory.getKeyValue(session.rb,'collections.#yesnoFormat(rc.rsLocal.restricted)#')#</span>
			</td>
			<td>
			<cfif rc.rsLocal.isActive>
								<i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,'collections.#yesnoFormat(rc.rsLocal.isActive)#')#"></i>
				<cfelse>
								<i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,'collections.#yesnoFormat(rc.rsLocal.isActive)#')#"></i>
				</cfif>
				<span>#application.rbFactory.getKeyValue(session.rb,'collections.#yesnoFormat(rc.rsLocal.isActive)#')#</span>
			</td>
		</tr></cfloop>
	</table>
	<cfelse>
		<div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,'collections.nolocalindexes')#</div>
	</cfif>
	</div><!-- /.block-content -->

			<div class="block-content">
	<h2>#application.rbFactory.getKeyValue(session.rb,'collections.remotecontentfeeds')#</h2>
	<cfif rc.rsRemote.recordcount>
	<table class="mura-table-grid">
	<tr>
	<th class="actions"></th>
	<th class="var-width">#application.rbFactory.getKeyValue(session.rb,'collections.feed')#</th>
	<th class="url var-width">#application.rbFactory.getKeyValue(session.rb,'collections.url')#</th>
	<th>#application.rbFactory.getKeyValue(session.rb,'collections.active')#</th>
	</tr>
	<cfloop query="rc.rsRemote">
	<tr>
		<td class="actions">
			<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
			<div class="actions-menu hide">
			<ul class="actions-list">
				<li class="edit"><a href="./?muraAction=cFeed.edit&feedID=#rc.rsRemote.feedID#&siteid=#esapiEncode('url',rc.siteid)#&type=Remote"><i class="mi-pencil"></i>#application.rbFactory.getKeyValue(session.rb,'collections.edit')#</a></li>
				<li class="rss"><a href="#rc.rsRemote.channelLink#" target="_blank"><i class="mi-rss"></i>#application.rbFactory.getKeyValue(session.rb,'collections.viewfeed')#</a></li>
				<li class="import"><a href="./?muraAction=cFeed.import1&feedID=#rc.rsRemote.feedID#&siteid=#esapiEncode('url',rc.siteid)#"><i class="mi-sign-in"></i>#application.rbFactory.getKeyValue(session.rb,'collections.import')#</a></li>			
				<li class="delete"><a href="./?muraAction=cFeed.update&action=delete&feedID=#rc.rsRemote.feedID#&siteid=#esapiEncode('url',rc.siteid)##rc.$.renderCSRFTokens(context=rc.rsremote.feedid,format='url')#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'collections.deleteremoteconfirm'))#',this.href)"><i class="mi-trash"></i>#application.rbFactory.getKeyValue(session.rb,'collections.delete')#</a></li>
		</ul>
		</div>
		</td>
		<td class="var-width"><a title="#application.rbFactory.getKeyValue(session.rb,'collections.edit')#" href="./?muraAction=cFeed.edit&feedID=#rc.rsRemote.feedID#&siteid=#esapiEncode('url',rc.siteid)#&type=Remote">#rc.rsRemote.name#</a></td>
		<td class="url var-width">#left(rc.rsRemote.channelLink,70)#</td>
		<td>#yesnoFormat(rc.rsRemote.isactive)#</td>
	</tr></cfloop>
	</table>
	<cfelse>
		<div class="help-block-empty">#application.rbFactory.getKeyValue(session.rb,'collections.noremotefeeds')#</div>
	</cfif>
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->

</cfoutput>
