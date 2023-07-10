/* license goes here */
/**
 * This provides legacy custom extended object iterating functionality
 */
component extends="mura.iterator.queryIterator" output="false" hint="This provides legacy custom extended object iterating functionality" {
	variables.configBean="";
	variables.manager="";

	public function init(configBean="") output=false {
	
		super.init(argumentCollection=arguments);
		if ( isObject(arguments.configBean) ) {
			setConfigBean(arguments.configBean);
		}
	
		return this;
	}

	public function setConfigBean(configBean) output=false {
		variables.configBean=arguments.configBean;
		return this;
	}

	public function setManager(manager) output=false {
		variables.manager=arguments.manager;
		return this;
	}

	public function packageRecord() output=false {
		var extendObject="";
		extendObject=new extendObject(
			Type=variables.records.type[currentIndex()],
			SubType=variables.records.subtype[currentIndex()],
			SiteID=variables.records.SiteID[currentIndex()],
			configBean=variables.configBean,
			ID=variables.records.ID[currentIndex()],
			manager=variables.manager,
			sourceIterator=this);
		if ( isObject(variables.recordTranslator) ) {
			extendObject.setTranslator(variables.recordTranslator);
		}
		return extendObject;
	}

}
