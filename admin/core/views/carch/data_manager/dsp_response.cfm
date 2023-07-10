<!--- license goes here --->
<cfsilent>
	<cfif LSisDate(rc.date1)>
		<cfset rc.date1=rc.date1>
	<cfelse>
		<cfset rc.date1=rc.rsDataInfo.firstentered>
	</cfif>

	<cfif LSisDate(rc.date2)>
		<cfset rc.date2=rc.date2>
	<cfelse>
		<cfset rc.date2=rc.rsDataInfo.lastentered>
	</cfif>

	<cfif len(rc.contentBean.getResponseDisplayFields()) gt 0 and rc.contentBean.getResponseDisplayFields() neq "~">
		<cfset rc.fieldnames=replace(listLast(rc.contentBean.getResponseDisplayFields(),"~"), "^", ",", "ALL")>
	<cfelse>
		<cfset rc.fieldnames=application.dataCollectionManager.getCurrentFieldList(rc.contentid)/>
	</cfif>
	<cfparam name="rc.hour1" default="0">
	<cfparam name="rc.minute1" default="0">
	<cfparam name="rc.hour2" default="23">
	<cfparam name="rc.minute2" default="59">
</cfsilent>
<div id="manage-data">
<cfif rc.rsDataInfo.CountEntered>
<cfparam name="rc.columns" default="fixed" />
<cfoutput>
<form novalidate="novalidate" action="index.cfm" method="get" name="download" onsubmit="return validate(this);">

	<div class="mura-control-group">
		<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.from')#</label>
		<input type="text" class="datepicker" name="date1" id="date1" value="#LSDateFormat(rc.date1,session.dateKeyFormat)#" style="width: 115px!important;" message="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.tovalidate')#" required="true"  autocomplete="off">
		<select name="hour1" class="time"><cfloop from="0"to="23" index="h"><option value="#h#" <cfif rc.hour1 eq h>selected</cfif>><cfif h eq 0>12 AM<cfelseif h lt 12>#iif(len(h) lt 2,de('0#h#'),de('#h#'))# AM<cfelseif h eq 12>#iif(len(h) lt 2,de('0#h#'),de('#h#'))# PM<cfelse><cfset h2=h-12>#iif(len(h2) lt 2,de('0#h2#'),de('#h2#'))# PM</cfif></option></cfloop></select>
		<select name="minute1" class="time"><cfloop from="0"to="59" index="mn"><option value="#mn#" <cfif rc.minute1 eq mn>selected</cfif>>#iif(len(mn) lt 2,de('0#mn#'),de('#mn#'))#</option></cfloop></select>
	</div>

	<div class="mura-control-group">
		<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.to')#</label>
		<input type="text" class="datepicker" name="date2" id="date2" value="#LSDateFormat(rc.date2,session.dateKeyFormat)#" style="width: 115px!important;" message="#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.tovalidate')#" required="true"   autocomplete="off">
		<select name="hour2" class="time"><cfloop from="0"to="23" index="h"><option value="#h#" <cfif rc.hour2 eq h>selected</cfif>><cfif h eq 0>12 AM<cfelseif h lt 12>#iif(len(h) lt 2,de('0#h#'),de('#h#'))# AM<cfelseif h eq 12>#iif(len(h) lt 2,de('0#h#'),de('#h#'))# PM<cfelse><cfset h2=h-12>#iif(len(h2) lt 2,de('0#h2#'),de('#h2#'))# PM</cfif></option></cfloop></select>
		<select name="minute2" class="time" ><cfloop from="0"to="59" index="mn"><option value="#mn#" <cfif rc.minute2 eq mn>selected</cfif>>#iif(len(mn) lt 2,de('0#mn#'),de('#mn#'))#</option></cfloop>
		</select>
	</div>

<div class="mura-control-group">
  <label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.sortby')#</label>
  <select name="sortBy" class="mura-constrain">
<option value="Entered" <cfif "Entered" eq rc.sortBy>selected</cfif>>Entered</option>
<cfloop list="#rc.fieldnames#" index="f">
<option value="#esapiEncode('html_attr',f)#" <cfif f eq rc.sortBy>selected</cfif>>#esapiEncode('html',f)#</option>
</cfloop>
</select>
<select name="sortDirection" class="mura-constrain">
<option value="asc" <cfif rc.sortDirection eq 'asc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.ascending')#</option>
<option value="desc" <cfif rc.sortDirection eq 'desc'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.descending')#</option>
</select>
</div>

	<div class="mura-control-group">
		<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.keywordsearch')#</label>
		<select name="filterBy" class="mura-constrain">
			<cfloop list="#rc.fieldnames#" index="f">
			<option value="#esapiEncode('html_attr',f)#" <cfif f eq session.filterBy>selected</cfif>>#esapiEncode('html',f)#</option>
			</cfloop>
		</select>
		<input type="text" name="keywords" class="mura-constrain" value="#esapiEncode('html_attr',session.datakeywords)#">
	</div>

