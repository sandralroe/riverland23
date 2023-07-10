<!--- license goes here --->
<cfset crumbs=variables.$.event('crumbData')>
<cfif arrayLen(crumbs) gt 1 and crumbs[2].type eq 'Calendar' and variables.$.content('display') eq 2 and variables.$.content('displayStart') gt now()>
<cfoutput>
<div id="svEventReminder" class="mura-event-reminder">
	<#variables.$.getHeaderTag('subHead1')#>#variables.$.rbKey('event.setreminder')#</#variables.$.getHeaderTag('subHead1')#>
	<cfif listfind(variables.$.event('doaction'),"setReminder")>
	<em>#variables.$.rbKey('event.setreminder')#</em><br/><br/>
	</cfif>
	<form class="well" name="reminderFrm" action="?nocache=1" method="post" onsubmit="return Mura.validateForm(this);" novalidate="novalidate" >
	<fieldset>
	<ol>
	<li class="req control-group"><label class="control-label" for="email">#variables.$.rbKey('event.email')#*</label>
	<input id="email" name="email" data-required="true" data-validate="email" data-message="#htmlEditFormat(variables.$.rbKey('event.emailvalidate'))#"></li>
	<li class="req control-group"><label class="control-label" for="interval">#variables.$.rbKey('event.sendmeareminder')#</label>
	<select id="interval" name="interval">
	<option value="0">0 #variables.$.rbKey('event.minutes')#</option>
	<option value="5">5 #variables.$.rbKey('event.minutes')#</option>
	<option value="15">15 #variables.$.rbKey('event.minutes')#</option>
	<option value="30">30 #variables.$.rbKey('event.minutes')#</option>
	<option value="60">1 #variables.$.rbKey('event.hour')#</option>
	<option value="120">2 #variables.$.rbKey('event.hours')#</option>
	<option value="240">3 #variables.$.rbKey('event.hours')#</option>
	<option value="300">4 #variables.$.rbKey('event.hours')#</option>
	<option value="360">5 #variables.$.rbKey('event.hours')#</option>
	<option value="420">6 #variables.$.rbKey('event.hours')#</option>
	<option value="480">7 #variables.$.rbKey('event.hours')#</option>
	<option value="540">8 #variables.$.rbKey('event.hours')#</option>
	<option value="1440">1 #variables.$.rbKey('event.day')#</option>
	<option value="2880">2 #variables.$.rbKey('event.days')#</option>
	<option value="3320">3 #variables.$.rbKey('event.days')#</option>
	<option value="10040">1 #variables.$.rbKey('event.week')#</option>
	</select>
	#variables.$.rbKey('event.beforethisevent')#</li>
	</ol>
	</fieldset>
	<input name="doaction" value="setReminder" type="hidden"/>
	<input class="btn" type="submit" value="#htmlEditFormat(variables.$.rbKey('event.submit'))#"/>
	</form>
</div>
</cfoutput>
</cfif>
