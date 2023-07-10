<!--- license goes here --->
<cfset request.layout=false>
<cfparam name="request.quickeditscheduler" default="false">
<cfset $=application.serviceFactory.getBean("MuraScope").init(session.siteID)>
<cfset content=$.getBean("content").loadBy(contentID=rc.contentID)>
<script>
	$('.mura-quickEdit select').niceSelect();
</script>
<cfif not content.hasDrafts()>
	<cfoutput>
	<h1>#application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.edit#rc.attribute#')#</h1>
	<span class="cancel" onclick="siteManager.closeQuickEdit();" title="#application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.cancel')#"><i class="mi-close"></i></span>

	<cfif rc.attribute eq "isnav">
		<select id="mura-quickEdit-isnav">
			 <option value="1"<cfif content.getIsNav()> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.true')#</option>
			 <option value="0"<cfif not content.getIsNav()> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.false')#</option>
		</select>
	<cfelseif rc.attribute eq "inheritObjects">
		<select id="mura-quickEdit-inheritobjects">
			<option value="Inherit"<cfif content.getInheritObjects() eq "Inherit"> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.inheritcascade')#</option>
			<option value="Cascade"<cfif content.getInheritObjects() eq "Cascade"> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.startnewcascade')#</option>
			<option value="Reject"<cfif content.getInheritObjects() eq "Reject"> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.donotinheritcascade')#</option>
		</select>
	<cfelseif rc.attribute eq "template">
		<cfset rsTemplates=application.contentUtility.getTemplates(rc.siteid,content.getType()) />
		<select id="mura-quickEdit-template">
			<cfif rc.contentid neq '00000000000000000000000000000000001'>
              <cfset templateName = application.contentManager.getTemplateFromParent(content.getParent().getContentID(), rc.siteid)>
              <cfif templateName eq "">
              	<cfset templateName = application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.none')>
              </cfif>
              <option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.inherit')# (#templateName#)</option>
			</cfif>
			<cfloop query="rsTemplates">
			<cfif right(rsTemplates.name,4) eq ".cfm">
				<cfoutput>
				<option value="#rsTemplates.name#" <cfif content.gettemplate() eq rsTemplates.name>selected</cfif>>#rsTemplates.name#</option>
				</cfoutput>
			</cfif>
			</cfloop>
		</select>
		<h1>#application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.edit.childtemplate')#</h1>
		<select id="mura-quickEdit-childtemplate">
			<option value="">#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.none')#</option>
			<cfloop query="rsTemplates">
			<cfif right(rsTemplates.name,4) eq ".cfm">
				<cfoutput>
				<option value="#rsTemplates.name#" <cfif content.getchildTemplate() eq rsTemplates.name>selected</cfif>>#rsTemplates.name#</option>
				</cfoutput>
			</cfif>
			</cfloop>
		</select>
	<cfelseif rc.attribute eq "display">
		<cfparam name="session.localeHasDayParts" default="true">

		<cfoutput>
		<div class="mura-control-group">
			 <select name="display" id="mura-display">
				<option value="1"  <cfif content.getdisplay() EQ 1> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.yes')#</option>
				<option value="0"  <cfif content.getdisplay() EQ 0> selected</cfif>>#application.rbFactory.getKeyValue(session.rb,'sitemanager.no')#</option>
				<option value="2"  <cfif content.getdisplay() EQ 2> selected</CFIF>>
					#application.rbFactory.getKeyValue(session.rb,'sitemanager.content.fields.perschedule')#
				</option>
			</select>
		</div>

	<script>
	$(function(){
		<cfif rc.ptype eq 'Calendar'>
			var isCalendar=true;
		<cfelse>
			var isCalendar=false;
		</cfif>

		// open manage schedule UI in content details view
		function getScheduleURL(el){
			var u = $('##mura-quickEditor').parents('dd.display').parents('dl').find('a.title-nested, a.title').attr('href');
			return u;
		}

		$('##btn__quickedit__schedule').click(function(){
			window.location.href=getScheduleURL($(this)) + '&bigui=schedule##panel-schedule';
			return false;
		});

		//toggle quickedit contents for 'per schedule'
		$('##mura-display').change(function(){
			if($(this).val() == 2){
				<cfif request.quickeditscheduler>
					$('.mura-quickEdit').addClass("large");
				<cfelse>
					$('##btn__quickedit__save').hide();
					$('##btn__quickedit__schedule').show();
				</cfif>
			} else {
				<cfif request.quickeditscheduler>
					$('.mura-quickEdit').removeClass("large")
				<cfelse>
					$('##btn__quickedit__save').show();
					$('##btn__quickedit__schedule').hide();
				</cfif>
			}
		}).trigger('change');
	})
	</script>
	</cfoutput>
	</cfif>
	<div class="form-actions">
		<button id="btn__quickedit__save"<cfif rc.attribute eq "display" and content.getdisplay() eq 2> style="display:none;"</cfif> class="btn mura-primary" onclick="siteManager.saveQuickEdit(this);">#application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.submit')#</button>
		<button id="btn__quickedit__schedule"<cfif rc.attribute neq "display" or content.getdisplay() neq 2> style="display:none;"</cfif> type="button" class="btn mura-primary"> #application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.manageschedule')#</button>
	</div>
	</cfoutput>
<cfelse>
	<cfoutput>
	<h3 class="popover-title">#application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.hasdraftstitle')# </h3>
	<span class="cancel" onclick="siteManager.closeQuickEdit();" title="#application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.cancel')#"><i class="mi-close"></i></span>
		<div class="popover-content" id="hasDraftsMessage">
			#application.rbFactory.getKeyValue(session.rb,'sitemanager.quickedit.hasdraftsmessage')#
		</div>
	</cfoutput>
</cfif>