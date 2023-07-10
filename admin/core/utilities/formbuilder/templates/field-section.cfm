<!--- License goes here --->
<cfoutput><span>
		<div class="mura-tb-form" id="formblock-${fieldid}">
			<div class="mura-tb-header">
				<h2><!---#mmRBF.getKeyValue(session.rb,'formbuilder.field.section')#:---> <span id="mura-tb-form-label"></span></h2>
				<ul class="mura-tb-nav-utility">
					<li><div id="button-trash" title="#mmRBF.getKeyValue(session.rb,'formbuilder.delete')#"></div></li>
				</ul>
			</div>
			<ul class="template-form">
				<li>
					<label for="label">#mmRBF.getKeyValue(session.rb,'formbuilder.field.label')#</label>
					<input class="text  tb-label" type="text" name="label" value="" data-label="true">
				</li>
				<li>
					<label for="name">#mmRBF.getKeyValue(session.rb,'formbuilder.field.name')#</label>
					<input id="tb-name" class="text  disabled" name="name" type="text" value="" maxlength="50" disabled="true" />
				</li>
			</ul>
		</div>
	</span>
</cfoutput>
