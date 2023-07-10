<!--- license goes here --->
<cfset tabList=listAppend(tabList,"tabRemote")>
<cfoutput>
<div class="mura-panel" id="tabRemote">
	<div class="mura-panel-heading" role="tab" id="heading-remote">
		<h4 class="mura-panel-title">
			<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-remote" aria-expanded="false" aria-controls="panel-remote">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.remote")#</a>
		</h4>
	</div>
	<div id="panel-remote" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-remote" aria-expanded="false" style="height: 0px;">
		<div class="mura-panel-body">
			<span id="extendset-container-tabremotetop" class="extendset-container"></span>

				<!--- Remote Information --->
				<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remoteid')#</label>
					<input type="text" id="remoteID" name="remoteID" value="#rc.contentBean.getRemoteID()#"  maxlength="255">
					</div>

					<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remoteurl')#</label>
					<input type="text" id="remoteURL" name="remoteURL" value="#rc.contentBean.getRemoteURL()#"  maxlength="255">
					</div>

					<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotepublicationdate')#</label>
					<input type="text" id="remotePubDate" name="remotePubDate" value="#rc.contentBean.getRemotePubDate()#"  maxlength="255">
					</div>

					<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotesource')#</label>
					<input type="text" id="remoteSource" name="remoteSource" value="#rc.contentBean.getRemoteSource()#"  maxlength="255">
					</div>

					<div class="mura-control-group">
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.remotesourceurl')#</label>
					<input type="text" id="remoteSourceURL" name="remoteSourceURL" value="#rc.contentBean.getRemoteSourceURL()#"  maxlength="255">
					</div>
	
			<!--- /Remote Information --->

			<span id="extendset-container-remote" class="extendset-container"></span>
			<span id="extendset-container-tabremotebottom" class="extendset-container"></span>
		</div>
	</div>
</div> 
</cfoutput>
