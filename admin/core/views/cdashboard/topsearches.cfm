 <!--- license goes here --->
<cfinclude template="js.cfm">
<cfhtmlhead text="#session.dateKey#">
<cfset rsList=application.dashboardManager.getTopKeywords(rc.siteID,rc.limit,rc.membersOnly,rc.visitorStatus,rc.startDate,rc.stopDate) />
<cfset rsTotal=application.dashboardManager.getTotalKeywords(rc.siteID,rc.membersOnly,rc.visitorStatus,rc.startDate,rc.stopDate) />
<cfoutput>


<div class="mura-header">
	<h1>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.topsearches")#</h1>
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
					<button class="btn mura-primary" onclick="submitForm(document.forms.searchFrm);"><i class="mi-search"></i>#application.rbFactory.getKeyValue(session.rb,"params.search")#</button>
				</div>
			</div>

			<input type="hidden" value="#esapiEncode('html_attr',rc.siteid)#" name="siteID"/>
			<input type="hidden" value="cDashboard.topSearches" name="muraAction"/>
			</form>

			<h3 class="alt">#application.rbFactory.getKeyValue(session.rb,"dashboard.session.totalsearches")#: <strong>#rstotal.keywordCount#</strong></h3>
			<table class="mura-table-grid">
			<tr>
			<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.keywords")#</th>
			<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.count")#</th>
			<th>#application.rbFactory.getKeyValue(session.rb,"dashboard.session.percent")#</th>
			</tr>
			<cfif rslist.recordcount>
			<cfloop query="rslist">
			<tr>
			<td>#esapiEncode('html',rslist.keywords)#</td>
			<td>#rsList.keywordCount#</td>
			<td><cfif rstotal.keywordCount>0%<cfelse>#decimalFormat((rsList.keywordCount/rstotal.keywordCount)*100)#%</cfif></td>
			</tr>
			</cfloop>
			<cfelse>
			<tr>
			<td class="noResults" colspan="3">#application.rbFactory.getKeyValue(session.rb,"dashboard.session.nosearchresults")#</td>
			</tr>
			</cfif>
			</table>
			</cfoutput>

		</div> <!-- /.block-content -->
	</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->