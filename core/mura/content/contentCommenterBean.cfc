/* license goes here */
component extends="mura.bean.beanORM" table="tcontentcommentcommenters" entityname="commenter" bundleable=true hint="deprecated"{

	property name="commenterID" fieldtype="id";
    property name="name" type="string";
    property name="email" type="string";
    property name="remoteID" fieldtype="index" type="string";

}
