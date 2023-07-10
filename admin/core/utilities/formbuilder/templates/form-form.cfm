<!--- License goes here --->
<cfoutput><span>
		<div class="mura-tb-form" id="formblock-${fieldid}">
			<div class="mura-tb-header">
				<h2><span id="mura-tb-form-label">#mmRBF.getKeyValue(session.rb,'formbuilder.form')#</span></h2>
			</div>
			<ul class="template-form">
				<li>
					<label for="label">#mmRBF.getKeyValue(session.rb,'formbuilder.form.emailsubject')#</label>
					<input class="text tb-emailsubject" type="text" name="emailsubject" value="" data-label="true">
				</li>
				<li>
					<label for="name">#mmRBF.getKeyValue(session.rb,'formbuilder.form.replyto')#</label>
					<input class="text tb-replyto" type="text" name="replyto" value="" data-label="true">
				</li>
				<li>
					<label for="name">#mmRBF.getKeyValue(session.rb,'formbuilder.form.submitlabel')#</label>
					<input class="text tb-submitlabel" type="text" name="submitlabel" value="" data-label="true">
				</li>
				<li>
					<label for="name">#mmRBF.getKeyValue(session.rb,'formbuilder.form.class')#</label>
					<input class="text tb-class" type="text" name="class" value="" data-label="true">
				</li>
				<li>
					<label for="name-restricted">#mmRBF.getKeyValue(session.rb,'formbuilder.form.nameunrestricted')#</label>
					<input id="tb-name-restricted" class="text tb-class" type="checkbox" name="name-unrestricted" value="1" data-label="true"> *
				</li>
				<!---
				<li>
					<label for="muraormentities">#mmRBF.getKeyValue(session.rb,'formbuilder.form.muraormentities')#</label>
					<input id="tb-muraormentities" class="text tb-class" type="checkbox" name="muraormentities" value="1" data-label="true"> **
				</li>--->
				<input id="tb-muraormentities" class="text tb-class" type="hidden" name="muraormentities" value="0" data-label="true">

				<li>
					<div>
					*#mmRBF.getKeyValue(session.rb,'formbuilder.form.nameunrestrictedtip')#
					</div>
					<!---<div>
					**#mmRBF.getKeyValue(session.rb,'formbuilder.form.muraormentitiestip')#
				</div>--->
				</li>



			</ul>
		</div>
	</span>
</cfoutput>
