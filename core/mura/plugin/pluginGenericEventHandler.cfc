/* license goes here */
/**
 * Thid provides base plugin event handling functionality
 */
component extends="mura.baseobject" output="false" hint="Thid provides base plugin event handling functionality" {

	public function init(required pluginConfig, required configBean) output=false {
		variables.pluginConfig=arguments.pluginConfig;
		variables.configBean=arguments.configBean;
		return this;
	}

	/**
	 * gets the objectid associated with the passed in display object
	 */
	private function renderPluginDisplayObject(required string object, required component event) output=false {
		var rsObjID = "";
		return getPluginManager().displayObject(arguments.object , arguments.event, pluginConfig.getModuleID() );
	}

}
