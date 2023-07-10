/* license goes here */
/**
 * This provides user address iterating functionality
 */
component extends="mura.bean.beanIterator" output="false" hint="This provides user address iterating functionality" {
	variables.addressBean="";
	variables.recordIDField="addressID";

	public function getEntityName() output=false {
		return "address";
	}

	public function packageRecord() output=false {
		if ( !isObject(variables.addressBean) ) {
			variables.addressBean=getBean("address");
			variables.addressStructTemplate=structCopy(variables.addressBean.getAllValues(autocomplete=false));
		} else {
			variables.addressBean.setAllValues( structCopy(variables.addressStructTemplate) );
		}
		variables.addressBean.set(queryRowToStruct(variables.records,currentIndex()));
		variables.addressBean.setValue('sourceIterator',this);
		return variables.addressBean;
	}

}
