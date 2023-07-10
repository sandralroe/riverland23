<!--- License goes here --->
<cfset request.layout=false>
<cfheader name="Content-Disposition" charset="utf-8" value="attachment;filename=#DateFormat(Now(), 'yyyymmdd')##TimeFormat(Now(), 'HHMMSS')#-config.xml.cfm">
<cfcontent type="application/xml"><cfoutput>#rc.exportXML#</cfoutput>