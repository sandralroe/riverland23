
<!--- License goes here --->
<cfsilent>
	<cfset $ = application.serviceFactory.getBean('$').init(session.siteid) />
	<cfset rsFormList = $.getBean('formBuilderManager').getForms($,session.siteid,form.formid) />
</cfsilent>
<cfoutput><span>
		<div class="mura-tb-form">
			<div class="mura-tb-header nestedform">
				<h2><!---#mmRBF.getKeyValue(session.rb,'formbuilder.field.nested')#:---><span id="mura-tb-form-label"></span></h2>
				<ul class="mura-tb-nav-utility">
					<li><div id="button-trash" title="#mmRBF.getKeyValue(session.rb,'formbuilder.delete')#"></div></li>
				</ul>
			</div>
			
			<div class="ui-tabs" id="ui-tabs">
			
			<ul class="ui-tabs-nav">
				<li class="ui-state-default ui-corner-top"><a href="##mura-tb-form-tab-basic"><span>Basic</span></a></li>
			</ul>
						
			<div class="ui-tabs-panel" id="mura-tb-form-tab-basic">
			
					<ul class="template-form">
						<li>
							<label for="label">#mmRBF.getKeyValue(session.rb,'formbuilder.field.label')#</label>
							<input class="text tb-label" type="text" name="label" value="" maxlength="250" data-required='true' />
						</li>
						<li>
							<label for="prefix">#mmRBF.getKeyValue(session.rb,'formbuilder.field.prefix')#</label>
							<input id="tb-name" class="text disabled" name="name" type="text" value="" maxlength="250" disabled="true" />
						</li>
						<li>
							<label for="value">#mmRBF.getKeyValue(session.rb,'formbuilder.form')#</label>
							<select name="formid" id="tb-formid">
								<cfloop query="rsFormList">
									<option value="#rsFormList.contentID#">#rsFormList.title#</option>
								</cfloop>
							</select>
						</li>
						<!---#$.renderEvent('onFormElementBasicTabRender')#--->
					</ul>
			</div>		
		</div>
		</div>
	</span>
</cfoutput>
