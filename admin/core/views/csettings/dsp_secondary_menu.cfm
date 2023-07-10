<!--- license goes here --->

<ul class="nav nav-pills">
<cfswitch expression="#rc.originalfuseaction#">
<cfcase value="list">
<li><a href="./?muraAction=cSettings.edit&siteid=">Add New Site</a></li>
</cfcase>
</cfswitch>
</ul>