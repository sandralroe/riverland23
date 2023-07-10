 <!--- license goes here --->
<cfset request.layout=false>
<cfif not isNumeric(rc.categoryAssignment)>
	<cfset rc.categoryAssignment=0>
</cfif>
<cfoutput>
	<div class="categoryassignmentcontent<cfif rc.categoryAssignment eq '2'> scheduled</cfif>">
		<a class="dropdown-toggle mura-quickEditItem"<cfif rc.categoryAssignment eq '2'> rel="tooltip" title="#esapiEncode('html_attr',LSDateFormat(rc.featurestart,"short"))#&nbsp;-&nbsp;#LSDateFormat(rc.featurestop,"short")#"<cfelse>class="mura-quickEditItem"</cfif>>
			<cfswitch expression="#rc.categoryAssignment#">		
				<cfcase value="0">
					<i class="mi-ban" title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.no'))#"></i><span>#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.no'))#</span>
				</cfcase>
				<cfcase value="1">
					<i class="mi-check" title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.yes'))#"></i><span>#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,'sitemanager.yes'))#</span>
				</cfcase>
				<cfcase value="2">
					<i class="mi-calendar" title="#esapiEncode('html_attr',LSDateFormat(rc.featurestart,"short"))#&nbsp;-&nbsp;#LSDateFormat(rc.featurestop,"short")#"></i> 
				</cfcase>
				<cfdefaultcase>
					<i class="mi-ban" title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.no'))#"></i><span>#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,"sitemanager.no"))#</span>
				</cfdefaultcase>
			</cfswitch>
		</a>
		<input type="hidden" id="categoryAssign#rc.catTrim#" name="categoryAssign#rc.catTrim#" value="#esapiEncode('html_attr',rc.categoryAssignment)#"/>
		<cfif rc.categoryAssignment eq 2>
			<input type="hidden" id="featureStart#rc.catTrim#" name="featureStart#rc.catTrim#" value="#LSDateFormat(rc.featureStart,session.dateKeyFormat)#">
			<input type="hidden" id="startHour#rc.catTrim#" name="startHour#rc.catTrim#" value="#esapiEncode('html_attr',rc.startHour)#">
			<input type="hidden" id="startMinute#rc.catTrim#" name="startMinute#rc.catTrim#" value="#esapiEncode('html_attr',rc.startMinute)#">
			<input type="hidden" id="startDayPart#rc.catTrim#" name="startDayPart#rc.catTrim#" value="#esapiEncode('html_attr',rc.startDayPart)#">
			<input type="hidden" id="featureStop#rc.catTrim#" name="featureStop#rc.catTrim#" value="#LSDateFormat(rc.featureStop,session.dateKeyFormat)#">
			<input type="hidden" id="stopHour#rc.catTrim#" name="stopHour#rc.catTrim#" value="#esapiEncode('html_attr',rc.stopHour)#">
			<input type="hidden" id="stopMinute#rc.catTrim#" name="stopMinute#rc.catTrim#" value="#esapiEncode('html_attr',rc.stopMinute)#">
			<input type="hidden" id="stopDayPart#rc.catTrim#" name="stopDayPart#rc.catTrim#" value="#esapiEncode('html_attr',rc.stopDayPart)#">
		</cfif>
	</div>
</cfoutput>