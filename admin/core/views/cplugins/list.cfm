<!--- license goes here --->
<cfoutput>

<div class="mura-header">
	<h1>#application.rbFactory.getKeyValue(session.rb,"plugin.siteplugins")#</h1>
	<cfinclude template="dsp_secondary_menu.cfm">
</div> <!-- /.mura-header -->

<cfset started=false>
	<div class="block block-constrain">
	<ul class="mura-tabs nav-tabs" data-toggle="tabs">
		<li class="active"><a href="##tab#ucase('Application')#" onclick="return false;"><span>Application</span></a></li>
		<li><a href="##tab#ucase('Utility')#" onclick="return false;"><span>Utility</span></a></li>
		<cfloop collection="#rc.plugingroups#" item="local.category" >
			<cfif not listFind("Application,Utility",local.category) and rc.plugingroups[local.category].recordCount>
				<li><a href="##tab#ucase(replace(local.category,' ','','all'))#" onclick="return false;"><span>#esapiEncode('html',local.category)#</span></a></li>
			</cfif>
		</cfloop>
		</ul>
		<div class="tab-content block-content">
			<cfset rscategorylist = rc.plugingroups['Application']/>
			<cfset local.category = "Application" />
			<cfinclude template="dsp_table.cfm" />
			<cfset rscategorylist = rc.plugingroups['Utility']/>
			<cfset local.category = "Utility" />
			<cfinclude template="dsp_table.cfm" />
			<cfloop collection="#rc.plugingroups#" item="local.category" >
				<cfif not listFind("Application,Utility",local.category) and rc.plugingroups[local.category].recordCount>
					<cfset rscategorylist = rc.plugingroups[local.category]/>
					<cfinclude template="dsp_table.cfm" />
				</cfif>
			</cfloop>
		</div>
	</div> <!-- /.block-constrain -->
</cfoutput>
