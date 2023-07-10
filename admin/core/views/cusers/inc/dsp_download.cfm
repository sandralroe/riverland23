<!--- License goes here --->
<cfset request.layout=false>
<cfheader name="Content-Disposition" value="attachment;filename=users.csv">
<cfcontent type="text/csv"><cfoutput>#replace(rc.str, "**comma**", ",", "ALL")#</cfoutput>