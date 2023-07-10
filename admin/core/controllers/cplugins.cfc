/* license goes here */
component extends="controller" output="false" {

	public function setPluginManager(pluginManager) output=false {
		variables.pluginManager=arguments.pluginManager;
	}

	public function before(rc) output=false {
		if ( !listFind(session.mura.memberships,'S2') ) {
			secure(arguments.rc);
		}
	}

	public function list(rc) output=false {
		arguments.rc.rslist=variables.pluginManager.getSitePlugins(siteID=arguments.rc.siteid, applyPermFilter=true);
		arguments.rc.plugingroups=variables.pluginManager.getSitePluginGroups(arguments.rc.rslist);
	}

}
