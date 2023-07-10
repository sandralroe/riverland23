<!--- License goes here --->
<cfoutput>
	<div class="ui-tabs">
		<ul class="ui-tabs-nav">
			<li title="#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.edit')#" class="ui-state-active ui-corner-top ui-tabs-selected"><a href="javascript:void(null);"><span>Source</span></a></li>
			<li id="button-grid-grid" class="ui-state-default ui-corner-top"><a href="javascript:void(null);"><span>List</span></a></li>
		</ul>
			<div class="ui-tabs-panel" id="mura-tb-form-tab-source">
			<div id="mura-tb-dataset" class="mura-tb-form">

					<ul class="template-form">
						<li class="mura-tb-grp-sourcetype">
							<label for="dataset">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sourcetype')#</label>
							<select class="select" name="sourcetype" id="mura-tb-dataset-sourcetype">
								<option value="entered">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sourcetype.entered')#</option>
								<option value="dsp">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sourcetype.dsp')#</option>
								<option value="object">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sourcetype.object')#</option>
								<!---<option value="muraorm" id="dataset-source-muraorm">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sourcetype.muraorm')#</option>--->
								<option value="remote">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sourcetype.remote')#</option>
							</select>
						</li>

						<li class="mura-tb-dsi mura-tb-grp-entered" style="display: none">
							<label for="dataset">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.issorted')#</label>
							<select class="select" name="issorted" id="mura-tb-dataset-issorted">
								<option value="0">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.issorted.manual')#</option>
								<option value="1">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.issorted.sorted')#</option>
							</select>
						</li>
						<li class="mura-tb-dsi mura-tb-grp-sorted" style="display: none">
							<label for="dataset">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sorttype')#</label>
							<select class="select" name="sorttype" id="mura-tb-dataset-sorttype">
								<option value="string">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sorttype.string')#</option>
								<option value="numeric">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sorttype.numeric')#</option>
								<option value="date">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sorttype.date')#</option>
							</select>
						</li>
						<li class="mura-tb-dsi mura-tb-grp-sorted" style="display: none">
							<label for="dataset">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sortcolumn')#</label>
							<select class="select" name="sortcolumn" id="mura-tb-dataset-sortcolumn">
								<option value="label">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sortcolumn.label')#</option>
								<option value="value">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sortcolumn.value')#</option>
							</select>
						</li>
						<li class="mura-tb-dsi mura-tb-grp-sorted" style="display: none">
							<label for="dataset">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sortdirection')#</label>
							<select class="select" name="sortdirection" id="mura-tb-dataset-sortdirection">
								<option value="asc">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sortdirection.asc')#</option>
								<option value="desc">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.sortdirection.desc')#</option>
							</select>
						</li>
						<li class="mura-tb-dsi mura-tb-grp-source" style="display: none">
							<label for="dataset">#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.source')#</label>
							<input class="text tb-source" id="mura-tb-dataset-source" type="text" name="source" value="" maxlength="250" />
						</li>
					</ul>
					<div class="btn-wrap">
						<input type="button" class="btn" name="save-dataset" id="mura-tb-save-dataset" value="#mmRBF.getKeyValue(session.rb,'formbuilder.dataset.update')#" />
					</div>
				</div>
			</div>

		</div>
</cfoutput>
