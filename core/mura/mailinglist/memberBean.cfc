<!--- license goes here --->
<cfcomponent extends="mura.bean.bean" output="false">

	<cfproperty name="MLID" type="string" default="" required="true" />
	<cfproperty name="siteID" type="string" default="" required="true" />
	<cfproperty name="email" type="string" default="" required="true" />
	<cfproperty name="fname" type="string" default="" required="true" />
	<cfproperty name="lname" type="string" default="" required="true" />
	<cfproperty name="company" type="string" default="" required="true" />
	<cfproperty name="isVerified" type="numeric" default="0" required="true" />
	<cfproperty name="created" type="date" default="" required="true" />

	<cffunction name="init" output="false">
		<cfset super.init(argumentCollection=arguments)>
		
		<cfset variables.instance.MLID="" />
		<cfset variables.instance.SiteID="" />
		<cfset variables.instance.Email="" />
		<cfset variables.instance.fName="" />
		<cfset variables.instance.lName="" />
		<cfset variables.instance.Company="" />
		<cfset variables.instance.isVerified=0 />
		<cfset variables.instance.created="" />

		<cfreturn this />
	</cffunction>

	<cffunction name="setCreated" output="false">
		<cfargument name="Created" type="string" required="true">
		<cfif lsisDate(arguments.created)>
			<cftry>
			<cfset variables.instance.created = lsparseDateTime(arguments.created) />
			<cfcatch>
				<cfset variables.instance.created = arguments.created />
			</cfcatch>
			</cftry>
			<cfelse>
			<cfset variables.instance.created = ""/>
		</cfif>
		<cfreturn this>
	</cffunction>

</cfcomponent>