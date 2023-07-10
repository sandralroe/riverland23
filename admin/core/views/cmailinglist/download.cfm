<!--- license goes here --->
<cfset request.layout=false>
<cfset newline= chr(13)& chr(10)>
<cfset TabChar=chr(9)>
<cfheader name="Content-Disposition" value="attachment;filename=#rc.listBean.getname()#.txt"> 
<cfheader name="Expires" value="0">
<cfcontent type="text/plain" reset="yes"><cfoutput>email#tabChar#fname#tabChar#lname#tabChar#company#tabChar#created#newline#</cfoutput><cfoutput query="rc.rslist">#rc.rslist.email##tabChar##rc.rslist.fname##tabChar##rc.rslist.lname##tabChar##rc.rslist.company##tabChar##LSDateFormat(created,session.datekeyformat)##newline#</cfoutput>