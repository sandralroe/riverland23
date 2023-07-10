<!--- license goes here --->
<cfset request.layout=false>
<cfif not isNumeric(rc.categoryAssignment)>
	<cfset rc.categoryAssignment=0>
</cfif>
<cfset $=application.serviceFactory.getBean("MuraScope").init(session.siteID)>
	<cfoutput>
	<h1>#application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.feature')#</h1>
	<span class="cancel" onclick="siteManager.closeCategoryAssignment();" title="#application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.cancel')#"><i class="mi-close"></i></span>

		<!---
		<select id="mura-quickEdit-display" onchange="this.selectedIndex==2?toggleDisplay2('mura-quickEdit-displayDates',true):toggleDisplay2('mura-quickEdit-displayDates',false);">
			<option value=""  <cfif rc.categoryAssignment EQ ''> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.yes')#</option>
			<option value="0"  <cfif content.getdisplay() EQ 0> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.no')#</option>
			<option value="2"  <cfif content.getdisplay() EQ 2> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.perstopstart')#</option>
		</select>
		--->
		<select id="mura-quickEdit-display" onchange="this.selectedIndex==2?toggleDisplay2('mura-quickEdit-displayDates',true):toggleDisplay2('mura-quickEdit-displayDates',false);">
		<option <cfif rc.categoryAssignment eq '0'>selected</cfif> value="0">#application.rbFactory.getKeyValue(session.rb,'sitemanager.no')#</option>
		<option value="1" <cfif rc.categoryAssignment eq '1'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.yes')#</option>
		<option value="2" <cfif rc.categoryAssignment eq '2'>selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.scheduledfeature')#</option>
		</select>


		<div id="mura-quickEdit-displayDates"<cfif rc.categoryAssignment NEQ 2> style="display: none;"</cfif>>

			<div class="mura-control-group">
				<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.startdatetime')#</label>
				<input type="text" id="mura-quickEdit-featureStart" value="#LSDateFormat(rc.featurestart,session.dateKeyFormat)#" class="textAlt datepicker mura-quickEdit-datepicker"><br />

				<cfif session.localeHasDayParts>
					<select id="mura-quickEdit-startHour" class="time">
						<cfloop from="1" to="12" index="h">
							<option value="#h#" <cfif isNumeric(rc.startHour) and (rc.startHour eq h or rc.startHour eq 0 and h eq 12) or not isNumeric(rc.startHour) and h eq 12>selected</cfif>>#h#</option>
						</cfloop>
					</select>
				<cfelse>
					<select id="mura-quickEdit-startHour" class="time">
						<cfloop from="0" to="23" index="h">
							<option value="#h#" <cfif isNumeric(rc.startHour) and rc.startHour eq h>selected</cfif>>#h#</option>
						</cfloop>
					</select>
				</cfif>

				<select id="mura-quickEdit-startMinute" class="time">
					<cfloop from="0" to="59" index="m">
						<option value="#m#" <cfif isNumeric(rc.startMinute) and rc.startMinute eq m>selected</cfif>>
							#iif(len(m) eq 1,de('0#m#'),de('#m#'))#
						</option>
					</cfloop>
				</select>

				<cfif session.localeHasDayParts>
					<select id="mura-quickEdit-startDayPart" class="time">
						<option value="AM">AM</option>
						<option value="PM" <cfif rc.startDayPart eq 'PM'>selected</cfif>>PM</option>
					</select>
				</cfif>
			</div> <!-- /.mura-control-group -->

			<div class="mura-control-group">
				<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.stopdatetime')#</label>
				<input type="text" id="mura-quickEdit-featureStop" value="#LSDateFormat(rc.featureStop,session.dateKeyFormat)#" class="textAlt datepicker mura-quickEdit-datepicker"><br />

				<cfif session.localeHasDayParts>
					<select id="mura-quickEdit-stopHour" class="time">
						<cfloop from="1" to="12" index="h">
							<option value="#h#" <cfif isNumeric(rc.stopHour) and (rc.stopHour eq h or rc.stopHour eq 0 and h eq 12) or not isNumeric(rc.stopHour) and h eq 11>selected</cfif>>#h#</option>
						</cfloop>
					</select>
				<cfelse>
					<select id="mura-quickEdit-stopHour" class="time">
						<cfloop from="0" to="23" index="h">
							<option value="#h#" <cfif isNumeric(rc.stopHour) and rc.stopHour eq h or not isNumeric(rc.stopHour) and h eq 23>selected</cfif>>#h#</option>
						</cfloop>
					</select>
				</cfif>

				<select id="mura-quickEdit-stopMinute" class="time">
					<cfloop from="0" to="59" index="m">
						<option value="#m#" <cfif isNumeric(rc.stopMinute) and rc.stopMinute eq m or m eq 59>selected</cfif>>
							#iif(len(m) eq 1,de('0#m#'),de('#m#'))#
						</option>
					</cfloop>
				</select>

				<cfif session.localeHasDayParts>
					<select id="mura-quickEdit-stopDayPart" class="time">
						<option value="AM">AM</option>
						<option value="PM" <cfif rc.stopDayPart neq 'AM'>selected</cfif>>PM</option>
					</select>
				</cfif>
			</div> <!-- /.mura-control-group -->

		</div> <!-- /mura-quickEdit-displayDates -->
	<input type="hidden" id="mura-quickEdit-cattrim" value="#esapiEncode('html_attr',rc.cattrim)#">
		<div class="form-actions">
		<button class="btn mura-primary" type="button" onclick="siteManager.saveCategoryAssignment();">Submit</button>
	</div>
	</cfoutput>
