/* license goes here */
component extends="mura.bean.beanORM" table="tentitytagassign" entityname="entityTagAssign" displayName="Tag Assignment" orderby="tag" public=true{

    property name="assignmentid" fieldtype="id";
    property name="site" fieldtype="many-to-one" cfc="site" fkcolumn="siteid";
    property name="tag" fieldtype="index" datatype="varchar" length=200 required=true;
    property name="entityid" fieldtype="index" datatype="varchar" length=35 required=true;
    property name="entitytype" datatype="varchar" length=100 required=true;
    property name="tagroup" datatype="varchar" length=100;
   
}