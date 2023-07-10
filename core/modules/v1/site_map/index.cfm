<!--- license goes here --->

<!--- Matt, 2 things need to happen: add "-tree" to the class; set this.ulNestedClass to no value on the dspNestedNav method below. The value is set in the theme contentRenderer for MuraBootstrap3. --->
<cfsilent>
<cfparam name="objectparams.mapclass" default="mura-site-map">
<cfif objectparams.mapclass eq "mura-site-map">
	<cfset objectparams.ulNestedClass="">
	<cfset objectparams.ulNestedAttributes="">
	<cfset objectparams.liHasKidsClass="">
	<cfset objectparams.liHasKidsAttributes="">
	<cfset objectparams.aHasKidsClass="">
	<cfset objectparams.aHasKidsAttributes="">
<cfelse>
	<cfset objectparams.ulNestedClass=this.ulNestedClass>
	<cfset objectparams.ulNestedAttributes=this.ulNestedAttributes>
	<cfset objectparams.liHasKidsClass=this.liHasKidsClass>
	<cfset objectparams.liHasKidsAttributes=this.liHasKidsAttributes>
	<cfset objectparams.aHasKidsClass=this.aHasKidsClass>
	<cfset objectparams.aHasKidsAttributes=this.aHasKidsAttributes>
</cfif>
</cfsilent>
<cfoutput>
	<ul id="svSiteMap" class="#objectparams.mapclass#">
		<li class="home"><a href="#variables.$.globalConfig('context')##variables.$.getURLStem(variables.$.event('siteID'),'')#">Home</a>#variables.$.dspNestedNav(
				contentid='00000000000000000000000000000000001',
				viewdepth=10,
				class='',
				ulNestedClass=objectparams.ulNestedClass,
				ulNestedAttributes=objectparams.ulNestedAttributes,
				liHasKidsClass=objectparams.liHasKidsClass,
				liHasKidsAttributes=objectparams.liHasKidsAttributes,
				aHasKidsClass=objectparams.aHasKidsClass,
				aHasKidsAttributes=objectparams.aHasKidsAttributes)#
		</li>
	</ul>
</cfoutput>
