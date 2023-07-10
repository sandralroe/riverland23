component extends="mura.bean.beanORM" table="tproxy" entityName="proxy" bundleable=true {
    property name="proxyid" fieldtype="id";
    property name="site" fieldtype="many-to-one" relatesto="site" fkcolumn="siteid" required=true;
    property name="lambda" fieldtype="many-to-one" relatesto="lambda" fkcolumn="lambdaid";
    property name="name" datatype="varchar" fieldtype="index" required=true length="200" maxlength="200";
    property name="resource" datatype="varchar" fieldtype="index" required=true length="200" maxlength="200";
    property name="endpoint" datatype="varchar" required=true length="200" maxlength="200";
    property name="restricted" datatype="tinyint" default=1 required=true;
    property name="restrictgroups" datatype="text";
    property name="credentials" fieldtype="one-to-many" relatesto="proxyCredential" cascade="delete";
    property name="events" fieldtype="one-to-many" relatesto="proxyEvent" cascade="delete";
    property name="created" ormtype="timestamp";
    property name="lastupdate" datatype="timestamp";
    property name="lastupdateby" datatype="varchar" length=50;
    property name="lastupdatebyid" datatype="varchar" length=35;
    
    function allowProxyAccess(){
        var currentUser=getCurrentUser();
        if(!this.getRestricted()  || currentUser.isSuperUser()){
            return true;
        }

        if(!len(this.getRestrictGroups()) && currentUser.isLoggedIn()){
            return true;   
        }
        if(this.getRestrictGroups()=='RetrictAll'){
            return false;
        } else {
            var assignments=listToArray(this.getRestrictGroups());
            for(var a in assignments){
                if(listFindNoCase(currentUser.getValue('membershipids'),a)){
                    return true;
                }
            }
        }

        return false;
    }
    function validate(){
        this.super.validate();
        var resourceCheck=getBean('proxy')
            .getFeed()
            .where()
            .prop('resource').isEQ(this.get('resource'))
            .andProp('siteid').isEQ(this.get('siteid'))
            .andProp('proxyid').isNEQ(this.get('proxyid'))
            .getIterator();

        if(resourceCheck.hasNext()){
            getErrors()["resource"]="The 'resource' property value must be unique";
        }

        return this;
    }
    function handleEvent(Mura){
        var _bean=arguments.Mura.event('bean');
       
        var e='';
        if(isObject(_bean)){
            var api=getBean('settingsManager').getSite(get('siteid')).getAPI(type="json",version='v1');
           
            var body={
                eventName= arguments.Mura.event('_eventName'),
                data=structCopy(api.getFilteredValues(entity=_bean,expanded=0,entityConfigName=_bean.getEntityName(),siteid=get('siteid'),expandLinks='',pk=_bean.getPrimaryKey(),editablecheck=false,fields="*"))
            };
          
            for(var i in body.data){
                if(isObject(body.data[i])){
                    structDelete(body.data,i);
                }
            }
        
            try {
                var response=call(body=body,httpmethod='post');
                if(isStruct(response)){
                    if(isDefined('response.data')){
                        _bean.set(response.data);
                    } else if(isDefined('response.error')){
                        if(isSimpleValue(response.error)){
                            _bean.getErrors()['#this.getResource()##arguments.Mura.event('_eventName')#']=response.error;
                        } else if (isArray(response.error)){
                            var i=1;
                            for(e in response.error){
                                _bean.getErrors()['#this.getResource()##arguments.Mura.event('_eventName')##i#']=e;
                                i++;
                            }
                        } else {
                            _bean.getErrors()['#this.getResource()##arguments.Mura.event('_eventName')#']="An error occurred in proxied event ['#this.getName()#']";
                        }
                    } else if(isDefined('response.errors') && isArray(response.errors)){
                        var i=1;
                        for(e in response.errors){
                            _bean.getErrors()['#this.getResource()##arguments.Mura.event('_eventName')##i#']=e;
                            i++;
                        }
                    }
                }
            } catch(any error){
                logError(error);
                _bean.getErrors()['#this.getName()##arguments.Mura.event('_eventName')#']="An runtime error occurred in proxied event ['#this.getName()#']";
            }
        }
    }

    function call(formScope,urlScope,cookieScope,cgiScope,body='',resourcepath='',headers=[],parse=true,httpmethod="any",isreplay=false, queryString=''){
        var httpService=getHttpService();
        var _url=this.getEndpoint();
        var forceMethod=false;
        
        if(len(arguments.queryString) && arguments.queryString != '?'){
            if(left(arguments.queryString,1)=="?"){
                arguments.queryString=right(arguments.queryString,len(arguments.queryString)-1);
            }
            for(var i in listToArray(arguments.queryString,'&')){
                var equalsPosition = Find("=", i);

                if(equalsPosition > 1){
                    var key = Left(i, equalsPosition-1);
                    var value = 'undefined';
                    
                    if(len(i) > equalsPosition){
                        value =Right(i, len(i) - equalsPosition);
                    }

                    if(!isDefined('arguments.urlScope') || !isStruct(arguments.urlScope)){
                        arguments.urlScope={};
                    }
                    arguments.urlScope[key]=value;
                } 
                
            }
        }
              
        if(len(arguments.httpmethod) && arguments.httpmethod != 'any'){
            forceMethod=true;
        }

        if(len(arguments.resourcepath)){
            _url=_url & "/" & arguments.resourcepath;
        }   
        
        //_url="http://localhost:8888/temp/echo.cfm";
        //dump(arguments.body);abort;

        if(isDefined('arguments.formScope')){
            structDelete(arguments.formScope,'fieldnames');
        }

        if(isDefined('arguments.urlScope') && isDefined('arguments.formScope')){
            for(var p in arguments.urlScope){
                if(structKeyExists(arguments.formScope,p)){
                    structDelete(arguments.formScope,p);
                }
            }
        }
        
        httpService.setURL(_url);
        httpService.setThrowOnError(false);
     
        if(arguments.httpmethod=='any'){
            var httpRequestData=getHTTPRequestData();
            if(structKeyExists(httpRequestData.headers,'X-HTTP-Method-Override')){
                arguments.httpmethod=httpRequestData.headers['X-HTTP-Method-Override'];
            } else {
                arguments.httpmethod=httpRequestData.method;
            }
        }
        
        var hasFormScope=false;
        var hasBody=!isSimpleValue(arguments.body) || isJSON(arguments.body);

        if(!hasBody && isDefined('arguments.formScope') && isStruct(arguments.formScope) && !structIsEmpty(arguments.formScope)){
            for(var field in arguments.formScope){ 
                if(field != 'fieldnames'){
                    if(arguments.httpmethod=='GET'){
                        arguments.httpmethod="POST";
                    }
                    httpService.addParam(type='formField',name=field,value=arguments.formScope['#field#']);
                    hasFormScope=true;
                }
            }
        }

        var excludeFromURL={
            'cachewithin'=true,
            'cachekey'=true,
            'purgeCache'=true,
            'cfid'=true,
            'cftoken'=true,
            'jsessionid'=true
        }
        
        if(isDefined('arguments.urlScope') && isStruct(arguments.urlScope)){
            for(var field in arguments.urlScope){
                if(!structKeyExists(excludeFromURL,'#field#')){
                    httpService.addParam(type='url',name=field,value=arguments.urlScope['#field#']);
                }
            }
        }

        if(isDefined('arguments.cookieScope') && isStruct(arguments.cookieScope)){
            for(var field in arguments.cookieScope){
                httpService.addParam(type='cookie',name=field,value=arguments.cookieScope['#field#']);
            }
        }

        if(isDefined('arguments.cgiScope') && isStruct(arguments.cgiScope)){
            for(var field in arguments.cgiScope){
                httpService.addParam(type='cgi',name=field,value=arguments.cgiScope['#field#']);
            }
        }

        if(!hasFormScope && hasBody){
            if(!isSimpleValue(arguments.body)){
                arguments.body=getBean('settingsManager')
                .getSite('default')
                .getAPI(type="json", version="v1")
                .getSerializer()
                .serialize(arguments.body);
            }
           
            if(!forceMethod && arguments.httpmethod=='GET'){
                arguments.httpmethod="POST";
            }
            
            httpService.addParam(type='body',value=arguments.body);
            httpService.addParam(type="header",name="Content-Type", value="application/json");
           
        }
       
        if(arrayLen(arguments.headers)){
            for(var header in arguments.headers){
                httpService.addParam(type="header",name=header.name,value=header.value);
            }
        }
       
        var _credentials=this.getCredentials();
        var doReplay=false;

        if(_credentials.hasNext()){
            while(_credentials.hasNext()){
                var credential=_credentials.next();
                //dump(credential.get('type') & ' ' & credential.get('name') & ' ' & credential.get('data'))
                if(listFindNoCase("OAuth2_JWT,OAuth2_Password",credential.get('type'))){
                    if(!arguments.isreplay){
                        doReplay=true;
                    }
                    param name="application.muraProxyTokens" default={};
                    if(!structKeyExists(application.muraProxyTokens,"#get('proxyid')#")){
                        if(credential.get('type')=="OAuth2_JWT"){
                            var token=getAccessTokenFromJWT(credential);
                        } else {
                            var token=getAccessTokenFromPassword(credential);
                        }
                        //Return errors for invalid calls to get token
                        if(!isSimpleValue(token)){
                            return token;
                        } else if(len(token)){
                            application.muraProxyTokens["#this.get('proxyid')#"]=token;
                        }
                    }
                    if(structKeyExists(application.muraProxyTokens,"#get('proxyid')#")){
                        httpService.addParam(type="header",name="Authorization",value="Bearer " & application.muraProxyTokens["#this.get('proxyid')#"]);
                    }
                } else {
                    httpService.addParam(type=credential.get('type'),name=credential.get('name'),value=credential.get('data'));
                    if(arguments.httpmethod=='GET' && credential.get('type')=='formField'){
                        arguments.httpmethod="POST";
                    }
                }
            }
        }
      
       // httpService.setThrowOnError(false);
        if(getBean('configBean').getCompiler()=='Lucee'){
            httpService.setEncodeurl(false);
        }
       
        httpService.addParam(type="header",name="accept", value="*/*");

        /*  
            httpService.setCompression(false);
            httpService.addParam(type='body',value="{}");
            httpService.addParam(type="header",name="Content-Type", value="application/json");
        */

        httpService.setMethod(arguments.httpmethod);

        //httpService.setGetAsBinary('auto');
        try{
            var result = httpService.send().getPrefix();
        } catch(any e){
            param name="application.muraProxyTokens" default={};
            structDelete(application.muraProxyTokens,'#get('proxyid')#');
            if(doReplay){
                arguments.isreplay=true;
                return call(argumentCollection=arguments);
            } else{
                logError(e);
                rethrow;
            }
        }

        if(doReplay){
            if(listFirst(result.statusCode,' ')==401){  
                structDelete(application.muraProxyTokens,'#get('proxyid')#');
                arguments.isreplay=true;
                return call(argumentCollection=arguments);
            }
        }
   
        if(arguments.parse){
            if(isJSON(result.filecontent)){
                return deserializeJSON(result.filecontent);
            } else if(isXML(result.filecontent)) {
                try{
                    return xmlParse(result.filecontent);
                } catch(any e){
                    return result.filecontent;
                }
            } else {
                return result.filecontent;
            }
        } else {
            return result;
        }
    }

    function allowAccess(mura){
		return getCurrentUser().isAdminUser();
	}

    function allowRead(){
        return getCurrentUser().isAdminUser();
    }

    function allowSave(){
        return getCurrentUser().isAdminUser();
    }

    function allowDelete(){
        return getCurrentUser().isAdminUser();
    }

    function formatResponse(response){
        if(isBinary(arguments.response.filecontent)){
            cfcontent(variable=arguments.response.filecontent,type=arguments.response.mimetype,reset=true);
            abort;
        } else {
            var responseObject=getpagecontext().getResponse();
            if(isJSON(arguments.response.filecontent)){
                responseObject.setContentType('application/json; charset=utf-8');
            } else if(structKeyExists(arguments.response.responseheader,'content-type')){
                responseObject.setContentType(arguments.response.responseheader['content-type']);
            }
            
            responseObject.setStatus(listFirst(arguments.response.statusCode,' '));
           
            /*
            if(isDefined('arguments.response.responseheader')){
                var headerVals=[];
                for(var h in arguments.response.responseheader){
                    if(h !='content-disposition'){
                        headerVals=arguments.response.responseheader['#h#'];
                        if(!isArray(headerVals)){
                            headerVals=[headerVals];
                        }
                        for(var hv in headerVals){
                            cfheader( name=h, value=hv);
                        }
                    }
                }
            }
            */
          
            return arguments.response.filecontent;


        }
       
    }

    function getAccessTokenFromJWT(credential){
        var data=credential.get('data');
        // dump(data);abort;
        if(!isJSON(data)){
            logText("Invalid PROXY OAuth_JWT #arguments.credential.get('credentialID')#");
            return '';
        }

        data=deserializeJSON(data); 

        param name="data.keystore.file" default="";

        if(!len(data.keystore.file)){
            logText("Invalid PROXY OAuth_JWT, missing keystore file #arguments.credential.get('credentialID')#");
            return '';
        }

        var keyStoreFile=toBinary(data.keystore.file);
        // var tempfile=getBean('configBean').getTempDir()  & "/#createUUID()#.#lcase(data.keystore.type)#";
        // filewrite(tempfile,keyStoreFile);

        param name="data.jwt.header" default={"alg":"RS256"};
        param name="data.jwt.payload" default={"iss":"MISSING","sub":"MISSING","aud":"MISSING"};

        var base64 = createObject('java','org.apache.commons.codec.binary.Base64');
        var headerString=Base64.encodeBase64URLSafeString(javaCast('string',serializeJSON(data.jwt.header)).getBytes("UTF-8"));
        var timestampUTC = dateDiff("s", CreateDate(1970,1,1), dateConvert("Local2UTC",now()));

        data.jwt.payload['iat']=timestampUTC;
        data.jwt.payload['exp']=(timestampUTC + 3600); 

        try{
            
            if(data.keystore.type=='JKS'){

                var payloadString=Base64.encodeBase64URLSafeString(javaCast('string',serializeJSON(data.jwt.payload)).getBytes("UTF-8"));
                var token=headerString & "." & payloadString;

                param name="data.keystore.password" default="";
                param name="data.keystore.key" default="";

                var keyStore=createObject('java','java.security.KeyStore').getInstance('JKS');
            
                keystore.load(createObject('java','java.io.ByteArrayInputStream').init(javaCast("byte[]",keyStoreFile)), javaCast("char[]",data.keystore.password));

                var privateKey = keystore.getKey(data.keystore.key, javaCast("char[]",data.keystore.password));
                var signature = createObject('java','java.security.Signature').getInstance("SHA256withRSA");
                
                signature.initSign(privateKey);
                signature.update(javaCast('string',token).getBytes("UTF-8"));
                
                var signedPayload = Base64.encodeBase64URLSafeString(signature.sign());
            
                token = token & "." & signedPayload;

            } else if (data.keystore.type=='GOOGLE_JSON'){
                var service_json = deserializeJSON(toString(keyStoreFile));

                data.jwt.payload['iss']=service_json.client_email;
                data.jwt.payload['aud']='https://oauth2.googleapis.com/token';

                var payloadString=Base64.encodeBase64URLSafeString(javaCast('string',serializeJSON(data.jwt.payload)).getBytes("UTF-8"));
                var token=headerString & "." & payloadString;
                
                var keyText = reReplace( service_json.private_key, "-----(BEGIN|END)[^\r\n]+", "", "all" );
                keyText = trim( keyText );
                
                var privateKeySpec = createObject( "java", "java.security.spec.PKCS8EncodedKeySpec" )
                    .init(binaryDecode( keyText, "base64" ));
                
                var privateKey = createObject( "java", "java.security.KeyFactory" )
                    .getInstance( javaCast( "string", "RSA" ) )
                    .generatePrivate( privateKeySpec );
                
                var signer = createObject( "java", "java.security.Signature" )
                    .getInstance( javaCast( "string", 'SHA256withRSA' ));
                
                signer.initSign( privateKey );
                signer.update( charsetDecode( token, "utf-8" ) );
                signedBytes = signer.sign();
                signedBase64 = toBase64(signedBytes);
                
                token = token & "." & signedBase64;
            }

            // try {
            //     fileDelete(tempfile);
            // } catch(any e1){
            //     logError(e1);
            // }

            data.tokengeneration.data["assertion"]=token;

            var httpService=application.Mura.getHttpService();
        
            httpService.setMethod('POST');
            httpService.setURL(data.tokengeneration.endpoint);
            httpService.addParam(type='header',name='Content-Type',value=data.tokengeneration.contenttype);
            
            if(data.tokengeneration.contenttype=='application/json'){
                httpService.addParam(type='header',name='body',value=serializeJSON(data.tokengeneration.data));
            } else {
                for(var p in data.tokengeneration.data){
                    httpService.addParam(type='formfield',name=lcase(p),value=data.tokengeneration.data[p]);
                }
            }
           
            var result=httpService.send().getPrefix();
           
            if(isJson(result.filecontent)){
                var response=deserializeJSON(result.filecontent);

                if(isDefined('response.data.access_token')){
                    return response.data.access_token;
                } else if(isDefined('response.access_token')){
                    return response.access_token;
                } else {
                    logText(serializeJSON(response));
                    if(isDefined('response.error') || isDefined('response.success') && !response.success){
                        return result;
                    }
                }
                return '';
            } else {
                logText(serializeJSON(result));
                return '';
            }

        } catch(any e){
            // dump(e);
            // abort;
            // try {
            //     if(fileExists(tempfile)){
            //         fileDelete(tempfile);
            //     }
            // } catch(any e1){
            //     logError(e1);
            // }
            logError(e);
            return '';
        }

    }

     function getAccessTokenFromPassword(credential){
        var data=credential.get('data');
        
        if(!isJSON(data)){
            logText("Invalid PROXY OAuth_Password #arguments.credential.get('credentialID')#");
            return '';
        }

        data=deserializeJSON(data); 

        data.tokengeneration.data["grant_type"]="password";
        
        try{
            var httpService=application.Mura.getHttpService();
        
            httpService.setMethod('POST');
            httpService.setURL(data.tokengeneration.endpoint);
            httpService.addParam(type='header',name='Content-Type',value=data.tokengeneration.contenttype);
            
            if(data.tokengeneration.contenttype=='application/json'){
                httpService.addParam(type='header',name='body',value=serializeJSON(data.tokengeneration.data));
            } else {
                for(var p in data.tokengeneration.data){
                    httpService.addParam(type='formfield',name=lcase(p),value=data.tokengeneration.data[p]);
                }
            }

            var result=httpService.send().getPrefix();

            if(isJson(result.filecontent)){
                var response=deserializeJSON(result.filecontent);
               
                if(isDefined('response.data.access_token')){
                    return response.data.access_token;
                } else if(isDefined('response.access_token')){
                    return response.access_token;
                } else {
                    logText(serializeJSON(response));
                    if(isDefined('response.error') || isDefined('response.success') && !response.success){
                        return result;
                    }
                }
                return '';
            } else {
                logText(serializeJSON(result));
                return '';
            }

        } catch(any e){
            logError(e);
            return '';
        }

    }
}