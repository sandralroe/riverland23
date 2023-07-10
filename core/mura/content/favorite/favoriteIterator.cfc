/* license goes here */
/**
 * This provides user favorite iterating functionality
 */
component extends="mura.iterator.queryIterator" output="false" hint="This provides user favorite iterating functionality" {

	public function packageRecord() output=false {
		var favorite=getBean("favoriteBean");
		favorite.set(queryRowToStruct(variables.records,currentIndex()));
		favorite.setIsNew(0);
		return favorite;
	}

}
