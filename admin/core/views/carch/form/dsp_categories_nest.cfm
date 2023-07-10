<!--- license goes here --->
<cfsilent>
	<cfscript>
	if(server.coldfusion.productname != 'ColdFusion Server'){
		backportdir='';
		include "/mura/backport/backport.cfm";
	} else {
		backportdir='/mura/backport/';
		include "#backportdir#backport.cfm";
	}
	</cfscript>
	<cfparam name="attributes.siteID" default="" />
	<cfparam name="attributes.parentID" default="" />
	<cfparam name="attributes.nestLevel" default="1" />
	<cfparam name="attributes.disabled" default="false" />
	<cfparam  name="contentBean" default="">
	<cfparam name="request.catNo" default="0" />


	<cfset rslist=application.categoryManager.getCategories(attributes.siteID,attributes.ParentID) />
</cfsilent>



<cfsilent>
	<cfset rc.rsCategoryAssign=application.contentManager.getCategoriesByHistID(attributes.contentBean.getContentHistID()) />
	
	<cfset altContentHistId = ''>
	<cfif rc.rsCategoryAssign.recordCount EQ 0 AND isDefined('URL.templateid')>
		<cfset rs=application.contentManager.getLastHistoryIdByContent(URL.templateid) />
		<cfif rs.recordcount>
			<cfset altContentHistId = rs.ContentHistId>
			<cfset rc.rsCategoryAssign=application.contentManager.getCategoriesByHistID(rs.ContentHistId) />
		</cfif>
	</cfif>
