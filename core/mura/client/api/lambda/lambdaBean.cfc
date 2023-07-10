component extends="mura.bean.beanORM" table="tlambda" entityName="lambda" bundleable="true" {
    property name="lambdaid" fieldtype="id";
    property name="environment" fieldtype="one-to-many" relatesto="lambdaenv" cascade="delete";
    property name="proxies" fieldtype="one-to-many" relatesto="proxy" cascade="delete";
    property name="name" datatype="varchar" fieldtype="index" required=true length="200" maxlength="200";
    property name="package" datatype="varchar" fieldtype="index" required=true length="200" maxlength="200";
    property name="created" ormtype="timestamp";
    property name="lastupdate" datatype="timestamp";
    property name="lastupdateby" datatype="varchar" length=50;
    property name="lastupdatebyid" datatype="varchar" length=35;
    property name="data" datatype="text" encrypted=true;

    function allowAccess(mura){
		return getCurrentUser().isSuperUser();
	}

    function allowRead(){
        return getCurrentUser().isSuperUser();
    }

    function allowSave(){
        return getCurrentUser().isSuperUser();
    }

    function allowDelete(){
        return getCurrentUser().isSuperUser();
    }
}