<cfparam name="rc.credentialid" default="">
<cfset isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('00000000000000000000000000000000020',rc.siteid))>

<cfif not len(rc.credentialid)>
    <cfset rc.credentialid=createUUID()>
</cfif>

<cfif not isdefined('rc.bean') or not isObject(rc.bean)>
    <cfset rc.bean=$.getBean('proxyCredential').loadBy(credentialid=rc.credentialid)/>
</cfif>
<cfoutput>
<div class="mura-header">
<cfif not rc.bean.exists()>
    <h1>Add API Credential</h1>
<cfelse>
    <h1>Edit API Credential</h1>
</cfif>

<div class="nav-module-specific btn-group">
    <a class="btn" href="./?muraAction=cproxy.edit&proxyid=#esapiEncode('url',rc.proxyid)#&siteid=&#esapiEncode('url',rc.siteid)#"><i class="mi-arrow-circle-left"></i>  Back to API Proxy</a>
</div>
</div> <!-- /.mura-header -->

<cfif not structIsEmpty(rc.bean.getErrors())>
<div class="alert alert-error"><span>#application.utility.displayErrors(rc.bean.getErrors())#</span></div>
</cfif>

<form novalidate="novalidate" action="./?muraAction=cproxy.savecredential" method="post" name="form1" onsubmit="return validateForm(this);">
<div class="block block-constrain">
    <div class="block block-bordered">
    <div class="block-content">
        <span id="token-container"></span>
        <div class="mura-control-group">
            <label>Name</label>
            <input name="name" type="text" required="true" message="The Name attribute is required." value="#esapiEncode('html_attr',rc.bean.getName())#" maxlength="200">
        </div>
        <div class="mura-control-group">
        <label>Type</label>
        <select id="credentialType" name="type">
            <option value="URL" <cfif rc.bean.getType() eq "URL"> selected</cfif>>URL</option>
            <option value="FormField"<cfif rc.bean.getType() eq "FormField"> selected</cfif>>FormField</option>
            <option value="Header"<cfif rc.bean.getType() eq "Header"> selected</cfif>>Header</option>
            <option value="Cookie"<cfif rc.bean.getType() eq "cookie"> selected</cfif>>Cookie</option>
            <option value="CGI"<cfif rc.bean.getType() eq "CGI"> selected</cfif>>CGI</option>
            <option value="OAuth2_JWT"<cfif rc.bean.getType() eq "OAuth2_JWT"> selected</cfif>>OAuth2_JWT</option>
            <option value="OAuth2_Password"<cfif rc.bean.getType() eq "OAuth2_Password"> selected</cfif>>OAuth2_Password</option>
        </select>
        </div>
        <div class="mura-control-group mura-standard-value" <cfif listFindNoCase("OAuth2_JWT,OAuth2_Password",rc.bean.getType())> style="display:none;"</cfif>>
            <label>Value</label>
            <input name="data" id="jsondata" type="text" message="The Value attribute is required." value="#esapiEncode('html_attr',rc.bean.getData())#">
        </div>

        <div class="mura-jwt-value"<cfif rc.bean.getType() neq "OAuth2_JWT"> style="display:none;"</cfif>>
            <h3>Token Segments</h3>
            <div class="mura-control-group">
                <label>Header</label>
                <div id="jwt_header_error" class="alert alert-error" style="display:none;">Invalid JSON</div>
                <div id="jwt_header_valid" class="alert alert-success">Valid JSON</div>
                <textarea class="data-json mura-code" name="jwt_header" data-scope="jwt" data-datatype="object" data-key="header" type="text" ></textarea>
            </div>
            <div class="mura-control-group">
                <label>Payload</label>
                <div id="jwt_payload_error" class="alert alert-error" style="display:none;">Invalid JSON</div>
                <div id="jwt_payload_valid" class="alert alert-success">Valid JSON</div>
                <textarea class="data-json mura-code" name="jwt_payload" data-scope="jwt" data-datatype="object" data-key="payload" type="text"></textarea>
            </div>
            <h3>Java Keystore</h3>
            <div class="mura-control-group">
                <label id="addkeystore" style="display:none;">Add Keystore File</label>
                <label id="updatekeystore" style="display:none;">Update Keystore File</label>
                <input  id="keystorefilesel" type="file">
                <input class="data-json" data-scope="keystore" data-datatype="string" data-key="file" type="hidden">
            </div>
            <div class="mura-control-group">
                <label>Keystore Type</label>
                <select class="data-json" data-scope="keystore" data-datatype="string" data-key="type">
                    <option value="JKS" selected>JKS</option>
                    <option value="GOOGLE_JSON" selected>GOOGLE_JSON</option>
                </select>
            </div>
            <div class="mura-control-group">
                <label>Keystore Key</label>
                <input class="data-json" data-scope="keystore" data-datatype="string" data-key="key" type="text">
            </div>
            <div class="mura-control-group">
                <label>Keystore Password</label>
                <input class="data-json" data-scope="keystore" data-datatype="string" data-key="password" type="text">
            </div>
        </div>
        <div class="mura-jwt-value mura-password-value" <cfif not listFindNoCase("OAuth2_JWT,OAuth2_Password",rc.bean.getType())> style="display:none;"</cfif>>
            <h3>Access Token Generation</h3>
            <div class="mura-control-group">
                <label>Endpoint</label>
                <input class="data-json" data-scope="tokengeneration" data-datatype="string" data-key="endpoint" type="text">
            </div>
            <div class="mura-control-group">
                <label>Content-Type</label>
                <select class="data-json" data-scope="tokengeneration" data-datatype="string" data-key="contenttype">
                    <option value="application/x-www-form-urlencoded" selected>application/x-www-form-urlencoded</option>
                </select>
            </div>
            <div class="alert alert-info">
                <p>JSON containing the values that should be sent to API to obtain access_token.</p>
            </div>
            <div class="mura-control-group">
                <label>Data</label>
                <div id="tokengeneration_data_error" class="alert alert-error" style="display:none;">Invalid JSON</div>
                <div id="tokengeneration_data_valid" class="alert alert-success">Valid JSON</div>
                <textarea class="data-json mura-code" name="tokengeneration_data" rows="10" data-scope="tokengeneration" data-datatype="object" data-key="data" type="text" ></textarea>
            </div>
        </div>
        <cfif isEditor>
        <div class="mura-actions">
            <div class="form-actions">
                <cfif not rc.bean.exists()>
                <button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'add');"><i class="mi-check-circle"></i> Add</button>
                <cfelse>
                <button class="btn" type="button" onclick="confirmDialog('Delete API Credential?','./?muraAction=cproxy.deletecredential&proxyid=#rc.bean.getproxyid()#&credentialid=#rc.bean.getcredentialid()#&siteid=#esapiEncode('url',rc.bean.getSiteID())##rc.$.renderCSRFTokens(context=rc.bean.getcredentialid(),format="url")#');"><i class="mi-trash"></i> Delete</button>
                <button class="btn mura-primary" type="button" onclick="submitForm(document.forms.form1,'save');"><i class="mi-check-circle"></i> Update</button>
                </cfif>
                <input type="hidden" name="siteid" value="#esapiEncode('html_attr',rc.bean.getSiteID())#">
                <input type="hidden" name="proxyid" value="#esapiEncode('html_attr',rc.proxyid)#">
                <input type="hidden" name="credentialid" value="#esapiEncode('html_attr',rc.bean.getcredentialid())#">
                #rc.$.renderCSRFTokens(context=rc.bean.getcredentialid(),format="form")#
            </div>
        </div>
        </cfif>

    </div> <!-- /.block-content -->