<input type="hidden" name="muraAction" value="cArch.datamanager" />
<input type="hidden" name="contentid" value="#esapiEncode('html_attr',rc.contentid)#" />
<input type="hidden" name="siteid" value="#esapiEncode('html_attr',session.siteid)#" />
<input type="hidden" name="moduleid" value="#esapiEncode('html_attr',rc.moduleid)#" />
<input type="hidden" name="newSearch" value="1" />
<input type="hidden" name="delete" value="0" />
<div class="mura-actions">
	<div class="form-actions">
		<button type="button" class="btn mura-primary" onclick="submitForm(document.forms.download);" /><i class="mi-bar-chart"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.viewdata')#</button>
		<cfset downloadLocationString="'./?muraAction=cArch.downloaddata&siteid=#esapiEncode('url',rc.siteid)#&contentid=#esapiEncode('url',rc.contentid)#&date1=' + document.download.date1.value + '&hour1=' +document.download.hour1.value + '&minute1=' +document.download.minute1.value + '&date2=' + document.download.date2.value + '&hour2=' + document.download.hour2.value + '&minute2=' + document.download.minute2.value + '&sortBy=' +  document.download.sortBy.value + '&sortDirection=' +  document.download.sortDirection.value + '&filterBy='  + document.download.filterBy.value + '&keywords=' + document.download.keywords.value + '&columns=#esapiEncode('url',rc.columns)#'">
		<cfif isdefined ('rc.minute1')><button type="button" class="btn" onclick="return confirmDialog('Delete filtered results?',function(){document.download.delete.value=1;submitForm(document.forms.download);});" /><i class="mi-trash"></i> Delete Results</button></cfif>
		<button type="button" class="btn" onclick="location.href=#downloadLocationString#;"><i class="mi-download"></i> #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.download')#</button>
	</div>
</div>
</form>
</cfoutput>
<cfelse>
	<div class="help-block-empty">No data to display for this form</div>
</cfif>
<cfif isdefined ('rc.minute1')>
	<cfsilent>
	<cfset rsData=application.dataCollectionManager.getData(rc)/>
	</cfsilent>
	<cfif rsData.recordcount>
		<cfif isDefined('rc.delete') and isBoolean(rc.delete) and rc.delete>
			<cfloop query="rsData">
				<cfset application.dataCollectionManager.delete(responseid=rsData.responseID,deleteFiles=true)>
			</cfloop>
			<div class="help-block-empty"><cfoutput>#rsData.recordcount#</cfoutput> responses were deleted.</div>
		<cfelse>
			<div class="mura-grid-container">
			<table class="mura-table-grid">
			<thead>
			<tr>
				<th class="actions"></th>
				<th><cfoutput>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.datetimeentered')#</cfoutput></th>
				<cfloop list="#rc.fieldnames#" index="f">
				<th><cfoutput>#esapiEncode('html',f)#</cfoutput></th>
				</cfloop>
			</tr>
			</thead>
			<tbody>
			<cfoutput query="rsData">
			<tr>
				<cftry>
					<cfsilent><cfwddx action="wddx2cfml" input="#rsdata.data#" output="info"></cfsilent>
					<td class="actions">
						<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
						<div class="actions-menu hide">
							<ul class="actions-list">
								<li class="edit">
									<a href="./?muraAction=cArch.datamanager&contentid=#esapiEncode('url',rc.contentid)#&siteid=#esapiEncode('url',rc.siteid)#&date1=#esapiEncode('url',rc.date1)#&hour1=#esapiEncode('url',rc.hour1)#&minute1=#esapiEncode('url',rc.minute1)#&date2=#esapiEncode('url',rc.date2)#&hour2=#esapiEncode('url',rc.hour2)#&minute2=#esapiEncode('url',rc.minute2)#&responseid=#rsdata.responseid#&action=edit&moduleid=#esapiEncode('url',rc.moduleid)#&sortBy=#esapiEncode('url',rc.sortBy)#&sortDirection=#esapiEncode('url',rc.sortDirection)#&filterBy=#esapiEncode('url',rc.filterBy)#&keywords=#esapiEncode('url',rc.keywords)#"><i class="mi-pencil"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.edit')#</a>
								</li>
								<li class="delete">
									<a href="./?muraAction=cArch.datamanager&contentid=#esapiEncode('url',rc.contentid)#&siteid=#esapiEncode('url',rc.siteid)#&date1=#esapiEncode('url',rc.date1)#&hour1=#esapiEncode('url',rc.hour1)#&minute1=#esapiEncode('url',rc.minute1)#&date2=#esapiEncode('url',rc.date2)#&hour2=#esapiEncode('url',rc.hour2)#&minute2=#esapiEncode('url',rc.minute2)#&responseid=#rsdata.responseid#&action=delete&moduleid=#esapiEncode('url',rc.moduleid)#&sortBy=#esapiEncode('url',rc.sortBy)#&sortDirection=#esapiEncode('url',rc.sortDirection)#&filterBy=#esapiEncode('url',rc.filterBy)#&keywords=#esapiEncode('url',rc.keywords)##rc.$.renderCSRFTokens(context=rsdata.responseID,format='url')#" onclick="return confirmDialog('#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.deleteresponseconfirm'))#',this.href)"><i class="mi-trash"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.deleteresponse')#</a>
								</li>
							</ul>
						</div>
					</td>
					<td class="dateSubmitted">#lsdateformat(rsdata.entered,'short')# #lstimeformat(rsdata.entered,"short")#</td>
					<cfloop list="#rc.fieldnames#" index="f">
						<cftry><cfset fValue=info['#f#']><cfcatch><cfset fValue=""></cfcatch></cftry>
					<td class="mForm-data"><cfif findNoCase('attachment',f) and isValid("UUID",fvalue)><a  href="##" onclick="return preview('#rc.$.siteConfig().getResourcePath(complete=1)##application.configBean.getIndexPath()#/_api/render/file/?fileID=#esapiEncode("url",fvalue)#');">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.viewattachment')#</a><cfelse>#$.setParagraphs(esapiEncode('html',fvalue))#</cfif></td>
					</cfloop>
					<cfcatch>
						<td>Invalid Response: #rsData.responseID#</td>
					</cfcatch>
				</cftry>
			</tr>
			</cfoutput>
			</tbody>
			</table>
			</div><!-- /.mura-grid-container -->
		</cfif>
	</cfif>
</cfif>
</div>
