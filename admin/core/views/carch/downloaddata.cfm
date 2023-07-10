 <!--- license goes here --->
<cfsilent>
<cfset request.layout=false>
<cfparam name="rc.columns" default="">

<!---
<cfif len(rc.contentBean.getResponseDisplayFields()) gt 0 and rc.contentBean.getResponseDisplayFields() neq "~">
	<cfset rc.fieldnames=replace(listLast(rc.contentBean.getResponseDisplayFields(),"~"), "^", ",", "ALL")>
<cfelse>--->
	<cfset rc.fieldnames=application.dataCollectionManager.getCurrentFieldList(rc.contentid)/>
<!---</cfif>--->

<cfset rsdata=application.dataCollectionManager.getData(rc)/>
<cfset DelimChar=",">
<cfset NewLine=chr(13)&chr(10)>

<cffunction name="fixDelim" output="false" returntype="string">
	<cfargument default="" type="String" name="arg">
	<cfreturn '"' & replace(replace(arguments.arg,'"','""',"All"),NewLine," ","All") & '"'>
</cffunction>

</cfsilent>
<cfheader name="Content-Disposition" value="attachment;filename=#rereplace(rc.contentBean.gettitle(),' ','-','ALL')#_#LSDateFormat(now(),'mmddyy')#.csv">
<cfheader name="Expires" value="0">
<cfcontent type="application/msexcel" reset="yes"><cfoutput>DATE/TIME ENTERED#DelimChar#<cfloop list="#rc.fieldnames#" index="c">#c##DelimChar#</cfloop>#NewLine#</cfoutput><cfoutput query="rsData"><cfsilent><cfwddx action="wddx2cfml" input="#rsdata.data#" output="info"></cfsilent>#rsdata.entered##DelimChar#<cfloop list="#iif(rc.columns eq 'fixed',de('#rc.fieldnames#'),de('#rsdata.fieldList#'))#" index="f"><cftry><cfif findNoCase('attachment',f) and isValid("UUID",info['#f#'])>#application.settingsManager.getSite(rc.siteid).getScheme()#://#application.settingsManager.getSite(rc.siteid).getDomain()##application.configBean.getServerPort()##application.configBean.getContext()##application.configBean.getIndexPath()#/_api/render/file/?fileID=#info['#f#']#<cfelse>#fixDelim(info['#f#'])#</cfif><cfcatch></cfcatch></cftry>#DelimChar#</cfloop>#NewLine#</cfoutput><cfabort>
