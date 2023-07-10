<cfset recaptcha = FORM["g-recaptcha-response"]>
		<cfif len(recaptcha)>
<cfquery name="getprospectsemester" datasource="webdirectory">
		select semester from semesterlist WHERE semesterid = '#form.semester#'
	</cfquery>
<cfquery name="getprogramID" datasource="webdirectory">
		select pos_name, programcontact, majorID from programlist WHERE majorID = '#form.programOption#'
	</cfquery>
<cfquery name="getcommMethod" datasource="webdirectory">
		select communicationMethod from communicationlist WHERE commID = '#form.communicationMethod#'
	</cfquery>

   <cfset DateToday = now() />
<!---    <cfquery name="PostProspect" datasource="webdirectory">
	insert into prospects (firstname, lastname, birthdate, address, city, state, zipcode, phone, email, textmessage, program, semester, communicationMethod, daterequest)
	values ( <cfqueryparam value="#form.firstname#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.lastname#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.lname#" cfsqltype="cf_sql_varchar">
    , <cfqueryparam value="#form.birthdate#" cfsqltype="cf_sql_varchar">    
	, <cfqueryparam value="#form.address#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.city#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.state#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.zipcode#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.phone#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.email#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.textmessage#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.program#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.semester#" cfsqltype="cf_sql_varchar">
	, <cfqueryparam value="#form.communicationMethod#" cfsqltype="cf_sql_varchar">
	, #datetoday#)
</cfquery>---> 
<cfoutput>

#form.firstname#<br>
#form.lastname#<br>
#form.email#<br>
#form.phone#<br>
#getprospectsemester.semester#<br>
#getprogramID.pos_name#<br>
#getprogramID.programcontact#<br>
#getcommMethod.communicationMethod#
</cfoutput>
Thank you for filling out our inquiry form. An admissions specilist will be reaching out to you shortly. 


	<cfelse>
		OOOPS this form will not be processed. Please go back and make sure you verify you are not a 
		robot.
		<cfabort>
		     </cfif> 
