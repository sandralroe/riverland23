
<!--- License goes here --->
<cfoutput><span>
		<div class="mura-tb-form">
			<div class="mura-tb-header hiddenfield">
				<h2><!---#mmRBF.getKeyValue(session.rb,'formbuilder.field.textfield')#:---><span id="mura-tb-form-label"></span></h2>
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
							<label for="name">#mmRBF.getKeyValue(session.rb,'formbuilder.field.name')#</label>
							<input id="tb-name" class="text disabled" name="name" type="text" value="" maxlength="250" disabled="true" />
						</li>
						<li>
							<label for="value">#mmRBF.getKeyValue(session.rb,'formbuilder.field.value')#</label>
							<input class="text long" type="text" name="value" value="" maxlength="250" />
						</li>
						#application.serviceFactory.getBean('$').init(session.siteid).renderEvent('onFormElementBasicTabRender')#
					</ul>
			</div>		
		</div>
		</div>
	</span>
</cfoutput>