</cfsilent>
<cfif rslist.recordcount>
	<ul class="categorylist"<cfif len(attributes.parentid)> style="display:none"<cfelse> id="mura-nodes"</cfif>>
		<cfoutput query="rslist">
			<cfsilent>
				<cfset catTrim=replace(rslist.categoryID,'-','','ALL') />
				<cfset request.catNo=request.catNo+1 />
				<cfif not len(attributes.contentBean.getValue('categoryAssign#catTrim#'))>
					<cfquery name="rsIsMember" dbtype="query">
					SELECT *
					FROM rc.rsCategoryAssign
					WHERE categoryID='#rslist.categoryID#'
						AND ContentHistID='#attributes.contentBean.getcontentHistID()#'
					</cfquery>
					<cfif rsIsMember.recordcount EQ 0 AND altContentHistId NEQ ''>
						<cfquery name="rsIsMember" dbtype="query">
							SELECT *
							FROM rc.rsCategoryAssign
							WHERE categoryID='#rslist.categoryID#'
								AND ContentHistID='#altContentHistId#'
						</cfquery>
					</cfif>
				<cfelse> 
					<cfset rsIsMember={
						recordcount=listFind(attributes.contentBean.getCategoryID(),rslist.categoryid),
						isFeature=attributes.contentBean.getValue('categoryAssign#catTrim#'),
						featureStart=attributes.contentBean.getValue('featureStart#catTrim#'),
						featureStop=attributes.contentBean.getValue('featureStop#catTrim#'),
						startHour=attributes.contentBean.getValue('startHour#catTrim#'),
						startMinute=attributes.contentBean.getValue('startMinute#catTrim#'),
						startDayPart=attributes.contentBean.getValue('startDayPart#catTrim#'),
						stopHour=attributes.contentBean.getValue('stopHour#catTrim#'),
						stopMinute=attributes.contentBean.getValue('stopMinute#catTrim#'),
						stopDayPart=attributes.contentBean.getValue('stopDayPart#catTrim#')
					}>
				</cfif>
				<cfparam name="request.opencategorylist" default="">

				<cfif rsIsMember.recordcount>
					<cfset request.opencategorylist=listAppend(request.opencategorylist,rslist.categoryid)>
				</cfif>

				<cfif not application.permUtility.getCategoryPerm(rslist.restrictGroups,attributes.siteid)>
					<cfset attributes.disabled=true />
				<cfelse>
					<cfset attributes.disabled=false />
				</cfif>

				<cfset assignVal = "">

				<cfif rsIsMember.recordCount>
					<cfset assignVal = rsIsMember.isFeature>
				</cfif>
			</cfsilent>
			<li data-siteID="#attributes.contentBean.getSiteID()#" data-categoryid="#rslist.categoryid#" data-cattrim="#catTrim#" data-disabled="#attributes.disabled#">
				<dl class="categoryitem">
					<!--- title --->
					<dt class="categorytitle">
						<span class="<cfif rslist.hasKids> hasChildren closed</cfif>"></span>
						<label>
							<cfif rslist.isOpen eq 1>
								<input name="categoryid" value="#rslist.categoryid#" type="checkbox"<cfif attributes.disabled> disabled="true"</cfif><cfif rsIsMember.recordcount> checked="true"</cfif>>
							</cfif>
							#esapiEncode('html',rslist.name)#</label>
							<cfif attributes.disabled and rsIsMember.recordcount>
								<input name="categoryid" value="#rslist.categoryid#" type="hidden" />
							</cfif>
					</dt>
					<!--- assignment --->
					<dd class="categoryassignmentwrapper">
						<cfif rslist.isOpen eq 1 and rslist.isFeatureable eq 1 or rslist.isFeatureable eq ''>
							<div id="categoryLabelContainer#cattrim#" class="categoryLabelContainer">
								<div class="categoryassignment<cfif rsIsMember.recordcount and rsIsMember.isFeature eq 2> scheduled</cfif>">
									<!--- Quick Edit --->
									<a class="dropdown-toggle<cfif not attributes.disabled> mura-quickEditItem</cfif>"<cfif rsIsMember.isFeature eq 2> rel="tooltip" title="#esapiEncode('html_attr',LSDateFormat(rsIsMember.featurestart,"short"))#&nbsp;-&nbsp;#LSDateFormat(rsIsMember.featurestop,"short")#"</cfif>>
										<cfswitch expression="#rsIsMember.isFeature#">
											<cfcase value="0">
											<i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.no")#"></i>
												<span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.no")#</span>
											</cfcase>
											<cfcase value="1">
												<i class="mi-check" title="#application.rbFactory.getKeyValue(session.rb,'sitemanager.yes')#"></i>
												<span>#application.rbFactory.getKeyValue(session.rb,'sitemanager.yes')#</span>
											</cfcase>
											<cfcase value="2">
												<i class="mi-calendar" title="#esapiEncode('html_attr',LSDateFormat(rsIsMember.featurestart,"short"))#&nbsp;-&nbsp;#LSDateFormat(rsIsMember.featurestop,"short")#"></i>
											</cfcase>
											<cfdefaultcase>
												<i class="mi-ban" title="#application.rbFactory.getKeyValue(session.rb,"sitemanager.no")#"></i><span>#application.rbFactory.getKeyValue(session.rb,"sitemanager.no")#</span>
											</cfdefaultcase>
										</cfswitch>
									</a><!--- /.mura-quickEditItem --->


									<input type="hidden" id="categoryAssign#catTrim#" name="categoryAssign#catTrim#" value="#val(assignVal)#"/>

									<cfif assignval eq 2>
											<input type="hidden" id="featureStart#catTrim#" name="featureStart#catTrim#" value="#LSDateFormat(rsIsMember.featurestart,session.dateKeyFormat)#">
										<cfif isDate(rsIsMember.featurestart)>
											<cfif session.localeHasDayParts>
												<cfif hour(rsIsMember.featurestart) lt 12>
													<input type="hidden" id="startHour#catTrim#" name="startHour#catTrim#" value="#hour(rsIsMember.featurestart)#">
													<input type="hidden" id="startDayPart#catTrim#" name="startDayPart#catTrim#" value="AM">
												<cfelse>
													<input type="hidden" id="startHour#catTrim#" name="startHour#catTrim#" value="#evaluate('hour(rsIsMember.featurestart)-12')#">
													<input type="hidden" id="startDayPart#catTrim#" name="startDayPart#catTrim#" value="PM">
												</cfif>
											<cfelse>
												<input type="hidden" id="startHour#catTrim#" name="startHour#catTrim#" value="#hour(rsIsMember.featurestart)#">
												<input type="hidden" id="startDayPart#catTrim#" name="startDayPart#catTrim#" value="">
											</cfif>
											<input type="hidden" id="startMinute#catTrim#" name="startMinute#catTrim#" value="#minute(rsIsMember.featurestart)#">
										<cfelse>
											<input type="hidden" id="startHour#catTrim#" name="startHour#catTrim#" value="">
											<input type="hidden" id="startMinute#catTrim#" name="startMinute#catTrim#" value="">
											<input type="hidden" id="startDayPart#catTrim#" name="startDayPart#catTrim#" value="">
										</cfif>
										<!--- feature stop --->
										<input type="hidden" id="featureStop#catTrim#" name="featureStop#catTrim#" value="#LSDateFormat(rsIsMember.featureStop,session.dateKeyFormat)#">
										<cfif isDate(rsIsMember.featureStop)>
											<cfif session.localeHasDayParts>
												<cfif hour(rsIsMember.featureStop) lt 12>
													<input type="hidden" id="stopHour#catTrim#" name="stopHour#catTrim#" value="#hour(rsIsMember.featureStop)#">
													<input type="hidden" id="stopDayPart#catTrim#" name="stopDayPart#catTrim#" value="AM">
												<cfelse>
													<input type="hidden" id="stopHour#catTrim#" name="stopHour#catTrim#" value="#evaluate('hour(rsIsMember.featureStop)-12')#">
													<input type="hidden" id="stopDayPart#catTrim#" name="stopDayPart#catTrim#" value="PM">
												</cfif>
											<cfelse>
												<input type="hidden" id="stopHour#catTrim#" name="stopHour#catTrim#" value="#hour(rsIsMember.featureStop)#">
													<input type="hidden" id="stopDayPart#catTrim#" name="stopDayPart#catTrim#" value="">
											</cfif>
											<input type="hidden" id="stopMinute#catTrim#" name="stopMinute#catTrim#" value="#minute(rsIsMember.featureStop)#">
										<cfelse>
											<input type="hidden" id="stopHour#catTrim#" name="stopHour#catTrim#" value="">
											<input type="hidden" id="stopMinute#catTrim#" name="stopMinute#catTrim#" value="">
											<input type="hidden" id="stopDayPart#catTrim#" name="stopDayPart#catTrim#" value="">
										</cfif>
									</cfif>
								</div><!--- /.categoryassignmentcontent --->
							</div><!--- /.categoryLabelContainer --->
						</cfif>
					</dd><!--- /.categoryassignment --->
				</dl><!--- /dl --->
				<cfif rslist.hasKids>
					<cf_dsp_categories_nest
						siteID="#attributes.siteID#"
						parentID="#rslist.categoryID#"
						nestLevel="#evaluate(attributes.nestLevel +1)#"
						contentBean="#attributes.contentBean#"
						rsCategoryAssign="#rc.rsCategoryAssign#"
						disabled="#attributes.disabled#">
				</cfif>
			</li><!--- /.categoryitem --->
		</cfoutput>
	</ul><!--- /.categorylist --->
</cfif>
