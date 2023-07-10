component extends="mura.bean.beanORM" table="tlambdaenv" entityName="lambdaenv" bundleable="true" {
    property name="envid" fieldtype="id";
    property name="lambda" fieldtype="many-to-one" relatesto="lambda" fkcolumn="lambdaid";
    property name="name" datatype="varchar" required=true length="200";
    property name="created" ormtype="timestamp";
    property name="lastupdate" datatype="timestamp";
    property name="lastupdateby" datatype="varchar" length=50;
    property name="lastupdatebyid" datatype="varchar" length=35;
    property name="data" datatype="text" encrypted=true required=true;

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