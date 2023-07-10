/* license goes here */
/**
 * This provides plugin install, update and delete handling
 */
component extends="mura.baseobject" output="false" hint="This provides plugin install, update and delete handling" {
	variables.pluginConfig="";

	public function init(any pluginConfig="", any configBean="") output=false {
		variables.pluginConfig = arguments.pluginConfig;
		if ( isObject(arguments.configBean) ) {
			variables.configBean = arguments.configBean;
		}
	}

	public function install() output=false {
		application.appInitialized=false;
	}

	public function update() output=false {
		application.appInitialized=false;
	}

	public function delete() output=false {
		application.appInitialized=false;
	}

}
