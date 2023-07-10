<!--- license goes here --->
<cfoutput><span>
		<div class="mura-tb-form">
			<div class="mura-tb-header textblock">
				<h2><!---#mmRBF.getKeyValue(session.rb,'formbuilder.field.textblock')#:---> <span id="mura-tb-form-label"></span></h2>
				<ul class="mura-tb-nav-utility">
					<li><div id="button-trash" title="#mmRBF.getKeyValue(session.rb,'formbuilder.delete')#"></div></li>
				</ul>
			</div>
			
			<div class="ui-tabs" id="ui-tabs">
			
			<ul class="ui-tabs-nav">
				<li class="ui-state-default ui-corner-top"><a href="##mura-tb-form-tab-basic"><span>Basic</span></a></li>
			</ul>
			
			<div class="ui-tabs-panel" id="mura-tb-form-tab-basic" style="position: relative">		
					<ul class="template-form">
						<li>
							<label for="label">#mmRBF.getKeyValue(session.rb,'formbuilder.field.label')#</label>
							<input class="text  tb-label" type="text" name="label" value="" maxlength="50" data-required='true' />
							<textarea id='field_textblock' class="textarea" name="value"></textarea>
						</li>
					</ul>
			</div>
		</div>
	</span>
</cfoutput>
