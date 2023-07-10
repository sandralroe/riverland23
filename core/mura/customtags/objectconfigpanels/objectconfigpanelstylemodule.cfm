<!--- todo: document nested configurator panel syntax --->
<!---
<div class="mura-panel-group" id="panels-style-object">

		<!--- panel 1: layout --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-object" href="##panel-style-object-1">Layout
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-object-1" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->

            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

</div> <!--- /.mura-panel-group --->
--->

<cfoutput>

<div class="mura-panel-group" id="panels-style-object">

		<!--- panel 1: layout --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-object" href="##panel-style-object-1">Layout
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-object-1" class="panel-collapse collapse">
            <div class="mura-panel-body">
            	<!--- panel contents --->
				<cfif request.haspositionoptions and request.hasFixedWidth>
					<div class="mura-control-group">
						<label>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.width')#</label>
						<!--- width selector widget --->
						<div id="object-widthsel-ui">
							<div id="object-widthsel-wrapper" class="mura-flex">
							<cfloop from="1" to="#arrayLen(attributes.positionoptions)#" index="i">
								<cfset p = attributes.positionoptions[i]>
								<cfif structKeyExists(p,'cols') and val(p["cols"])>
								<div class="object-widthsel-option" data-value="#p["value"]#"><span>#p["cols"]#</span></div>
								</cfif>
							</cfloop>
							</div>
						</div>
						
						<!--- hidden select tied to js logic in objectconfigurator.cfm --->
						<div style="display: none">
							<select name="width" id="objectwidthsel" class="classtoggle">
								<cfloop from="1" to="#arrayLen(attributes.positionoptions)#" index="i">
									<cfset p = attributes.positionoptions[i]>
									<option value="#p['value']#"<cfif listFind(attributes.params.class,'#p['value']#',' ')> selected</cfif>>#p['label']#</option>
									<cfset l = "'#p["label"]#'">
									<cfset v = "'#p["value"]#'">
								</cfloop>
							</select>
						</div>
					</div>
					<cfif len(contentcontainerclass)>
						<div class="mura-control-group constraincontentcontainer" style='display:none;'>
							<cfif $.siteConfig().getContentRenderer().getValue(property='enableExpandToggle',defaultValue=(not $.siteConfig('isremote')))>
							<label class="css-input switch switch-sm switch-primary">
								<input type="checkbox" id="expandedwidthtoggle" name="expandedwidthtoggle" value="true"<cfif listFind(attributes.params.class,'mura-expanded',' ')> checked</cfif>><span></span> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.expandwidth'))#
							</label>
							</cfif>
							<label class="css-input switch switch-sm switch-primary">
								<input name="constraincontenttoggle" type="checkbox" id="constraincontenttoggle" value="true"<cfif listFind(attributes.params.contentcssclass,contentcontainerclass,' ')> checked</cfif>><span></span> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.constraincontent'))#
							</label>
							<!--- hidden select tied to js logic in objectconfigurator.cfm --->
							<div style="display:none;">	
								<select name="constraincontent" id="objectconstrainsel" class="classtoggle">
									<option value=""<cfif not listFind(attributes.params.contentcssclass,contentcontainerclass,' ')> selected</cfif>>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.false'))#</option>
									<option value="constrain"<cfif listFind(attributes.params.contentcssclass,contentcontainerclass,' ')> selected</cfif>>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.true'))#</option>
								</select> 
							</div>							 								
						</div>
					</cfif>

					<div class="mura-control-group objectbreakpointcontainer">
						<label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.targetdevice'))# (#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.breakpoint'))#)</label>
						<select name="objectBreakpoint" data-param="breakpoint"  id="objectbreakpointsel" class="classtoggle">
						<option value="mura-xs"<cfif listFind(attributes.params.class,'mura-xs',' ')> selected</cfif>> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.phoneportrait'))#</option>
						<option value="mura-sm"<cfif not(listFind(attributes.params.class,'mura-md',' ') || listFind(attributes.params.class,'mura-xs',' ') or listFind(attributes.params.class,'mura-lg',' ') or listFind(attributes.params.class,'mura-xl',' ') )> selected</cfif>> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.phonelandscape'))# (< 576px)</option>
						<option value="mura-md"<cfif listFind(attributes.params.class,'mura-md',' ')> selected</cfif>>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.tablet'))# (< 768px)</option>
						<option value="mura-lg"<cfif listFind(attributes.params.class,'mura-lg',' ')> selected</cfif>>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.laptop'))# (< 992px)</option>
						<option value="mura-xl"<cfif listFind(attributes.params.class,'mura-xl',' ')> selected</cfif>> #esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.desktop'))# (< 1200px)</option>
						</select>
					</div>

					<div class="mura-control-group objectbreakpointcontainer">
						<label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.breakpointbehavior'))#</label>
						<select name="objectBreakpointBhvr" data-param="breakpointbp" id="objectbreakpointbhsel" class="classtoggle">
						<option value="">#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.displayfullwidth'))#</option>
						<option value="mura-bp-hide"<cfif listFind(attributes.params.class,'mura-bp-hide',' ')> selected</cfif>>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.hide'))#</option>
						</select>
					</div>
					
				</cfif>
				
				<cfif arrayLen(request.layoutoptions)>
					<cfset loArray=[]>
					<cfloop array="#request.layoutoptions#" index="t">
						<cfif (not structKeyExists(t,'modules') or t.modules eq '*' or listFindNoCase(t.modules,attributes.params.object)) and not (structKeyExists(t,'omitmodules') and listFindNoCase(t.omitmodules,attributes.params.object))>
						<cfset arrayAppend(loArray,t)>
						</cfif>
					</cfloop>
					<cfif arrayLen(loArray)>
						<div class="mura-control-group">
							<label>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.layout'))#</label>
							<select name="layoutOption" class="classtoggle">
								<option value="">--</option>
								<cfloop array="#loArray#" index="t">
									<option value="#t.value#"<cfif len(attributes.params.class) and listFind(attributes.params.class,t.value,' ')> selected</cfif>>#esapiEncode('html',t.name)#</option>
								</cfloop>
							</select>
						</div>
					</cfif>
				</cfif>

				<cfset attributes.name='object'>
				<cfinclude template="objectlayout.cfm">
				<!--- /panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

		<!--- panel 2: theme --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-object" href="##panel-style-object-2">Theme
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-object-2" class="panel-collapse collapse">
            <div class="mura-panel-body">
				 <!--- panel contents --->

				<!--- theme --->
				<cfif arrayLen(request.modulethemeoptions)>
					<cfset request.modulethemelabels = []>
					<cfset request.modulethemevalues = []>
					<div class="mura-control-group mura-ui-grid">
						<label>Theme Styles</label>
						<div class="row mura-flex">
							<select class="dispenser-select" name="moduletheme" id="objectTheme"  data-delim=" " data-param="objectThemeClasses">
								<option value="">--</option>
								<cfloop array="#request.modulethemeoptions#" index="t">
									<cfif (not structKeyExists(t,'modules') or t.modules eq '*' or listFindNoCase(t.modules,attributes.params.object)) and not (structKeyExists(t,'omitmodules') and listFindNoCase(t.omitmodules,attributes.params.object))>
									<option value="#t.value#">#esapiEncode('html',t.name)#</option>
									<cfset arrayAppend(request.modulethemelabels,t.name)>
									<cfset arrayAppend(request.modulethemevalues,t.value)>
									</cfif>
								</cfloop>
							</select>
							<input type="hidden" value="#esapiEncode('html_attr',attributes.params.objectthemeclasses)#" name="objectThemeClasses" id="objectThemeClassesdispenserval" class="classtoggle objectParam">
					<!--- 		<a class="btn btn-trans mura-select-dispense" data-select="objectTheme" href="##"><i class="mi-plus-circle"></i></a> --->
						</div>

						<!--- if saved theme values --->
						<cfif len(trim(attributes.params.objectthemeclasses))>
							<cfset request.objectthemeoptions = []>
							<cfset request.objectthemeclasses = listToArray(attributes.params.objectthemeclasses, ' ')>
								<cfloop array="#request.objectthemeclasses#" item="c">
									<cfif listFind(attributes.params.class,c,' ')>
										<cfset arrayAppend(request.objectthemeoptions,c)>
									</cfif>
								</cfloop>	
								<!--- if saved values match available options --->
								<cfif arrayLen(request.objectthemeoptions)>
									<div class="dispense-to" data-select="objectTheme" data-delim=" " data-param="objectThemeClasses">
										<cfloop array="#request.objectthemeoptions#" index="o">
											<cfset labelIndex=arrayFind(request.modulethemevalues,o)>
											<cfset oo = (labelIndex) ? request.modulethemelabels[arrayFind(request.modulethemevalues,o)] : o>
											<div class="dispense-option" data-value="#o#">
												<span class="drag-handle"><i class="mi-navicon"></i></span>
												<span class="dispense-label">#oo#</span>
												<a class="dispense-option-close"><i class="mi-minus-circle"></i></a>
											</div>
										</cfloop>
									</div>
								</cfif>	
						</cfif>	
						
					</div>
				</cfif>
				 
				<!--- text color --->
				<cfset attributes.name='object'>
				<cfinclude template="objecttext.cfm">
				 
         		<!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

		<!--- panel 3: background --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-object" href="##panel-style-object-3">Background
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-object-3" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->
			
			<cfset attributes.name='object'>
			<cfinclude template="objectbackground.cfm">

            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

		<!--- panel 4: custom --->
    <div class="panel mura-panel">
        <div class="mura-panel-heading">
            <h4 class="mura-panel-title">
                <a class="collapse collapsed" data-toggle="collapse" data-parent="##panels-style-object" href="##panel-style-object-4">Custom
                </a>
            </h4>
        </div> <!--- /.mura-panel-heading --->
        <div id="panel-style-object-4" class="panel-collapse collapse">
            <div class="mura-panel-body">
            <!--- panel contents --->
				<cfif not $.siteConfig().get('isremote')>
				<div class="mura-control-group">
					<label>
						Lazy Load?
					</label>
			
					<label class="radio inline">
						<input name="queue" class="objectParam" type="radio" value="true" <cfif attributes.params.queue>checked</cfif>> True
					</label>
					<label class="radio inline">
						<input name="queue" class="objectParam" type="radio" value="false" <cfif not attributes.params.queue>checked</cfif>> False
					</label>
				</div>
				</cfif>
				<div class="mura-control-group">
					<label>
					Z-Index
					</label>
					<input name="zIndex" class="objectStyle numeric" type="text" value="#esapiEncode('html_attr',attributes.params.stylesupport.objectstyles.zindex)#" maxlength="5">
				</div>
				<div class="mura-control-group">
					<label>
						CSS Class
					</label>
					<input name="cssclass" class="objectParam classtoggle" type="text" value="#esapiEncode('html_attr',attributes.params.cssclass)#" maxlength="255">
				</div>
				<div class="mura-control-group">
					<label>
						Custom CSS Styles
					</label>
					<cfoutput>
					<textarea class="textarea-lg mura-code" id="customstylesedit" data-mode="css" data-lineNumbers="false">#esapiEncode('html',attributes.params.stylesupport.css)#</textarea>
					</cfoutput>
					<a class="btn" id="applystyles"><i class="mi-check"></i>#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.applycustomstyles'))#</a>
					<script>
						Mura(function(){
							Mura('##applystyles').click(function(){
								jQuery('##csscustom').val(Mura('##customstylesedit').val()).trigger('change');
							})
						})
						
					</script>
				</div>
            <!--- /end panel contents --->
            </div> <!--- /.mura-panel-body --->
        </div> <!--- /.panel-collapse --->
    </div> <!--- /.mura-panel --->

</div> <!--- /.mura-panel-group --->
</cfoutput>
