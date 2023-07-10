/* license goes here */
/**
 * This provides category iterating functionality
 */
component extends="mura.bean.beanIterator" output="false" hint="This provides category iterating functionality" {

	public function init() output=false {
		super.init(argumentCollection=arguments);
		variables.entityname="categoryBean";
		return this;
	}

}
