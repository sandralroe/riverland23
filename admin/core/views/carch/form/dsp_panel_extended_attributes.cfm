<!--- license goes here --->
<cfset tabList=listAppend(tabList,"tabExtendedAttributes")>
<cfset extendSets=application.classExtensionManager.getSubTypeByName(rc.type,rc.contentBean.getSubType(),rc.siteid).getExtendSets(activeOnly=true) />

<cfoutput>
<div class="mura-panel<cfif not arrayLen(extendSets)> hide</cfif>" id="tabExtendedAttributes">
	<div class="mura-panel-heading" role="tab" id="heading-extendedattributes">
		<h4 class="mura-panel-title">
			<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##content-panels" href="##panel-extendedattributes" aria-expanded="false" aria-controls="panel-extendedattributes">#application.rbFactory.getKeyValue(session.rb,"sitemanager.content.tabs.extendedattributes")#</a>
		</h4>
	</div>
	<div id="panel-extendedattributes" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-extendedattributes" aria-expanded="false" style="height: 0px;">
		<div class="mura-panel-body">
			<span id="extendset-container-tabextendedattributestop" class="extendset-container"></span>
			<span id="extendset-container-default" class="extendset-container"></span>
			<!--- legacy tab assignments render here --->
			<cfloop list="#application.contentManager.getLegacyTabList()#" index="container">
				<cfset tabStr = REreplace(container, "[^\\\w]", "", "all")>
				<span id="extendset-container-#lcase(tabStr)#" class="extendset-container"></span>
			</cfloop>

			<span id="extendset-container-tabextendedattributesbottom" class="extendset-container"></span>
		</div>
	</div>
</div> 
</cfoutput>