<!--- license goes here --->

<cfparam name="rc.#rc.linklist#" default="">
<cfparam name="rc.#rc.labellist#" default="">
<cfparam name="rc.linklist" default="">
<cfparam name="rc.labellist" default="">
<cfparam name="rc.moduleid" default="">
<cfparam name="rc.sort" default="asc">
<cfparam name="rc.context" default="">
<cfparam name="rc.stub" default="">
<cfparam name="rc.indexFile" default="index.cfm">

<cfset rsNest=application.contentManager.getNest('#rc.parentid#','#rc.siteid#')>
<cfoutput query="rsNest">
<cfset link=$.createHREF(rsNest.type,rsNest.filename,rc.siteid,rsnest.contentid,rsNest.target,rsnest.targetParams,'',rc.context,rc.stub,rc.indexFile) />
<cfset "rc.#rc.linklist#"=listappend(evaluate("rc.#rc.linklist#"),"#link#","^")>
<cfsavecontent variable="templabel"><cfif rc.nestlevel><cfloop  from="1" to="#rc.NestLevel#" index="I">&nbsp;&nbsp;</cfloop></cfif>#rsnest.menutitle#</cfsavecontent>
<cfset "rc.#rc.labellist#"=listappend(evaluate("rc.#rc.labellist#"),templabel,"^")>
<cfif rsNest.hasKids><cf_sitelist parentid="#rsnest.contentid#" 
  nestlevel="#evaluate(rc.nestlevel + 1)#" 
  siteid="#rc.siteid#"
  moduleid="#rc.moduleid#"
  linklist="#rc.linklist#"
  labellist="#rc.labellist#"
  sort="#rc.sort#"
  context="#rc.context#"
  stub="#rc.stub#"
  indexFile="#rc.indexFile#"></cfif></cfoutput>
  