 <!--- license goes here --->
<cfset request.layout=false>
<cfset currentChangeset=application.changesetManager.read(rc.changesetID)>
<cfset changesets=application.changesetManager.getIterator(siteID=rc.siteID,published=0,publishdate=now(),publishDateOnly=false,openOnly=true)>
<cfoutput>
<table class="mura-table-grid">
<tr>
<th>&nbsp;</th>
<th class="var-width">#application.rbFactory.getKeyValue(session.rb,"changesets.name")#</th>
</tr>
<cfif changesets.hasNext() or application.permUtility.getModulePerm("00000000000000000000000000000000014",session.siteid)>
<cfloop condition="changesets.hasNext()">
<cfset changeset=changesets.next()>
<tr>
<td><input name="_changesetID" type="radio" onclick="removeChangesetPrompt(this.value);" value="#changeset.getChangesetID()#"<cfif changeset.getChangesetID() eq rc.changesetid> checked="true"</cfif>/></td>
<td class="var-width">#esapiEncode('html',changeset.getName())#</td>
</tr>
</cfloop>
<tr>
<td><input name="_changesetID" id="changesetother" type="radio" onclick="removeChangesetPrompt(this.value);" value="other"/></td>
<td class="var-width"><input id="_changesetname" onclick="$('##changesetother').trigger('click');" placeholder="#application.rbFactory.getKeyValue(session.rb,'changesets.addchangeset')#"/></td>
</tr>
<tr>
<td><input name="_changesetID" type="radio" onclick="removeChangesetPrompt(this.value);" value=""<cfif not len(rc.changesetID)> checked="true"</cfif>/></td>
<td class="var-width">#esapiEncode('html',application.rbFactory.getKeyValue(session.rb,"sitemanager.content.none"))#</td>
</tr>
<cfelse>
<tr>
<td colspan="2">#application.rbFactory.getKeyValue(session.rb,'changesets.nochangesets')#</td>
</tr>
</cfif>
</table>
<div style="display:none" id="removeChangesetContainer">
<input type="checkbox" id="_removePreviousChangeset" value="true"/>&nbsp;#application.rbFactory.getResourceBundle(session.rb).messageFormat(application.rbFactory.getKeyValue(session.rb,"sitemanager.content.removechangeset"),'<em>"#esapiEncode('html_attr',currentChangeset.getName())#"</em>')#
</div>
</cfoutput>
