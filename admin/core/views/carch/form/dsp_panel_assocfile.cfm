<!--- license goes here --->
<cfif ListFindNoCase("Page,Folder,Calendar,Gallery,Link",rc.type)>
<cfset tabList=listAppend(tabList,"tabAssoc")>
<cfoutput>
<div class="mura-panel" id="tabAssoc">
	<div class="mura-panel-heading" role="tab" id="heading-assoc">
		<h4 class="mura-panel-title">
			<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-assoc" aria-expanded="true" aria-controls="panel-assoc">
				<cfif rc.ptype eq 'Gallery' or rc.type neq 'File'>
			  		#listLast(application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectimage'),' ')#
				<cfelse>
					#listLast(application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selectfile'),' ')#
				</cfif>
			</a>
		</h4>
	</div>
	<div id="panel-assoc" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-assoc" aria-expanded="false" style="height: 0px;">
		<div class="mura-panel-body">
			
				<span id="extendset-container-tabimagetop" class="extendset-container"></span>

				<!--- file/image selector --->				
				<cfinclude template="dsp_file_selector.cfm">

				<span id="extendset-container-image" class="extendset-container"></span>

				<span id="extendset-container-tabimagebottom" class="extendset-container"></span>

		</div>
	</div>
</div> 
</cfoutput>
</cfif>