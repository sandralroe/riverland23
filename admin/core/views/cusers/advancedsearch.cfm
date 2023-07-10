<!--- License goes here --->
<cfinclude template="inc/js.cfm" />
<cfsilent>
	<cfset options=arrayNew(2) />
	<cfset criterias=arrayNew(2) />

	<cfset options[1][1]="tusers.fname^varchar">
	<cfset options[1][2]= rbKey('user.fname') >
	<cfset options[2][1]="tusers.lname^varchar">
	<cfset options[2][2]= rbKey('user.lname')>
	<cfset options[3][1]="tusers.username^varchar">
	<cfset options[3][2]= rbKey('user.username') >
	<cfset options[4][1]="tusers.email^varchar">
	<cfset options[4][2]= rbKey('user.email')>
	<cfset options[5][1]="tusers.company^varchar">
	<cfset options[5][2]= rbKey('user.company')>
	<cfset options[6][1]="tusers.jobTitle^varchar">
	<cfset options[6][2]= rbKey('user.jobtitle')>
	<cfset options[7][1]="tusers.website^varchar">
	<cfset options[7][2]= rbKey('user.website')>
	<!---<cfset options[8][1]="tusers.IMName^varchar">
	<cfset options[8][2]="IM Name">
	<cfset options[8][1]="tusers.IMService^varchar">
	<cfset options[8][2]="IM Service">--->
	<cfset options[8][1]="tusers.mobilePhone^varchar">
	<cfset options[8][2]= rbKey('user.mobilephone')>
	<cfset options[9][1]="tuseraddresses.address1^varchar">
	<cfset options[9][2]= rbKey('user.address1')>
	<cfset options[10][1]="tuseraddresses.address2^varchar">
	<cfset options[10][2]= rbKey('user.address2')>
	<cfset options[11][1]="tuseraddresses.city^varchar">
	<cfset options[11][2]= rbKey('user.city')>
	<cfset options[12][1]="tuseraddresses.state^varchar">
	<cfset options[12][2]= rbKey('user.state')>
	<cfset options[13][1]="tuseraddresses.Zip^varchar">
	<cfset options[13][2]= rbKey('user.zip')>
	<cfset options[14][1]="tusers.created^date">
	<cfset options[14][2]= rbKey('user.created')>
	<cfset options[15][1]="tusers.tags^varchar">
	<cfset options[15][2]= rbKey('user.tag')>

	<!--- Extended Attributes --->
		<cfset rsExtend=application.configBean.getClassExtensionManager().getExtendedAttributeList(siteID=rc.siteid,baseTable="tusers",activeOnly=true)>
		<cfloop query="rsExtend">
			<cfset options[rsExtend.currentRow + 15][1]="#rsExtend.attributeID#^varchar">
			<cfset options[rsExtend.currentRow + 15][2]="#iif(rsExtend.Type eq 1,de('Group'),de('User'))#/#rsExtend.subType# - #rsExtend.attribute#"/>
		</cfloop>

	<!--- Criteria --->
		<cfset criterias[1][1]="Equals">
		<cfset criterias[1][2]=rbKey('params.equals')>
		<cfset criterias[2][1]="GT">
		<cfset criterias[2][2]=rbKey('params.gt')>
		<cfset criterias[3][1]="GTE">
		<cfset criterias[3][2]=rbKey('params.gte')>
		<cfset criterias[4][1]="LT">
		<cfset criterias[4][2]=rbKey('params.lt')>
		<cfset criterias[5][1]="LTE">
		<cfset criterias[5][2]=rbKey('params.lte')>
		<cfset criterias[6][1]="NEQ">
		<cfset criterias[6][2]=rbKey('params.neq')>
		<cfset criterias[7][1]="Begins">
		<cfset criterias[7][2]=rbKey('params.beginswith')>
		<cfset criterias[8][1]="Contains">
		<cfset criterias[8][2]=rbKey('params.contains')>
