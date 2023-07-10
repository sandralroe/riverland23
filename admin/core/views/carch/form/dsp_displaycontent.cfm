<!--- License goes here --->
<cfset rc.ptype=rc.contentBean.getParent().getType()>

<cfif rc.contentBean.getIsNew() and rc.parentBean.getType() eq 'Calendar'>
	<cfset rc.ptype='Calendar'>
	<cfset rc.contentBean.setDisplay(2)>
</cfif>
<cfif rc.contentBean.getIsNew()>
	<cfset rc.contentBean.setDisplayStart(createDateTime(year(now()),month(now()),day(now()),0,0))>
</cfif>
<cfparam name="session.localeHasDayParts" default="true">

<cfoutput>
<div class="mura-control-group">
	<label>
		<span data-toggle="popover" title="" data-placement="right"
	  	data-content="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"tooltip.displayContent"))#"
	  	data-original-title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.fields.display"))#">
  			#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.display')#
  		 <i class="mi-question-circle"></i></span>
  	</label>
		<select name="display" id="mura-display" onchange="javascript: this.selectedIndex==2?toggleDisplay2('editDates',true):toggleDisplay2('editDates',false); $('##mura-datepicker-displayStart').trigger('change');">
		<option value="1"  <cfif rc.contentBean.getdisplay() EQ 1> selected</cfif>>
			<cfif rc.ptype eq 'Calendar'>
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.excludefromcalendar')#
			<cfelse>
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.always')#
			</cfif>
		</option>
		<option value="0"  <cfif rc.contentBean.getdisplay() EQ 0> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.never')#</option>
		<option value="2"  <cfif rc.contentBean.getdisplay() EQ 2> selected</CFIF>>
			#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.perschedule')#
		</option>
	</select>

