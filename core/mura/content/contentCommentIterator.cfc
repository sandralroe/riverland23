/* license goes here */
/**
 * This provides content comment iterating functionality
 */
component extends="mura.iterator.queryIterator" output="false" hint="This provides content comment iterating functionality" {
	variables.commentBean="";
	variables.recordIDField="commentid";

	public function packageRecord() output=false {
		if ( !isObject(variables.commentBean) ) {
			variables.commentBean=getBean('comment');
			variables.commentStructTemplate=structCopy(variables.commentBean.getAllValues());
		} else {
			variables.commentBean.setAllValues( structCopy(variables.commentStructTemplate) );
		}
		variables.commentBean.set(queryRowToStruct(variables.records,currentIndex()));
		return variables.commentBean;
	}

}
