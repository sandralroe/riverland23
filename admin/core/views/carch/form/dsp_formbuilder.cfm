<!--- License goes here --->
<cfoutput>
<script>
	isFormBuilder = true;

	jQuery(document).ready(function() {
		jQuery("##mura-templatebuilder").templatebuilder();
	});
</script>

	<div id="mura-templatebuilder" data-url="#$.globalConfig('context')##$.globalConfig('adminDir')#/">
		<div class="mura-tb-menu">
			<ul class="mura-tb-form-menu">
			<li><div class="ui-button button-field" id="button-form" data-object="section-form" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.form.tooltip')#"><span class="ui-button-text">#application.rbFactory.getKeyValue(session.rb,'formbuilder.form')#</span></div></li>
			<li class="spacer"></li>
			</ul>
			<ul class="mura-tb-field-menu">
			<li><div class="ui-button button-field" id="button-section" data-object="section-section" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.section.tooltip')#"><span class="ui-button-text ui-icon-formfield-section">#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.section')#</span></div></li>
			<li class="spacer"></li>
			<li><div class="ui-button button-field" id="button-textfield" data-object="field-textfield" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.textfield.tooltip')#"><span class="ui-icon ui-icon-formfield ui-icon-formfield-textfield"></span></div></li>
			<li><div class="ui-button button-field" id="button-textarea" data-object="field-textarea" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.textarea.tooltip')#"><span class="ui-icon ui-icon-formfield ui-icon-formfield-textarea"></span></div></li>
			<li><div class="ui-button button-field" id="button-hidden" data-object="field-hidden" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.hidden.tooltip')#"><span class="ui-icon ui-icon-formfield ui-icon-formfield-hidden"></span></div></li>
			<li><div class="ui-button button-field" id="button-radio" data-object="field-radio" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.radio.tooltip')#"><span class="ui-icon ui-icon-formfield ui-icon-formfield-radiobox"></span></div></li>
			<li><div class="ui-button button-field" id="button-checkbox" data-object="field-checkbox" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.checkbox.tooltip')#"><span class="ui-icon ui-icon-formfield ui-icon-formfield-checkbox"></span></div></li>
			<li><div class="ui-button button-field" id="button-dropdown" data-object="field-dropdown" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.dropdown.tooltip')#"><span class="ui-icon ui-icon-formfield ui-icon-formfield-select"></span></div></li>
			<li><div class="ui-button button-field" id="button-file" data-object="field-file" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.file.tooltip')#"><span class="ui-icon ui-icon-formfield ui-icon-formfield-file"></span></div></li>
			<li><div class="ui-button button-field" id="button-textblock" data-object="field-textblock" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.textblock.tooltip')#"><span class="ui-icon ui-icon-formfield ui-icon-formfield-textblock"></span></div></li>
			<li><div class="ui-button button-field" id="button-nested" data-object="field-nested" title="#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.nested.tooltip')#"><span class="ui-icon ui-icon-formfield ui-icon-formfield-nested"></span></div></li>
			</ul>
		</div>
		<div id="mura-tb-form">
			<div id="mura-tb-form-pages">
					Page
				<ul id="mura-form-pages">
				</ul>
				<div id="mura-form-addpage">+</div>
			</div>
			<div id="mura-tb-form-fields">
				<div id="mura-tb-fields-empty" class="help-block">#application.rbFactory.getKeyValue(session.rb,'formbuilder.fields.empty')#</div>
				<ul id="mura-tb-fields">
				</ul>
			</div>
			<div id="mura-tb-fields-settings">
				<div id="mura-tb-field-form" class="mura-tb-data-form">
					<div id="mura-tb-field-empty" class="help-block">#application.rbFactory.getKeyValue(session.rb,'formbuilder.field.empty')#</div>
					<div id="mura-tb-field">
					</div>
				</div>
				<div id="mura-tb-dataset-form" class="mura-tb-data-form">
				</div>
				<div id="mura-tb-grid">
				</div>
			</div>
			<div style="clear:both;"></div>
		</div>

	</div>
	<textarea id="mura-formdata" name="body">#replace(rc.contentBean.getBody(),"&quot;","\""","all")#</textarea>

	<script>
		hideBodyEditor=function(){
			jQuery("##mura-templatebuilder").hide();
		}

		showBodyEditor=function(){
			jQuery("##mura-templatebuilder").show();
		}

		<cfif not isExtended>
		jQuery(document).ready(function(){
			showBodyEditor();
		});
		</cfif>
	</script>
</cfoutput>
