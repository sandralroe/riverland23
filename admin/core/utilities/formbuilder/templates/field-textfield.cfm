<!--- License goes here --->
<cfoutput><span>
		<div class="mura-tb-form">
			<div class="mura-tb-header textfield">
				<h2><!---#mmRBF.getKeyValue(session.rb,'formbuilder.field.textfield')#:---><span id="mura-tb-form-label"></span></h2>
				<ul class="mura-tb-nav-utility">
					<li><div id="button-trash" title="#mmRBF.getKeyValue(session.rb,'formbuilder.delete')#"></div></li>
				</ul>
			</div>
			
			<div class="ui-tabs" id="ui-tabs">
			
			<ul class="ui-tabs-nav">
				<li class="ui-state-default ui-corner-top"><a href="##mura-tb-form-tab-basic"><span>Basic</span></a></li>
				<li class="ui-state-default ui-corner-top"><a href="##mura-tb-form-tab-advanced"><span>Advanced</span></a></li>
				<li class="ui-state-default ui-corner-top"><a href="##mura-tb-form-tab-validation"><span>Validation</span></a></li>
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
			
			<div class="ui-tabs-panel" id="mura-tb-form-tab-advanced">	
					<ul class="template-form">
						<li>
							<label for="size">#mmRBF.getKeyValue(session.rb,'formbuilder.field.size')#</label>
							<input class="text " type="text" name="size" value="" maxlength="50" data-required='false' />
						</li>
						<li>
							<label for="cssid">#mmRBF.getKeyValue(session.rb,'formbuilder.field.cssid')#</label>
							<input class="text " type="text" name="cssid" value="" maxlength="50" data-required='false' />
						</li>
						<li>
							<label for="cssclass">#mmRBF.getKeyValue(session.rb,'formbuilder.field.cssclass')#</label>
							<input class="text " type="text" name="cssclass" value="" maxlength="50" data-required='false' />
						</li>
						<li>
							<label for="wrappercssclass">#mmRBF.getKeyValue(session.rb,'formbuilder.field.wrappercssclass')#</label>
							<input class="text " type="text" name="wrappercssclass" value="" maxlength="50" data-required='false' />
						</li>
						<li>
							<label for="placeholder">#mmRBF.getKeyValue(session.rb,'formbuilder.field.placeholder')#</label>
							<input class="text " type="text" name="placeholder" value="" maxlength="255" data-required='false' />
						</li>
						<li>
							<label for="tooltip">#mmRBF.getKeyValue(session.rb,'formbuilder.field.tooltip')#</label>
							<textarea name="tooltip" value="" maxlength="250" ></textarea>
						</li>
					</ul>
			</div>
			
			<div class="ui-tabs-panel" id="mura-tb-form-tab-validation">
					<ul class="template-form">
						<li>
							<label for="validatetype">#mmRBF.getKeyValue(session.rb,'formbuilder.field.validatetype')#</label>
							<select class="select" name="validatetype">
								<option value="">#mmRBF.getKeyValue(session.rb,'formbuilder.field.validate.none')#</option>
								<option value="numeric">#mmRBF.getKeyValue(session.rb,'formbuilder.field.validate.numeric')#</option>
								<option value="date">#mmRBF.getKeyValue(session.rb,'formbuilder.field.validate.date')#</option>
								<option value="email">#mmRBF.getKeyValue(session.rb,'formbuilder.field.validate.email')#</option>
								<option value="regex">#mmRBF.getKeyValue(session.rb,'formbuilder.field.validate.regex')#</option>
							</select>
						</li>
						<li>
							<label for="validateregex">#mmRBF.getKeyValue(session.rb,'formbuilder.field.validateregex')#</label>
							<input class="text long" type="text" name="validateregex" value="" maxlength="350" />
						</li>
						<li>
							<label for="validatemessage">#mmRBF.getKeyValue(session.rb,'formbuilder.field.validatemessage')#</label>
							<input class="text long" type="text" name="validatemessage" value="" maxlength="250" />
						</li>
						<li class="checkbox">
							<label for="isrequired">
							#mmRBF.getKeyValue(session.rb,'formbuilder.field.isrequired')#</label>
							<input type="checkbox" name="isrequired" value="1">
						</li>
					</ul>
				</div>
			</div>
		</div>
	</span>
</cfoutput>
