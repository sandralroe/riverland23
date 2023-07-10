 <!--- license goes here --->
<cfinclude template="js.cfm">
<cfhtmlhead text="#session.dateKey#">
<cfset rsList=application.dashboardManager.getTopContent(rc.siteID,rc.limit,rc.membersOnly,rc.visitorStatus,rc.startDate,rc.stopDate) />
<cfset rsTotal=application.dashboardManager.getTotalHits(rc.siteID,rc.membersOnly,rc.visitorStatus,rc.startDate,rc.stopDate) />
<cfset items=rc.$.getBean('contentIterator')>
<cfset items.setQuery(rslist)>
<cfoutput>

<div class="mura-header">
<h1>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.topviewedcontent")#</h1>

	<cfinclude template="dsp_secondary_menu.cfm">

</div> <!-- /.mura-header -->

<div class="block block-constrain">
	<div class="block block-bordered">
	  <div class="block-content">

			<h3 class="alt">#application.rbFactory.getKeyValue(session.rb,"params.daterange")#</h3>
			<form novalidate="novalidate" name="searchFrm" onsubmit="return validate(this);" id="advancedSearch">
				<div class="mura-control-group">
					<label class="label-inline">
						#application.rbFactory.getKeyValue(session.rb,"params.from")#
						<input type="text" class="datepicker" name="startDate" value="#LSDateFormat(rc.startDate,session.dateKeyFormat)#" validate="date" message="The 'From' date is required." />
						#application.rbFactory.getKeyValue(session.rb,"params.to")#
						<input type="text" class="datepicker" name="stopDate" value="#LSDateFormat(rc.stopDate,session.dateKeyFormat)#" validate="date" message="The 'To' date is required." />
					#application.rbFactory.getKeyValue(session.rb,"params.numberofitems")#
	      	<select name="limit">
						<cfloop list="10,20,30,40,50,75,100" index="i">
						<option value="#i#" <cfif rc.limit eq i>selected</cfif>>#i#</option>
						</cfloop>
						</select>
					</label>
				</div>
			<div class="mura-actions">
				<div class="form-actions">
					<button class="btn mura-primary" onclick="submitForm(document.forms.searchFrm);"><i class="mi-search"></i>#application.rbFactory.getKeyValue(session.rb,"params.search")#</button></dd>
				</div>
			</div>

			<input type="hidden" value="#esapiEncode('html_attr',rc.siteid)#" name="siteID"/>
			<input type="hidden" value="cDashboard.topContent" name="muraAction"/>
			</form>

			<h3 class="alt">#application.rbFactory.getKeyValue(session.rb,"dashboard.session.totalviews")#: <strong>#rstotal.hits#</strong></h3>

			<table class="mura-table-grid">
			<tr>
				<th class="actions"></th>
				<th class="var-width">#application.rbFactory.getKeyValue(session.rb,"dashboard.session.content")#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.views")#</th>
				<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.percent")#</th>
			</tr>
			<cfif items.hasNext()>
			<cfloop condition="items.hasNext()">
			<cfsilent>
			<cfset item=items.next()>
			</cfsilent>
			<tr>
				<td class="actions">
					<a class="show-actions" href="javascript:;" <!---ontouchstart="this.onclick();"---> onclick="showTableControls(this);"><i class="mi-ellipsis-v"></i></a>
					<div class="actions-menu hide">	
						<ul class="actions-list">		
							<li class="preview"><a href="##" onclick="return preview('#item.getURL(complete=1)#');"><i class="mi-globe"></i>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.view")#</a>
							</li>
						</ul>
					</div>		
				</td>
				<td class="var-width">#$.dspZoom(item.getCrumbArray())#</td>
				<td>#item.gethits()#</td>
				<td>#decimalFormat((item.gethits()/rstotal.hits)*100)#%</td>
			</tr>
			</cfloop>
			<cfelse>
			<tr>
			<td class="noResults" colspan="4">#application.rbFactory.getKeyValue(session.rb,"dashboard.session.nosearchresults")#</td>
			</tr>
			</cfif>
			</table>
		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->					

</cfoutput>