/* license goes here */
component extends="mura.bean.beanORM"
	table="tcontentfilenamearchive"
	entityName="contentFilenameArchive"
	bundleable=true
	hint="This provides content filename archiving" {

	property name="archiveid" fieldtype="id";
	property name="content" fieldtype="many-to-one" cfc="content" fkcolumn="contentID";
	property name="site" fieldtype="many-to-one" cfc="site" fkcolumn="siteID";
	property name="filename" fieltype="index" type="varchar" length=255;

	//Don't include in bundles and clear out existing with empty query
	function toBundle(bundle,siteid,includeVersionHistory=false,contenthistid){
		var qs=getQueryService();
		qs.setSQL("select * from #getTable()# where 0=1");
		arguments.bundle.setValue("rs" & getTable(),qs.execute().getResult());
		return this;
	}

	function persistToVersion(previousBean,newBean,$){
		if(
			arguments.newBean.getContentID() == arguments.previousBean.getContentID()
		){
			return true;
		} else {
			return false;
		}
	}

}