<div id="editDates"<cfif rc.contentBean.getdisplay() NEQ 2> style="display: none;"</cfif> class="mura-control justify">

	<cfset displayInterval=rc.contentBean.getDisplayInterval().getAllValues()>

	<cfif rc.ptype eq 'Calendar' and not rc.contentBean.exists()>
		<cfset displayInterval.repeats=0>
		<cfset displayInterval.allday=1>
	<cfelseif rc.contentbean.getIsNew() and rc.ptype neq 'Calendar'>
		<cfset displayInterval.repeats=0>
		<cfset displayInterval.allday=0>
	</cfif>

	<cfif displayInterval.endAfter eq 0>
		<cfset displayInterval.endAfter = 1>
	</cfif>

	<div class="bigui__preview">
		<div id="displayschedule-label"></div>
	</div>

	<!--- 'big ui' flyout panel --->
	<div class="bigui" id="bigui__schedule" data-label=#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.schedule'))#>
		<div class="bigui__title">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.schedule'))#</div>
			<div class="bigui__controls">

				<div id="displayschedule-selector">	

					<div class="mura-control-group">
						<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.starts')#</label>
						<cf_datetimeselector name="displayStart" datetime="#rc.contentBean.getDisplayStart(timezone=displayInterval.timezone)#" timeselectwrapper="true">
							<label id="displayIntervalToLabel" class="time"<cfif rc.ptype neq 'Calendar'> style=
							"display:none;"</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.to')#</label>
						<cfif rc.ptype eq 'Calendar'>
							<cf_datetimeselector name="displayStop" datetime="#rc.contentBean.getDisplayStop(timezone=displayInterval.timezone)#" defaulthour="23" defaultminute="59"  timeselectwrapper="true">
						</cfif>

					</div>
					<!--- /end starts --->

					<!--- timezone --->
					<cfif len(rc.$.globalConfig('tzRegex'))>
					<div id="mura-tz-container" class="mura-control-group span4" style="display:none">
						<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.timezone')#</label>
						<cfset tz=CreateObject("java", "java.util.TimeZone")>
						<cfset defaultTZ=tz.getDefault().getID()>
						<cfset timezones=tz.getAvailableIDs()>
						<cfset timezones=listToArray(arrayToList(timezones))>
						<cfset arraySort(timezones,'text')>
						<select name="displayIntervalTZ" id="displayIntervalTZ" class="mura-repeat-option">
							<option value="#defaultTZ#"<cfif defaultTZ eq displayInterval.timezone> selected </cfif>>
								#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.default')# (#defaultTZ#)
							</option>
							<cfloop array="#timezones#" index="i">
								<cfif i neq defaultTZ and (len(rc.$.globalConfig('tzRegex')) and refind(rc.$.globalConfig('tzRegex'),i) or not len(rc.$.globalConfig('tzRegex')))>
									<option value="#i#"<cfif i eq displayInterval.timezone> selected </cfif>>#i#</option>
								</cfif>
							</cfloop>
						</select>
					</div>
					<cfelse>
						<cfset tz=CreateObject("java", "java.util.TimeZone")>
						<cfset defaultTZ=tz.getDefault().getID()>
						<input type="hidden" name="displayIntervalTZ" id="displayIntervalTZ" value="#defaultTZ#">
					</cfif>
					<input type="hidden" name="displayInterval" id="displayInterval" value="#esapiEncode('html_attr',rc.contentBean.getDisplayInterval(serialize=true))#">
					<input name="convertDisplayTimeZone" type="hidden" value="true">
					<!--- /end timezone --->

					<!--- all day --->
						<cfif rc.ptype eq 'Calendar'>
							<div class="mura-control-group">
								<label class="checkbox" for="displayIntervalAllDay">
									<input type="checkbox" id="displayIntervalAllDay" name="displayIntervalllDay" value="1" <cfif displayInterval.allday> checked</cfif>/>&nbsp;&nbsp;#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.allday')#
								</label>
							</div>
						<cfelse>
							<div>
								<input type="hidden" id="displayIntervalAllDay" name="displayIntervalllDay" value="0"/>
							</div>
						</cfif>

					<!--- repeats --->
					<div class="mura-control-group">
						<label style="display:none;" for="displayIntervalRepeats" class="checkbox">
							<input type="checkbox" class="mura-repeat-option" id="displayIntervalRepeats" value="1" name="displayIntervalRepeats"<cfif displayInterval.repeats> checked</cfif> >
						</label>

						<label class="radio inline"><input type="radio" id="repeatsRadioYes" name="repeatsRadio" value="yes"<cfif displayInterval.repeats> checked</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.repeats')#</label>
						<label class="radio inline"><input type="radio" id="repeatsRadioNo" name="repeatsRadio" value="no"<cfif not displayInterval.repeats> checked</cfif>>Does not repeat</label>
					</div>
					<!--- /repeats --->

					<!--- repeat schedule --->
					<div class="mura-repeat-options mura-control-group" style="display:none">
						<div class="mura-control-inline">
							<select id="displayIntervalType" name="displayIntervalType" class="mura-repeat-option">
								<cfloop list="daily,weekly,bi-weekly,monthly,weekdays,weekends,week1,week2,week3,week4,weeklast,yearly" index="i">
								<option value="#i#"<cfif displayInterval.type eq i> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayInterval.#i#')#</option>
								</cfloop>
							</select>
							<label class="time-repeat">
							&nbsp;#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.every')#</label>
							<input type="text" id="displayIntervalEvery" name="displayIntervalEvery" value="#esapiEncode('html_attr',displayInterval.every)#" class="mura-repeat-option numeric">

							<label class="time-repeat">
							<span class="mura-interval-every-label" id="mura-interval-every-label-weeks" style="display:none">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.weeks')#</span>
							<span class="mura-interval-every-label" id="mura-interval-every-label-months" style="display:none">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.months')#</span>
							<span class="mura-interval-every-label" id="mura-interval-every-label-years" style="display:none">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.years')#</span>
							<span class="mura-interval-every-label" id="mura-interval-every-label-days" style="display:none">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.days')#</span>
							<span class="mura-interval-every-label" id="mura-interval-every-label-biweeks" style="display:none">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.bi-weeks')#</span>
						</label>
						</div>
					</div><!-- /mura-repeat-options -->

					<!--- days of week --->
					<cfset daysofweekshortlabels=application.rbFactory.getKeyValue(session.rb,'calendar.weekdayAbrev')>
					<div class="mura-daysofweek mura-control-group" style="display:none">
						<label class="checkbox inline">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.ondow')#: </label>
							<label class="checkbox inline"><input class="mura-repeat-option" id="dow1" name="displayIntervalDays" type="checkbox" value="1"<cfif listFind(displayInterval.daysofweek,1)> checked</cfif>/> #listGetAt(daysofweekshortlabels,1)#</label>
							<label class="checkbox inline"><input class="mura-repeat-option" id="dow2" name="displayIntervalDays" type="checkbox" value="2"<cfif listFind(displayInterval.daysofweek,2)> checked</cfif>/> #listGetAt(daysofweekshortlabels,2)#</label>
							<label class="checkbox inline"><input class="mura-repeat-option" id="dow3" name="displayIntervalDays" type="checkbox" value="3"<cfif listFind(displayInterval.daysofweek,3)> checked</cfif>/> #listGetAt(daysofweekshortlabels,3)#</label>
							<label class="checkbox inline"><input class="mura-repeat-option" id="dow4" name="displayIntervalDays" type="checkbox" value="4"<cfif listFind(displayInterval.daysofweek,4)> checked</cfif>/> #listGetAt(daysofweekshortlabels,4)#</label>
							<label class="checkbox inline"><input class="mura-repeat-option" id="dow5" name="displayIntervalDays" type="checkbox" value="5"<cfif listFind(displayInterval.daysofweek,5)> checked</cfif>/> #listGetAt(daysofweekshortlabels,5)#</label>
							<label class="checkbox inline"><input class="mura-repeat-option" id="dow6" name="displayIntervalDays" type="checkbox" value="6"<cfif listFind(displayInterval.daysofweek,6)> checked</cfif>/> #listGetAt(daysofweekshortlabels,6)#</label>
							<label class="checkbox inline"><input class="mura-repeat-option" id="dow7" name="displayIntervalDays" type="checkbox" value="7"<cfif listFind(displayInterval.daysofweek,7)> checked</cfif>/> #listGetAt(daysofweekshortlabels,7)#</label>
					</div>
					<!--- /end days of week --->

				</div>

				<!--- ends --->
				<div class="mura-control-group<cfif rc.ptype eq 'Calendar'> mura-repeat-options</cfif>"<cfif rc.ptype eq 'Calendar'> style="display:none;"</cfif>>
					<label>#ReReplace(application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.ends'),"\b(\w)","\u\1","ALL")#</label>
					<select id="displayIntervalEnd" name="displayIntervalEnd" class="mura-repeat-option time" style="margin-left: 0;">
						<option value="never" <cfif displayInterval.end eq 'never'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.never')#</option>
						<option value="on"<cfif displayInterval.end eq 'on'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.on')#</option>
						<option value="after"<cfif displayInterval.end eq 'after'> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.after')#</option>
					</select>
						<span class="mura-interval-end" id="mura-interval-end-after" style="display:none">
							<input type="text" id="displayIntervalEndAfter" name="displayIntervalEndAfter" value="#esapiEncode('html_attr',displayInterval.endafter)#" class="mura-repeat-option numeric" size="3">
					<label class="time-repeat">
							#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.occurrences')#
					</label>
						</span>
						<span class="mura-interval-end" id="mura-interval-end-on" style="display:none">
							<input type="text" id="displayIntervalEndOn" name="displayIntervalEndOn" class="mura-repeat-option datepicker mura-datepickerdisplayIntervalEndOn" value="#LSDateFormat(displayInterval.endon,session.dateKeyFormat)#" maxlength="12"/>
							<cfif rc.ptype neq 'Calendar'>
							<cf_datetimeselector name="displayStop" datetime="#rc.contentBean.getDisplayStop(timezone=displayInterval.timezone)#" defaulthour="23" defaultminute="59" timeselectwrapper="true">
							</cfif>
						</span>
					</div>
					<!--- /end ends --->

				<cfif rc.type eq 'Calendar'>
					<div class="mura-control-group">
						<label for="displayIntervalDetectConflicts" class="checkbox">
							<input type="checkbox" class="mura-repeat-option" id="displayIntervalDetectConflicts" value="1" name="displayIntervalDetectConflicts"<cfif displayInterval.detectconflicts> checked</cfif>>&nbsp;&nbsp;#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.detectconflicts')#
						</label>
					</div>

					<div class="mura-control-group" id="mura-detectspan-container"<cfif displayInterval.detectconflicts> style="display:none;"</cfif>>
						<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.for')#</label>
						<select id="mura-detectspan" class="mura-repeat-option">
							<cfloop from="1" to="12" index="m">
								<option value="#m#"<cfif m eq displayInterval.detectspan> selected</cfif>>
								#m##application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.months')#
								</option>
							</cfloop>
						</select>
					</div>

				</cfif>

			</div> <!--- /displayschedule-selector --->
		</div>
	</div> <!--- /.bigui --->