</cfsilent>
<cfoutput>
<div class="mura-header">
	<h1>#rbKey("user.advancedusersearch")#</h1>

	<!--- Basic Search Button --->
	<div class="nav-module-specific btn-group">
		<a class="btn" href="#buildURL(action='cusers.search', querystring='siteid=#esapiEncode('url',rc.siteid)#')#" onclick="actionModal();">
			<i class="mi-search"></i> 
			#rbKey('user.basicsearch')#
		</a>
	</div>

</div> <!-- /.mura-header -->


<div class="block block-constrain">
<!--- Search Form --->
<form class="mura-search" novalidate="novalidate" id="advancedMemberSearch" action="index.cfm" method="get" name="form2">

		<!--- Search Params --->
			<div class="mura-control-group" id="searchParams">
					<label>#rbKey("user.searchcriteria")#</label>

					<cfif rc.newSearch or (session.paramCircuit neq 'cUsers' or not session.paramCount)>
					<div class="mura-control justify">
						<select name="paramRelationship1" style="display:none;">
							<option value="and">#rbKey("params.and")#</option>
							<option value="or">#rbKey("params.or")#</option>
						</select>

						<input type="hidden" name="param" value="1" />

						<select name="paramField1">
							<option value="">#rbKey("params.selectfield")#</option>
							<cfloop from="1" to="#arrayLen(options)#" index="i">
								<option value="#options[i][1]#">#options[i][2]#</option>
							</cfloop>
						</select>
							
						<select name="paramCondition1">
							<cfloop from="1" to="#arrayLen(criterias)#" index="i">
								<option value="#criterias[i][1]#">#criterias[i][2]#</option>
							</cfloop>
						</select>
				
						<input type="text" name="paramCriteria1">

						<!--- remove --->
						<a class="criteria remove" href="javascript:;" onclick="$searchParams.removeSeachParam(this.parentNode);$searchParams.setSearchButtons();return false;" style="display:none;" title="#rbKey("params.removecriteria")#">
							<i class="mi-minus-circle"></i>
						</a>
						<!--- add --->
						<a class="criteria add" href="javascript:;" onclick="$searchParams.addSearchParam();$searchParams.setSearchButtons();return false;" title="#rbKey("params.addcriteria")#">
							<i class="mi-plus-circle"></i>
						</a>
					</div> <!--- /.mura-control --->
				<cfelse>
					<cfloop from="1" to="#session.paramCount#" index="p">
						<div class="mura-control justify">
						<select name="paramRelationship#p#">
							<option value="and" <cfif session.paramArray[p].relationship eq "and">selected</cfif>>
								#rbKey("params.and")#
							</option>
							<option value="or" <cfif session.paramArray[p].relationship eq "or">selected</cfif>>
								#rbKey("params.or")#
							</option>
						</select>

						<input type="hidden" name="param" value="#p#" />
						
						<select name="paramField#p#">
							<option value="">#rbKey("params.selectfield")#</option>
							<cfloop from="1" to="#arrayLen(options)#" index="i">
								<option value="#options[i][1]#" <cfif session.paramArray[p].field eq options[i][1]>selected</cfif>>
									#options[i][2]#
								</option>
							</cfloop>
						</select>
						
						<select name="paramCondition#p#">
							<cfloop from="1" to="#arrayLen(criterias)#" index="i">
								<option value="#criterias[i][1]#" <cfif session.paramArray[p].condition eq criterias[i][1]>selected</cfif>>
									#criterias[i][2]#
								</option>
							</cfloop>
						</select>
						
						<input type="text" name="paramCriteria#p#" value="#session.paramArray[p].criteria#">
						<a class="criteria remove" href="javascript:;" onclick="$searchParams.removeSeachParam(this.parentNode);$searchParams.setSearchButtons();return false;" title="#rbKey('params.removecriteria')#">
							<i class="mi-minus-circle"></i>
						</a>
						<a class="criteria add" href="javascript:;" onclick="$searchParams.addSearchParam();$searchParams.setSearchButtons();return false;" title="#rbKey('params.addcriteria')#">
							<i class="mi-plus-circle"></i>
						</a><br><br>
						</div> <!--- /.mura-control --->
					</cfloop>
				</cfif>
			</div> <!--- /searchparams --->

		<!--- Active --->
			<div class="mura-control-group">
				<label>#rbKey('user.inactive')#</label>
				<select name="inActive">
					<option value="">#rbKey('user.all')#</option>
					<option value="0" <cfif session.inactive eq 0>selected</cfif>>#rbKey('user.yes')#</option>
					<option value="1" <cfif session.inactive eq 1>selected</cfif>>#rbKey('user.no')#</option>
				</select>
			</div>
		<!--- /Active --->

	<!--- Form Buttons --->
		<div class="mura-actions">
			<div class="form-actions">
				<input type="hidden" name="muraAction" value="cUsers.advancedSearch">
				<input type="hidden" name="siteid" value="#esapiEncode('html', rc.siteid)#">
				<input type="hidden" name="ispublic" value="#esapiEncode('html', rc.ispublic)#">
				
				<!--- Download Button --->
					<cfif rc.it.getRecordcount()>
						<button type="button" class="btn" onclick="document.forms.form2.muraAction.value='cUsers.advancedSearchToCSV';submitForm(document.forms.form2);$('##action-modal').remove();">
							<i class="mi-download"></i> 
							#rbKey("user.download")#
						</button>
					</cfif>

				<!--- Search Button --->
					<button type="button" class="btn mura-primary" onclick="document.forms.form2.muraAction.value='cUsers.advancedSearch';submitForm(document.forms.form2);">
						<i class="mi-search"></i> 
						#rbKey("user.search")#
					</button>
			</div>
		</div>

