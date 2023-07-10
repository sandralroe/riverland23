<cfparam name="objectParams.label" default="">
<cfparam name="objectParams.labeltag" default="">
<cfparam name="objectParams.isbodyobject" default="false">
<cfparam name="objectParams.hasTargetAttr" default="false">
<cfparam name="objectParams.metacssstyles.textalign" default="">
<cfparam name="request.hasbasicoptions" default="true">
<cfif $.siteConfig().getModule(objectParams.object).metaoptions 
and (isBoolean(objectParams.hasTargetAttr) and not objectParams.hasTargetAttr)>
	<cfset request.hasmetaoptions=true>
	<cfif not (IsBoolean(objectParams.isbodyobject) and objectParams.isbodyobject)>
		<cfoutput>
			<cfif isDefined('request.muraconfiguratortag')>
				<cfif request.hasbasicoptions>
					</div> <!--- /end  mura-panel-collapse --->
				</div> <!--- /end  mura-panel-body --->
			</div> <!--- /end panel --->
			</cfif>
			<div class="mura-panel">
				<div class="mura-panel-heading" role="tab" id="heading-labeling">
					<h4 class="mura-panel-title">
						<a class="collapse collapsed" role="button" data-toggle="collapse" data-parent="##configurator-panels" href="##panel-labeling" aria-expanded="false" aria-controls="panel-labeling">
							<i class="mi-header"></i>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.heading')#
						</a>
					</h4>
				</div>
				<div id="panel-labeling" class="panel-collapse collapse" role="tabpanel" aria-labelledby="heading-labeling">
					<div class="mura-panel-body">
			</cfif>
			<div id="labelContainer">
				<div class="mura-control-group">
					<cfif isDefined('request.muraconfiguratortag')>
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.text')#</label>
					<cfelse>
					<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.label')#</label>
					</cfif>
					<input id="labelText" name="label" type="text" class="objectParam" maxlength="100" value="#esapiEncode('html_attr',objectParams.label)#"/>
				</div>
				<div class="mura-control-group">
					<label>Heading Tag</label>
					<select name="labeltag" class="objectParam">
						<cfloop list="h1,h2,h3,h4,h5,h6" item="tag">
							<option value="#tag#" <cfif tag eq objectParams.labeltag> selected</cfif>>#ucase(tag)#</option>
						</cfloop>
					</select>
				</div>
			</div>
		</cfoutput>
	</cfif>
<cfelse>
	<cfset request.hasmetaoptions=false>
</cfif>