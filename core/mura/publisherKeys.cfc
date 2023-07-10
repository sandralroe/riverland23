/* license goes here */
/**
 * This provides a utility to map old to new imported key bundles values
 */
component output="false" extends="mura.baseobject" hint="This provides a utility to map old to new imported key bundles values" {
	variables.keys="";
	variables.mode="";

	public function init(mode, utility) output=false {
		variables.utility=arguments.utility;
		variables.mode=arguments.mode;
		variables.keys=new mura.baseobject();
		return this;
	}

	public function getMode() output=false {
		return variables.mode;
	}

	public function setMode(mode) output=false {
		variables.mode=arguments.mode;
	}

	public function has(key) output=false {
		return variables.keys.hasValue(hash(arguments.key));
	}

	public function get(key, required defaultValue="#variables.utility.getUUID()#") output=false {
		if ( variables.mode == "publish" && !isNumeric(arguments.key) ) {
			return arguments.key;
		} else {
			if ( left(key,32) != '00000000000000000000000000000000' ) {
				return variables.keys.getValue(hash(arguments.key),arguments.defaultValue);
			} else {
				return key;
			}
		}
	}

}