</form>
<!--- /Search Form --->
</div>

<div class="block block-constrain">
	<!--- Tab Nav (only tabbed for Admin + Super Users) --->
    <cfif rc.isAdmin>
					<ul class="mura-tab-links nav-tabs">
						<!--- Site Members Tab --->
							<li<cfif rc.ispublic eq 1> class="active"</cfif>>
								<a href="#buildURL(action='cusers.advancedsearch', querystring='#esapiEncode("url",rc.qs)#ispublic=1')#" onclick="actionModal();">
									#rbKey('user.sitemembers')#
								</a>
							</li>

		        <!--- System Users Tab --->
							<li<cfif rc.ispublic eq 0> class="active"</cfif>>
								<a href="#buildURL(action='cusers.advancedsearch', querystring='#esapiEncode("url",rc.qs)#ispublic=0')#" onclick="actionModal();">
									#rbKey('user.systemusers')#
								</a>
							</li>
		      </ul>
					<!-- start tab -->
					<div id="tab2" class="tab-pane">
						<div class="block block-bordered">
							<!-- block header -->
							<div class="block-header">
								<h3 class="block-title"><cfif rc.ispublic eq 1>#rbKey('user.sitemembers')#<cfelse>#rbKey('user.systemusers')#</cfif></h3>
							</div> <!-- /.block header -->						
							<div class="block-content">
							  	 
					  		<!--- Search Results --->
								<cfinclude template="inc/dsp_users_list.cfm" />

								</div> <!-- /.block-content -->
						</div> <!-- /.block-bordered -->
					</div> <!-- /.tab-pane -->
					<!-- /end tab -->

    <cfelse>
			<div class="block block-bordered">
			  <div class="block-content">

		      <h3>#rbKey('user.sitemembers')#</h3>
					<!--- Search Results --->
					<cfinclude template="inc/dsp_users_list.cfm" />

				</div> <!-- /.block-content -->
			</div> <!-- /.block-bordered -->
    </cfif>  
  <!--- /Tab Nav --->

</div> <!-- /.block-constrain -->

<script type="text/javascript">$searchParams.setSearchButtons();</script>

</cfoutput>