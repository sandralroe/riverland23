component extends="mura.bean.beanORM" table="tproxyevent" entityName="proxyEvent" scaffold=false bundleable=true {
    property name="eventid" fieldtype="id";
    property name="site" fieldtype="many-to-one" relatesto="site" fkcolumn="siteid" required=true;
    property name="proxy" fieldtype="many-to-one" relatesto="proxy" fkcolumn="proxyid";
    property name="name" datatype="varchar" required=true length="200" maxlength="200";
    property name="created" ormtype="timestamp";
    property name="lastupdate" datatype="timestamp";
    property name="lastupdateby" datatype="varchar" length=50;
    property name="lastupdatebyid" datatype="varchar" length=35;
   
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