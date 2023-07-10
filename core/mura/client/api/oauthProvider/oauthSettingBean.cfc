component extends="mura.bean.beanORM" entityName='oauthSetting' table="toauthsettings" bundleable="true" hint="This provides OAuth Settings CRUD functionality" {
    property name="oauthsettingid" fieldtype="id";
    property name="site" fieldtype="one-to-one" cfc="site" fkcolumn="siteid" required=true;
    property name="alloweddomain" datatype="varchar" length=255;
    property name="allowedadmindomain" datatype="varchar" length=255;
    property name="allowedadmingroupemaillist" datatype="varchar" length=255;
    property name="alloweds2emaillist" datatype="varchar" length=255;
    property name="created" ormtype="timestamp";
    property name="lastupdate" datatype="timestamp";
    property name="lastupdateby" datatype="varchar" length=50;
    property name="lastupdatebyid" datatype="varchar" length=35;
    
}
