<!--- license goes here --->

<cfsilent>
<cfset rsData=application.dataCollectionManager.read(rc.responseid)/>
</cfsilent>
<cfoutput>
<form novalidate="novalidate" name="form1" id="formdataedit1" action="index.cfm" method="post">

<cfsilent><cfwddx action="wddx2cfml" input="#rsdata.data#" output="info"></cfsilent>

<div class="mura-control-group">
  <label>Date/Time Entered</label>
  <div class="mura-control">
    #LSDateFormat(rsdata.entered,session.dateKeyFormat)# #LSTimeFormat(rsdata.entered,"short")#
  </div>
</div>

<cfloop list="#rc.fieldnames#" index="f">
	<cftry>
		<cfset fValue=info['#f#']>
		<cfcatch>
			<cfset fValue="">
		</cfcatch>
	</cftry>
	<cfif findNoCase('attachment',f) and isValid("UUID",fvalue)>
		<input type="hidden" name="#esapiEncode('html_attr',f)#" value="#fvalue#">
	<cfelse>
		<div class="mura-control-group">
  			<label>#esapiEncode('html',f)#</label>
				<cfif len(fValue) gt 100>
					<textarea class="mura-constrain" name="#esapiEncode('html_attr',f)#">#esapiEncode('html',fvalue)#</textarea>
				<cfelse>
					<input class="mura-constrain" type="text" name="#esapiEncode('html_attr',f)#" value="#esapiEncode('html_attr',fvalue)#">
  			</cfif>
 		 </div>
	</cfif>
</cfloop>

<div class="mura-actions">
	<div class="form-actions">
	<button class="btn mura-primary" onclick="submitForm(document.forms.form1,'update');"><i class="mi-check-circle"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.update')#</button>
	<button type="button" class="btn" onclick="submitForm(document.forms.form1,'delete','#esapiEncode('javascript',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.deleteresponseconfirm'))#');"><i class="mi-trash"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.deleteresponse')#</button>
	</div>
</div>

<input type="hidden" name="formid" value="#esapiEncode('html_attr',rc.contentid)#">
<input type="hidden" name="contentid" value="#esapiEncode('html_attr',rc.contentid)#">
<input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.siteid)#">
<input type="hidden" name="muraAction" value="cArch.datamanager">
<input type="hidden" name="responseID" value="#rsdata.responseID#">
<input type="hidden" name="hour1" value="#esapiEncode('html_attr',rc.hour1)#">
<input type="hidden" name="hour2" value="#esapiEncode('html_attr',rc.hour2)#">
<input type="hidden" name="minute1" value="#esapiEncode('html_attr',rc.minute1)#">
<input type="hidden" name="minute2" value="#esapiEncode('html_attr',rc.minute2)#">
<input type="hidden" name="date1" value="#esapiEncode('html_attr',rc.date1)#">
<input type="hidden" name="date2" value="#esapiEncode('html_attr',rc.date2)#">
<input type="hidden" name="fieldlist" value="#esapiEncode('html_attr',rc.fieldnames)#">
<input type="hidden" name="sortBy" value="#esapiEncode('html_attr',rc.sortBy)#">
<input type="hidden" name="sortDirection" value="#esapiEncode('html_attr',rc.sortDirection)#">
<input type="hidden" name="filterBy" value="#esapiEncode('html_attr',rc.filterBy)#">
<input type="hidden" name="keywords" value="#esapiEncode('html_attr',rc.keywords)#">
<input type="hidden" name="entered" value="#rsData.entered#">
<input type="hidden" name="moduleid" value="#esapiEncode('html_attr',rc.moduleid)#">
<input type="hidden" name="action" value="update">
#rc.$.renderCSRFTokens(context=rsdata.responseID,format="form")#
</form>
</cfoutput>
