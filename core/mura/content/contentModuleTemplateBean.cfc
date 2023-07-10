component extends="mura.bean.beanORM"
    table="tcontentmoduletemplate"
    entityname="moduletemplate"
    orderby="name asc"
    bundleable=true
    hint="This provides module templates" {
    
    property name="templateid" fieldtype="id";
    property name="site" fieldtype="many-to-one" cfc="site" fkcolumn="siteid";
    property name="name" fieldtype="index" datatype="varchar" length="250";
    property name="params" datatype="text";
   
    function save() {
        var rejex = '[0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{16}';
        var params=get('params');
        
        if(isJSON(params)) {
            params = deserializeJSON(params);
        }

        deserializeItems(params);
 
        if(structKeyExists(params,"instanceid")) {
            params.instanceid = createUUID();
        }

        set('params',serializeJSON(params));

        super.save();

        return this;
    }
    
    private function deserializeItems( data ) {
        if(structKeyExists(arguments.data,"items") && isJSON(arguments.data.items)) {
            arguments.data.items = deserializeJSON(arguments.data.items);
            if(isArray(arguments.data.items)) {
                for(var x = 1;x <=ArrayLen(arguments.data.items);x++) {
                    deserializeItems(arguments.data.items[x]);
                    if(structKeyExists(arguments.data.items[x],"instanceid")) {
                        arguments.data.items[x].instanceid = createUUID();
                    }
                }
            }
        }
    }
}
