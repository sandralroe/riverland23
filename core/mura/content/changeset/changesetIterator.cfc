/* license goes here */
/**
 * This provides changeset iterating functionality
 */
component extends="mura.bean.beanIterator" output="false" hint="This provides changeset iterating functionality" {
	variables.changesetBean="";
	variables.recordIDField="changesetID";

	public function packageRecord() output=false {
		if ( !isObject(variables.changesetBean) ) {
			variables.changesetBean=getBean('changeset');
			variables.changesetStructTemplate=structCopy(variables.changesetBean.getAllValues());
		} else {
			variables.changesetBean.setAllValues( structCopy(variables.changesetStructTemplate) );
		}
		variables.changesetBean.set(queryRowToStruct(variables.records,currentIndex()));
		return variables.changesetBean;
	}

}
