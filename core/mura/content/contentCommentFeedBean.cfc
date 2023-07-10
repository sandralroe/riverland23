/* license goes here */
/**
 * This provides content comment feed functionality
 */
component extends="mura.bean.beanFeed" output="false" hint="This provides content comment feed functionality" {
	property name="entityName" type="string" default="comment" required="true";
	property name="table" type="string" default="tcontentcomments" required="true";
	property name="keyField" type="string" default="commentID" required="true";
	property name="siteID" type="string" default="" required="true";
	property name="sortBy" type="string" default="entered" required="true";
	property name="sortDirection" type="string" default="asc" required="true";

	public function init() output=false {
		super.init(argumentCollection=arguments);
		variables.instance.siteID="";
		variables.instance.entityName="comment";
		variables.instance.table="tcontentcomments";
		variables.instance.keyField="commentID";
		variables.instance.sortBy="entered";
		variables.instance.sortDirection="asc";
		variables.instance.params=queryNew("param,relationship,field,condition,criteria,dataType","integer,varchar,varchar,varchar,varchar,varchar" );
		return this;
	}

}
