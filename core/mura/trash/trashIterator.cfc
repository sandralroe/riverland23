/* license goes here */
/**
 * This provides trash iterating functionality
 */
component extends="mura.iterator.queryIterator" output="false" hint="This provides trash iterating functionality" {

	public function packageRecord() output=false {
		var trashItem=new trashItemBean();
		trashItem.setAllValues(queryRowToStruct(variables.records,currentIndex()));
		trashItem.setTrashManager(variables.trashManager);
		if ( isObject(variables.recordTranslator) ) {
			trashItem.setTranslator(variables.recordTranslator);
		}
		return trashItem;
	}

	public function setTrashManager(trashManager) output=false {
		variables.trashManager=arguments.trashManager;
		return this;
	}

}
