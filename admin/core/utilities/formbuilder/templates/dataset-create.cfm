<!--- license goes here --->
<cfoutput>
<span>
		<div id="dataset-create" class="mura-template-form">
			<h2>#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.form')#: <span id="mura-template-form-label"></span></h2>
					<ul class="template-form">
						<li>
							<label for="dataset">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset')#</label>
							<select class="select" name="datasetid">
								<option value="">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.chooseone')#</option>
								<option value="4FA62B2D-3A29-44B1-8603FB892C60014B">Big Long Honking Name Shirt Sizes</option>
								<option value="77917A42-28F4-4BA4-B88732109F9A05C5">Colors</option>
							</select>
							<input type="button" class="button ui-icon ui-icon-check" name="set-dataset" value="#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.set')#" />
						</li>
						<li>
							<label for="filter">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.filter')#</label>
							<input class="text medium" type="text" name="filter" id="dataset-filter" value="" maxlength="50" />
							<input type="button" class="button ui-icon ui-icon-check" name="set-filter" value="" />
						</li>
					</ul>
					<div class="btn-wrap">
					<input type="button" class="btn" name="new-datasource" value="#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.createnew')#" />
					</div>
		</div>
	</span>
</cfoutput>