</div> <!-- /.block-bordered -->
</div> <!-- /.block-constrain -->
</form>
</cfoutput>
<script>
    Mura(function(){
        var data=Mura('#jsondata').val();

        try{
            data=JSON.parse(data);
        } catch(e){
            data={
                jwt:{
                    header:{
                        "alg": "RS256"
                    },
                    payload:{
                        iss: "", 
                        sub:  "", 
                        aud:  ""
                    },
                },
                keystore:{
                    file:"",
                    type:"JKS",
                    key:"",
                    password:""
                },
                tokengeneration:{
                    endpoint:"",
                    contenttype:"application/x-www-form-urlencoded",
                    data:{}
                }
            };
        };

        /*
        grant_type:"urn:ietf:params:oauth:grant-type:jwt-bearer",
        format:"json",
        assertion:"--dynamic--"
        */
       
        function serializeData(){
            Mura('.data-json').forEach(function(){
                var prop=Mura(this);
                var val=prop.val();
                data[prop.data('scope')]=data[prop.data('scope')] || {};
                if(prop.data('datatype')==='object'){
                    var val=prop.val().replaceAll('\t','').replaceAll('\n','');
                    try{
                       val=JSON.parse(val);
                        Mura('#' + prop.attr('name') + '_error').hide();
                        Mura('#' + prop.attr('name') + '_valid').show();
                    } catch (e){
                        Mura('#' + prop.attr('name') + '_error').show();
                        Mura('#' + prop.attr('name') + '_valid').hide();
                        //console.log(prop.attr('name'),prop.val())
                        val={};
                    }
                }
                data[prop.data('scope')][prop.data('key')]=val;
            });
            Mura('#jsondata').val(JSON.stringify(data));
        }

        function distributeData(){
            for(var prop in data){
                if(data.hasOwnProperty(prop) && typeof data[prop]==='object'){
                    var scope=data[prop];
                    //console.log('scope',scope)
                    for(var key in scope){
                        var item=Mura('[data-scope="'+ prop +'"][data-key="'+ key +'"]');
                        if(item.data('datatype')==='object'){
                            if(typeof scope[key] === 'object'){
                                //console.log(scope[key])
                                item.val(JSON.stringify(scope[key], null, '\t'));
                            } else {
                                item.val("{}");
                            }
                        } else {
                            item.val(scope[key]);
                        }
                    }
                }
            }
        }
       
        distributeData();
      
        if(Mura('[data-scope="keystore"][data-key="file"]').val()){
            Mura('#addkeystore').hide();
            Mura('#updatekeystore').show();
        } else {
            Mura('#addkeystore').show();
            Mura('#updatekeystore').hide();
        }

        Mura('#keystorefilesel').on('change',function(e){
             // get a reference to the file
            var newData=Object.assign({},data);

            var file = e.target.files[0];

            // encode the file using the FileReader API
            var reader = new FileReader();
           
            reader.onloadend = function(){
                // use a regex to remove data url part
                //console.log(reader.result)
                var base64String = reader.result
                    .replace("data:", "")
                    .replace(/^.+,/, "");
                newData.keystore.file=base64String;

                Mura('#jsondata').val(JSON.stringify(newData));
            }

            reader.readAsDataURL(file);
        });
   
        Mura('.data-json').on('change',function(){
            serializeData();
        })

        Mura('#credentialType').on('change',function(){
            if(Mura(this).val()=='OAuth2_JWT'){
                codeInstances['tokengeneration_data'].setValue(`{
    "grant_type":"urn:ietf:params:oauth:grant-type:jwt-bearer",
    "format":"json"
}`);
                Mura(".mura-password-value").hide();
                Mura(".mura-standard-value").hide();
                Mura(".mura-jwt-value").show();
            } else if(Mura(this).val()=='OAuth2_Password'){
                codeInstances['tokengeneration_data'].setValue(`{
    "grant_type": "password",
    "client_id": "",
    "client_secret": "",
    "username": "",
    "password": ""
}`);
                Mura(".mura-jwt-value").hide();
                Mura(".mura-standard-value").hide();
                Mura(".mura-password-value").show();
            } else {
                Mura(".mura-jwt-value").hide();
                Mura(".mura-password-value").hide();
                Mura(".mura-standard-value").show();
            }
        })
    });
</script>
  