<div><!--- /end editDates --->

	<script>
	$(function(){
		<cfif rc.ptype eq 'Calendar' and rc.contentBean.getDisplay() eq 2>
			var isCalendar=true;
		<cfelse>
			var isCalendar=false;
		</cfif>
	
		function pushDisplayStopOut(){
			$('##mura-datepicker-displayStop').val($('##mura-datepicker-displayStart').val());
			$('##mura-datepicker-displayStop').trigger('change');

			var stopMinute = ($('##mura-displayStopMinute').length) ? $('##mura-displayStopMinute').val() : 0;
			var stopHour=($('##mura-displayStopHour').length) ? $('##mura-displayStopHour').val() : 0;

			if($('##mura-displayStopDayPart').length){
				if($('##mura-displayStopDayPart').val().toLowerCase() == 'pm'){
					stopHour=parseInt(stopHour) + 12;
					if(stopHour==24){
						stopHour=12;
					}
				} else if (parseInt(stopHour) ==12) {
					stopHour=0;
				}
			}

			if(stopHour.length==1){
				stopHour='0' + stopHour;
			}

			if(stopMinute.length==1){
				stopMinute='0' + stopMinute;
			}

			$('##mura-displayStop').val("{ts '2100-01-01 " + stopHour + ":" + stopMinute + ":00'}");
			$('##displayIntervalEndOn').val('');
		}

		function updateDisplayInterval(){
			if($('##displayIntervalEnd').val()=='on'){
				$('##mura-datepicker-displayStop').val($('##displayIntervalEndOn').val());
				$('##mura-datepicker-displayStop').trigger('change');
			} else {
				pushDisplayStopOut();
			}

			var options={
				repeats: ($('##displayIntervalRepeats').is(':checked')) ? 1 : 0,
				detectconflicts: $('##displayIntervalDetectConflicts').is(':checked') ? 1 : 0,
				detectspan: $('##mura-detectspan').val(),
				allday:  (isCalendar && $('##displayIntervalAllDay').is(':checked')) ? 1 : 0,
				timezone: $('##displayIntervalTZ').val(),
				every: $('##displayIntervalEvery').val() || 0,
				type: $('##displayIntervalType').val(),
				end: $('##displayIntervalEnd').val(),
				endon: $('##displayIntervalEndOn').val(),
				endafter: $('##displayIntervalEndAfter').val(),
				daysofweek: getDaysOfWeek()
			};

			if(!options.repeats && options.allday){
				$('##mura-datepicker-displayStop').val($('##mura-datepicker-displayStart').val());
				$('##mura-datepicker-displayStop').trigger('change');
				options.endon=$('##mura-datepicker-displayStop').val();
			}

			$('##displayInterval').val(JSON.stringify(options));

			toggleDailyEndTime();
		}

		function toggleDailyEndTime(){
			var repeats =  $('##displayIntervalRepeats').is(':checked');
			var type=$('##displayIntervalEnd').val();

		//alert('toggling');

			if (!isCalendar){

				if (repeats){
					$('##displayIntervalToLabel').show();
					$('##mura-interval-end-on .mura-timeselectwrapper').insertAfter('##displayIntervalToLabel');
				} else if (type='on' || type == 'never'){
					$('##displayIntervalToLabel').hide();
					$('##displayIntervalToLabel + .mura-timeselectwrapper').insertAfter('##mura-datepicker-displayStop');
				}
			}
		}

		function getDaysOfWeek(){
			var daysofweek=[];

			$('input[name="displayIntervalDays"]').each(function(){
				var day=$(this);
				if(day.is(':checked')){
					daysofweek.push(day.val());
				}
			});

			return daysofweek.join();
		}

		function setDaysOfWeekDefault(){

			if(!$('input[name="displayIntervalDays"]:checked').length){
				var dateString=$('input[name="displayStart"]').val();

				if(dateString){
					var dateObj=new Date(dateString.substring(5,24));

					if(dateObj.getDay() > -1){
						$('input[name="displayIntervalDays"]:eq('+ dateObj.getDay() + ')').prop('checked',true);
					}
				}
			}
		}

		function setEndOption(){

			if(!isCalendar || isCalendar && $('##displayIntervalRepeats').is(':checked')){
				var type=$('##displayIntervalEnd').val();

				$('.mura-interval-end').hide();

				if(type=='after'){
					$('##mura-interval-end-after').show();
					if ($('##displayIntervalEndAfter').val() == 0){
						$('##displayIntervalEndAfter').val(1);
					}
					pushDisplayStopOut();
					if(!$('##displayIntervalRepeats').is(':checked')){
						$('##repeatsRadioYes').trigger('click');
						toggleRepeatCheckbox();
						toggleRepeatOptionsContainer();
						$('##displayIntervalEnd').val('after');
					}

				} else if(type=='on'){
					$('##mura-interval-end-on').show();
					$('##displayIntervalEndAfter').val(0);

					var start=$('##mura-datepicker-displayStart');
					var stop=$('##mura-datepicker-displayStop');
					var endon=$('##displayIntervalEndOn');

					if(!stop.val() && endon.val()){
						stop.val(endon.val()).trigger('change');
					}

					if(!endon.val()){
						endon.val(stop.val())
					}

					if(!endon.val()){
						endon.val(start.val());
						stop.val(start.val()).trigger('change');
					}
				} else if(type=='never'){
					pushDisplayStopOut();
					$('##displayIntervalEndAfter').val(0);
				}
			} else {
				var start=$('##mura-datepicker-displayStart');
				var stop=$('##mura-datepicker-displayStop');
				stop.val(start.val()).trigger('change');
				$('##displayIntervalEnd').val('on');
				$('##displayIntervalEndAfter').val(0);
				$('##displayIntervalEndOn').val(start.val());
			}

			updateDisplayInterval();
		}

		function setIntervalUnitLabel(){
			var type=$('##displayIntervalType').val();
			//alert(type)
			$('.mura-interval-every-label').hide();

			switch(type){
				case 'weekly':
				case 'weekends':
				case 'weekdays':
				$('##mura-interval-every-label-weeks').show();
				break;
				case 'bi-weekly':
				$('##mura-interval-every-label-biweeks').show();
				break;
				case 'yearly':
				$('##mura-interval-every-label-years').show();
				break;
				case 'daily':
				$('##mura-interval-every-label-days').show();
				break;
				default:
				$('##mura-interval-every-label-months').show();
			}
		}

		function toggleRepeatOptions(){
			var input=$('##displayIntervalType');

			if(input.val().toLowerCase().search('week') > -1 && input.val() != 'weekends' && input.val() != 'weekdays'){
				$('.mura-daysofweek').show();
				setDaysOfWeekDefault();

			} else {
				$('.mura-daysofweek').hide();
			}

			setIntervalUnitLabel();

		}

		function toggleAllDayOptions(){

			if(isCalendar && $('##displayIntervalAllDay').is(':checked')){
				$('##mura-displayStartHour').hide();
				$('##mura-displayStartMinute').hide();
				$('##mura-displayStartDayPart').hide();
				$('##mura-displayStopHour').hide();
				$('##mura-displayStopMinute').hide();
				$('##mura-displayStopDayPart').hide();
				$('##mura-tz-container').hide();
				$('##displayIntervalToLabel').hide();

				$('##displayIntervalTZ').val('#tz.getDefault().getID()#');

				<cfif session.localeHasDayParts>
					$('##mura-displayStartHour').val('12');
					$('##mura-displayStartMinute').val('0');
					$('##mura-displayStartDayPart').val('AM');
					$('##mura-displayStopHour').val('11');
					$('##mura-displayStopMinute').val('59');
					$('##mura-displayStopDayPart').val('PM');
				<cfelse>
					$('##mura-displayStartHour').val('0');
					$('##mura-displayStartMinute').val('0');
					$('##mura-displayStopHour').val('23');
					$('##mura-displayStopMinute').val('59');
				</cfif>

			} else if(isCalendar) {
				$('##mura-tz-container').show();
				$('##mura-displayStartHour').show();
				$('##mura-displayStartMinute').show();
				$('##mura-displayStartDayPart').show();
				$('##mura-displayStopHour').show();
				$('##mura-displayStopMinute').show();
				$('##mura-displayStopDayPart').show();
				$('##displayIntervalToLabel').show();
				$('##mura-tz-container').show();
			} else {
				$('##mura-tz-container').show();
				$('##mura-displayStartHour').show();
				$('##mura-displayStartMinute').show();
				$('##mura-displayStartDayPart').show();
				$('##mura-displayStopHour').show();
				$('##mura-displayStopMinute').show();
				$('##mura-displayStopDayPart').show();
				$('##displayIntervalToLabel').show();
				$('##mura-tz-container').show();
			}

			updateDisplayInterval();
		}

		function toggleRepeatOptionsContainer(){

			if($('##displayIntervalRepeats').is(':checked')){
				$('.mura-repeat-options').show();
				setDaysOfWeekDefault();
			} else {
				$('.mura-repeat-options').hide();
				$('##displayIntervalType').val('daily');
				$('##displayIntervalEvery').val(1);
				if($('##displayIntervalEndOn').val()){
					$('##displayIntervalEnd').val('on');
				} else {
					$('##displayIntervalEnd').val('never');
				}
				toggleRepeatOptions();
			}

			setEndOption();
			setIntervalUnitLabel();
		}

		function toggleDetectConflicts(){
			if($('##displayIntervalDetectConflicts').is(':checked')){
				$('##mura-detectspan-container').show();
			} else {
				$('##mura-detectspan-container').hide();
			}

		}

		function toggleRepeatCheckbox(){
			if ($('##repeatsRadioYes').is(':checked')){
				if (!$('##displayIntervalRepeats').is(':checked')){
					$('##displayIntervalRepeats').trigger('click');
				}
			} else {
				if ($('##displayIntervalRepeats').is(':checked')){
					$('##displayIntervalRepeats').trigger('click');
				}
			}
		}

		function hideDefaultRepeats(){
			var stopHour = $('##mura-displayStopHour').val();
			var stopMin = $('##mura-displayStopMinute').val();
			var stopDaypart = $('##mura-displayStopDayPart').val();
			var intervalType = $('##displayIntervalType').val();
			var intervalEvery = $('##displayIntervalEvery').val();
			var intervalEnds = $('##displayIntervalEnd').val();
			var intervalEndsAfter = $('##displayIntervalEndAfter').val();
			var repeats = $('##repeatsRadioYes').is(':checked');

			if ( (intervalEnds != 'after' || intervalEndsAfter < 2)
				&& (intervalType == 'daily' && intervalEvery == 1 && !repeats)
				&& (stopMin == 59 && (stopHour == 11 && stopDaypart == 'PM' || stopHour == 23))
				){
					$('##repeatsRadioNo').trigger('click');
					toggleRepeatCheckbox();
				}
		}

		$('##mura-datepicker-displayStop').hide();
		$('.mura-repeat-option').on('change',updateDisplayInterval);
		$('##displayIntervalRepeats').click(toggleRepeatOptionsContainer);
		$('##displayIntervalAllDay').click(toggleAllDayOptions);
		$('##displayIntervalDetectConflicts').click(toggleDetectConflicts);
		$('##displayIntervalType').on('change',toggleRepeatOptions);
		$('##displayIntervalEnd').on('change',setEndOption);
		$('##mura-datepicker-displayStart').change(setEndOption);
		$('##repeatsRadioYes,##repeatsRadioNo').click(toggleRepeatCheckbox);

		hideDefaultRepeats();
		toggleRepeatOptionsContainer();
		toggleRepeatOptions();
		toggleAllDayOptions();
		setEndOption();
		toggleDetectConflicts();

	})

	// update selected datetime string
	function showSelectedCS(){
		var startDayPart=$('##mura-displayStartDayPart option:selected');
		var csStr = $('##mura-datepicker-displayStart').val() + ' '
					+ $('##mura-displayStartHour').val() + ':'
					+ $('##mura-displayStartMinute option:selected').html() + ' '
					+ (startDayPart.length ? startDayPart.html() : '') + '<br>';
		if ( $('##displayIntervalRepeats').is(':checked')){
			csStr += '#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.repeating')#';
				if ($('##displayIntervalType').val() == 'daily'){
					csStr += '&nbsp;#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.every')#&nbsp;' + $('##displayIntervalEvery').val() + '&nbsp;#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.days')#';
				} else {
					csStr += $('##displayIntervalType option:selected').html();
				}
		}

		if ( $('##displayIntervalEnd').val() == 'on' && $('##displayIntervalEndOn').val() != ''  && $('##displayIntervalEndOn').val() != $('##mura-datepicker-displayStart').val()){
			csStr += ' #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.until')# ' + $('##displayIntervalEndOn').val();
		}
		else if ( $('##displayIntervalEnd').val() == ' #application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayinterval.after')#'  && $('##displayIntervalEndAfter').val() >= 1){
			csStr += ' x ' + $('##displayIntervalEndAfter').val();
		}

		if ($('##mura-datepicker-displayStart').val() != ''){
			$('##displayschedule-label').html(csStr);
		}
	}

	$(document).ready(function(){
		// run on page load
		showSelectedCS();
		// run on change of any schedule element
		$('##displayschedule-selector *, ##displayIntervalEnd').on('change',function(){
			showSelectedCS();
		})
	});

	</script>
</div>
</div>
</cfoutput>
