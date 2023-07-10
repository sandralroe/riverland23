<!--- license goes here --->

<cfparam name="rc.#rc.parentlabels#" default="">
<cfparam name="rc.#rc.parentlist#" default="">
<cfparam name="rc.parentlabels" default="">
<cfparam name="rc.parentlist" default="">
<cfparam name="rc.moduleid" default="">
<cfparam name="rc.sort" default="asc">
<cfparam name="rc.contentid" default="">

<cfset rsNest=application.contentManager.getNest('#rc.parentid#','#rc.siteid#', 0, '#rc.sort#')>
<cfoutput query="rsNest">
<cfif rc.contentid neq rsnest.contentid>
	<cfset variables.title=replace(rsNest.menutitle,",","","ALL")>
	<cfif (rsnest.type eq 'Page' or rsnest.type eq 'Folder' or rsnest.type eq 'Calendar')>
	<cfset "rc.#rc.parentlist#"=listappend(evaluate("rc.#rc.parentlist#"),"#rsnest.contentid#;#rsnest.filename#")>
	<cfsavecontent variable="templabel"><cfif rc.nestlevel><cfloop  from="1" to="#rc.NestLevel#" index="I">&nbsp;&nbsp;</cfloop></cfif>#variables.title#</cfsavecontent>
	<cfset "rc.#rc.parentlabels#"=listappend(evaluate("rc.#rc.parentlabels#"),templabel)>
	</cfif><cfif rsNest.hasKids>
	 <cf_siteparents parentid="#rsnest.contentid#" 
	  nestlevel="#evaluate(rc.nestlevel + 1)#" 
	  siteid="#rc.siteid#"
	  moduleid="#rc.moduleid#"
	  parentlabels="#rc.parentlabels#"
	  parentlist="#rc.parentlist#"
	  sort="#rc.sort#"
	  contentid="#rc.contentid#"></cfif>
	  </cfif>
  </cfoutput>
  