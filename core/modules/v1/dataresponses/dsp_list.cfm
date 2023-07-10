<!--- License goes here --->
<cfsilent>
	<cfset variables.data.sortby=variables.formBean.getValue('sortBy')/>
	<cfset variables.data.sortDirection=variables.formBean.getValue('sortDirection')/>
	<cfset variables.data.siteid=variables.formBean.getValue('siteID')/>
	<cfset variables.data.contentid=variables.formBean.getValue('contentID')/>
	<cfset variables.data.keywords=request.keywords />
	<cfif Right(variables.formBean.getValue('ResponseDisplayFields'), 1) neq '~'>
		<cfset variables.data.fieldnames=Replace(ListLast(variables.formBean.getValue('ResponseDisplayFields'),"~"),"^",",","ALL")/>
	<cfelse>
		<cfset variables.data.fieldnames=application.dataCollectionManager.getCurrentFieldList(variables.data.contentid)/>
	</cfif>
	<cfset variables.rsdata=application.dataCollectionManager.getdata(variables.data)/>
</cfsilent>
<div id="dsp_list" class="dataResponses">
	<cfif variables.rsdata.recordcount and ListLen(variables.data.fieldnames)>
		<cfsilent>
			<cfset variables.nextN=variables.$.getBean('utility').getnextN(variables.rsdata,variables.formBean.getValue('nextN'),request.StartRow)>
		</cfsilent>
		<cfoutput>
			<#variables.$.getHeaderTag('subHead2')#>
				#HTMLEditFormat(variables.formBean.getValue('title'))# #variables.$.rbKey('form.dataresponses.responses')#
			</#variables.$.getHeaderTag('subHead2')#>
		</cfoutput>
		<table class="<cfoutput>#this.dataResponseTableClass#</cfoutput>">
			<thead>
				<tr>
					<cfloop list="#variables.data.fieldnames#" index="variables.f">
						<th>
							<cfoutput>#variables.f#</cfoutput>
						</th>
					</cfloop>
				</tr>
			</thead>
			<tbody>
				<cfoutput 
					query="variables.rsdata" 
					startrow="#request.startRow#" 
					maxrows="#variables.nextN.RecordsPerPage#">
					<tr>
						<cfsilent>
							<cfwddx action="wddx2cfml" input="#variables.rsdata.data#" output="variables.info">
						</cfsilent>
						<cfloop list="#variables.data.fieldnames#" index="variables.f">
							<cfsilent>
								<cftry>
									<cfset variables.fValue=variables.info['#variables.f#']>
									<cfcatch>
										<cfset variables.fValue="">
									</cfcatch>
								</cftry>
							</cfsilent>
							<td>
								<cfif findNoCase('attachment',variables.f) and isValid("UUID",variables.fvalue)>
									<a  href="http://#application.settingsManager.getSite(session.siteid).getDomain()##application.configBean.getServerPort()##application.configBean.getContext()##application.configBean.getIndexPath()#/_api/render/file//index.cfm?fileID=#variables.fvalue#">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.viewattachment')#</a>
								<cfelse>
									<a href="./?dataResponseView=detail&amp;responseid=#variables.rsdata.responseid#">
										#HTMLEditFormat(variables.fvalue)#
									</a>
								</cfif>	
							</td>
						</cfloop>
					</tr>
				</cfoutput>
			</tbody>
		</table>
		<cfif variables.nextN.numberofpages gt 1>
			<cfoutput>
				<div class="mura-next-n navSequential #this.dataResponsePaginationClass#">
					<ul>
						<cfif variables.nextN.currentpagenumber gt 1>
							<li>
								<a href="./?startrow=#variables.nextN.previous#&amp;categoryID=#variables.$.event('categoryID')#&amp;relatedID=#request.relatedID#">&laquo;&nbsp;#variables.$.rbKey('list.previous')#</a>
							</li>
						</cfif>
						<cfloop from="#variables.nextN.firstPage#"  to="#variables.nextN.lastPage#" index="i">
							<cfif variables.nextN.currentpagenumber eq i>
								<li class="current active"><span>#i#</span></li>
							<cfelse>
								<li>
									<a href="./?startrow=#evaluate('(#i#*#variables.nextN.recordsperpage#)-#variables.nextN.recordsperpage#+1')#&amp;categoryID=#variables.$.event('categoryID')#&amp;relatedID=#request.relatedID#">#i#</a>
								</li>
							</cfif>
						</cfloop>
						<cfif variables.nextN.currentpagenumber lt variables.nextN.NumberOfPages>
							<li>
								<a href="./?startrow=#variables.nextN.next#&amp;categoryID=#variables.$.event('categoryID')#&amp;relatedID=#request.relatedID#">#variables.$.rbKey('list.next')#&nbsp;&raquo;</a>
							</li>
						</cfif>
					</ul>
				</cfoutput>
			</div>
		</cfif>
	<cfelseif variables.rsdata.recordcount and not ListLen(variables.data.fieldnames)>
		<div class="alert alert-info">
			<cfoutput>#variables.$.rbKey('form.dataresponses.nofieldnames')#</cfoutput>
		</div>
	<cfelse>
		<div class="alert alert-info">
			<cfoutput>#variables.$.rbKey('form.dataresponses.nodata')#</cfoutput>
		</div>
	</cfif>
</div>
