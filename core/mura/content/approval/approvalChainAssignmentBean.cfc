/* license goes here */
component extends="mura.bean.beanORM" table="tapprovalassignments" bundleable=false hint="This provides approval chain assignment functionality" {

	property name="assignmentID" fieldtype="id";
    property name="approvalChain" fieldtype="many-to-one" cfc="approvalChain" fkcolumn="chainID";
    property name="content" callbackname="asssignments" fieldtype="many-to-one" cfc="content" fkcolumn="contentID";
    property name="site" fieldtype="many-to-one" cfc="site" fkcolumn="siteID";
    property name="exemptID" ormtype="text";

}
