component extends="mura.bean.bean" {

   
    variables.queryBuilder.pendingParam={};
    variables.queryBuilder.urlScope={};
    variables.queryBuilder.resourcepath="";

    function init(){
		super.init(argumentCollection=arguments);
        variables.instance.siteid="";
        return this;
    }

    function getProxyId(){
		param name="application.objectMappings.#variables.entityName#.proxyid" default="";
		return application.objectMappings[variables.entityName].proxyid;
	}

    function addParam(){
        if(isValid('variableName',variables.queryBuilder.pendingParam.param)){
            if(variables.queryBuilder.pendingParam.param == 'resourcepath'){
                variables.queryBuilder.resourcepath=variables.queryBuilder.pendingParam.criteria;
            } else {
                variables.queryBuilder.urlScope['#variables.queryBuilder.pendingParam.param#']=variables.queryBuilder.pendingparam.criteria;
            }
        }
        return this;
    }
        
    function where(param) output=false {
		if ( isDefined('arguments.param') ) {
			andProp(argumentCollection=arguments);
		}
		return this;
	}

	function prop(param) output=false {
		andProp(argumentCollection=arguments);
		return this;
	}

	function andProp(param) output=false {
		variables.queryBuilder.pendingParam.relationship='and';
		variables.queryBuilder.pendingParam.param=arguments.param;
		return this;
	}

    function isEQ(criteria) output=false {
		variables.queryBuilder.pendingParam.criteria=arguments.criteria;
		addParam();
		variables.queryBuilder.pendingParam={};
		return this;
	}

    function getFeed(){
        return this;
    }
    function getIsProxiedEntity(){
        return true;
    }

    function getManageSchema(){
		return false;
	}

	function getPrimaryKey(){
		return application.objectMappings[variables.entityName].primaryKey;
	}

    function getIterator(){
        var proxyid=getProxyId();

        if(!len(proxyid)){
            throw;
        } else {
            if(isValid('uuid',proxyid)){
                var loadArgs={proxyid=proxyid,siteid=get('siteid')};
            } else {
                var loadArgs={resource=proxyid,siteid=get('siteid')}
            }
        }
       
        var proxy=getBean('proxy').loadBy(argumentCollection=loadArgs);

        if(!proxy.exists()){
            throw;
        } else {
            var result=proxy.call(urlScope=variables.queryBuilder.urlScope,formScope={},resourcepath=variables.queryBuilder.resourcePath);
            var iterator=new mura.bean.beanIterator();
            iterator.setEntityName(getEntityName());
            
            if(isJson(result)){
                result=deserializeJSON(result);
            }
        
            if(!isSimpleValue(result)){
                if(isJson(result)){
                    result=deserializeJSON(result);
                }
                packageResponse(result,iterator);
            } else {
                iterator.setArray([]);
            }

            return iterator;
        }
    }

    function loadBy(siteid){
        var iterator=where().prop(get('primaryKey')).isEQ(arguments[get('primaryKey')]).getIterator();
        if(iterator.hasNext()){
            set(iterator.next().getAllValues());
        }
        return this;
    }

    function packageResponse(response,iterator){
        if(isArray(arguments.response)){
            iterator.setArray(arguments.response);
        } else if(isDefined('arguments.response.data') && isArray(arguments.response.data)){
            iterator.setArray(arguments.response.data);
        } else if(isDefined('arguments.response.data.items') && isArray(arguments.response.data.items)){
            iterator.setArray(arguments.response.data.items);
        } else {
            iterator.setArray([arguments.response]);
        }
    }

    function save(){
        throw;
    }

    function delete(){
        throw;
    }

}