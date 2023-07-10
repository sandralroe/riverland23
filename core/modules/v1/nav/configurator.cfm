 <!--- license goes here --->
<cfsilent>
	<cfset rc.rsObjects = application.contentManager.getSystemObjects(rc.siteid)/>
	<cfquery name="rc.rsObjects" dbtype="query">
		select * from rc.rsObjects where object like '%nav%'
	</cfquery>
	<cfset content=rc.$.getBean("content").loadBy(contentID=rc.objectid)>
	<cfparam name="objectParams.taggroup" default="">
</cfsilent>
<cf_objectconfigurator>
<cfoutput>
	<div class="mura-layout-row">
		<div class="mura-control-group">
			<label class="mura-control-label">#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.selectnavigation')#</label>
			<select id="objectselector" name="object" class="objectParam">
				<option value="">
					#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.selectnavigation')#
				</option>
				<cfloop query="rc.rsObjects">
					<option <cfif rc.object eq rc.rsobjects.object>selected </cfif>title="#esapiEncode('html_attr',rc.rsObjects.name)#" value="#esapiEncode('javascript',rc.rsobjects.object)#">
						#esapiEncode('html',rc.rsObjects.name)#
					</option>
				</cfloop>
				<option <cfif rc.object eq 'archive_nav'>selected </cfif>title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.archivenavigation'))#" value="archive_nav">
					#esapiEncode('html',application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.archivenavigation'))#
				</option>
				<option <cfif rc.object eq 'category_summary'>selected </cfif>title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.categorysummary'))#" value="category_summary">
					#esapiEncode('html',application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.categorysummary'))#
				</option>
				<option <cfif rc.object eq 'calendar_nav'>selected </cfif>title="#esapiEncode('html_attr',application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.calendarnavigation'))#" value="calendar_nav">
					#esapiEncode('html',application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.calendarnavigation'))#
				</option>
				<option <cfif rc.object eq 'tag_cloud'>selected </cfif>title="Tag Cloud" value="tag_cloud">
					#application.rbFactory.getKeyValue(session.rb, 'sitemanager.content.fields.tagcloud')#
				</option>
			</select>
		</div>
	</div>
	<div class="mura-layout-row" id="taggroupcontainer" style="display:none">
		<div class="mura-control-group">
			<label class="mura-control-label">
				#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.selecttaggroup')#
			</label>
			<select name="taggroup" class="objectParam">
				<option value="">Default</option>
				<cfif len(rc.$.siteConfig('customTagGroups'))>
					<cfloop list="#rc.$.siteConfig('customTagGroups')#" index="g" delimiters="^,">
						<option value="#g#" <cfif g eq objectParams.taggroup>selected</cfif>>#g#</option>
					</cfloop>
				</cfif>
			</select>
		</div>
	</div>
	<input name="objectid" type="hidden" class="objectParam" value="#esapiEncode('html_attr',rc.contentid)#">
	<script>
		$(function(){
			function toggleTagGroups(){
				if($('##objectselector').val() == 'tag_cloud'){
					$('##taggroupcontainer').show();
				} else {
					$('##taggroupcontainer').hide();
				}
			}

			toggleTagGroups();
			$('##objectselector').change(toggleTagGroups);

		});
	</script>
</cfoutput>
</cf_objectconfigurator>
