/* license goes here */
/**
 * This provides category feed functionality
 */
component extends="mura.bean.beanFeed" output="false" hint="This provides category feed functionality" {
	property name="bean" type="string" default="category" required="true";
	property name="table" type="string" default="tcontentcategories" required="true";
	property name="keyField" type="string" default="categoryID" required="true";
	property name="siteID" type="string" default="" required="true";
	property name="sortBy" type="string" default="name" required="true";
	property name="sortDirection" type="string" default="asc" required="true";

	public function init() output=false {
		super.init(argumentCollection=arguments);
		variables.instance.siteID="";
		variables.instance.entityName="category";
		variables.instance.table="tcontentcategories";
		variables.instance.keyField="categoryID";
		variables.instance.sortBy="name";
		variables.instance.sortDirection="asc";
		variables.instance.params=queryNew("param,relationship,field,condition,criteria,dataType","integer,varchar,varchar,varchar,varchar,varchar" );
		return this;
	}

}
