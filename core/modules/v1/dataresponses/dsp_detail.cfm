<!--- License goes here --->
<cfsilent>
	<cfset variables.rsData=application.dataCollectionManager.read($.event('responseid'))/>
	<cfif Left(variables.formBean.getValue('ResponseDisplayFields'), 1) neq '~'>
		<cfset variables.fieldnames=Replace(ListFirst(variables.formBean.getValue('ResponseDisplayFields'),"~"),"^",",","ALL")/>
	<cfelse>
		<cfset variables.fieldnames=application.dataCollectionManager.getCurrentFieldList(variables.formBean.getValue('contentID'))/>
	</cfif>
</cfsilent>
<cfif variables.rsData.recordcount>
	<cfsilent>
		<cfwddx action="wddx2cfml" input="#variables.rsData.data#" output="variables.info">
	</cfsilent>
	<cfoutput>
		<div id="dsp_detail" class="dataResponses">
			<#variables.$.getHeaderTag('subHead2')#>
				#HTMLEditFormat(variables.formBean.getValue('title'))# #variables.$.rbKey('form.dataresponses.response')#
			</#variables.$.getHeaderTag('subHead2')#>
			<a class="actionItem" href="##" onclick="history.go(-1); return false;">#variables.$.rbKey('form.dataresponses.returntolist')#</a>
			<dl class="#this.dataResponseListClass#">
				<cfloop list="#variables.fieldnames#" index="variables.f">
					<cftry>
						<cfset variables.fValue=variables.info['#variables.f#']>
						<cfcatch>
							<cfset variables.fValue="">
						</cfcatch>
					</cftry>
					<dt>#HTMLEditFormat(variables.f)#</dt>
					<dd>
						<cfif findNoCase('attachment',variables.f) and isValid("UUID",fvalue)>
							<a  href="http://#application.settingsManager.getSite(session.siteid).getDomain()##application.configBean.getServerPort()##application.configBean.getContext()##application.configBean.getIndexPath()#/_api/render/file/?fileID=#variables.fvalue#">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.viewattachment')#</a>
						<cfelse>
							#variables.$.setParagraphs(htmleditformat(variables.fvalue))#
						</cfif>
					</dd>
				</cfloop>
			</dl>
		</div>
	</cfoutput>
<cfelse>
	<div class="alert alert-info">
		#variables.$.rbKey('form.dataresponses.recordnotfound')#
	</div>
</cfif>