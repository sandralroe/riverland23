/* License goes here */

component extends="controller" {

	variables.moduleid="00000000000000000000000000000000020";

	function before(rc){

		if(
			not getCurrentUser().isAdminUser()
			&& !variables.permUtility.getModulePerm(
				'#variables.moduleid#'
				, arguments.rc.siteid
			)
		){
			secure(arguments.rc);
		}

		param name='arguments.rc.proxyid' default=createUUID();
		param name='arguments.rc.name' default='';
		param name='arguments.rc.resource' default='';
		param name='arguments.rc.apiendpoint' default='';
		param name='arguments.rc.restricted' default=0;
	
	}

	function save(rc){
        if(not isdefined('arguments.rc.siteid')){
        	arguments.rc.siteID=session.siteid;
        	variables.fw.redirect(action="cproxy.list",append="siteid",path="./");
        }

		rc.bean=getBean('proxy').loadBy(proxyid=arguments.rc.proxyid).set(arguments.rc).validate();

        var isNew=rc.bean.getIsNew();
		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));

		if(!isEditor){
			rc.bean.getErrors()['permission']='You do not have permission to edit API Proxies';
		} else if(rc.$.validateCSRFTokens(context=arguments.rc.proxyid)){
			rc.bean.save();
		}

        

		if(!isNew && not rc.bean.hasErrors()){
			variables.fw.redirect(action="cproxy.list",append="siteid",path="./");
		}
    }
    
    function savecredential(rc){
        if(not isdefined('arguments.rc.siteid')){
        	arguments.rc.siteID=session.siteid;
        	variables.fw.redirect(action="cproxy.list",append="siteid",path="./");
        }

		rc.bean=getBean('proxyCredential').loadBy(credentialid=arguments.rc.credentialid).set(arguments.rc).validate();
		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));

		if(!isEditor){
			rc.bean.getErrors()['permission']='You do not have permission to edit API Proxies';
		} else if(rc.$.validateCSRFTokens(context=arguments.rc.credentialid)){
			rc.bean.save();
		}

		if(not rc.bean.hasErrors()){
			variables.fw.redirect(action="cproxy.edit",append="siteid,proxyid",path="./");
		}
    }
    
    function saveevent(rc){
        if(not isdefined('arguments.rc.siteid')){
        	arguments.rc.siteID=session.siteid;
        	variables.fw.redirect(action="cproxy.list",append="siteid",path="./");
        }

		rc.bean=getBean('proxyEvent').loadBy(eventid=arguments.rc.eventid).set(arguments.rc).validate();
		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));

		if(!isEditor){
			rc.bean.getErrors()['permission']='You do not have permission to edit API Proxies';
        } else if(rc.$.validateCSRFTokens(context=arguments.rc.eventid)){
			rc.bean.save();
		}

		if(not rc.bean.hasErrors()){
			variables.fw.redirect(action="cproxy.edit",append="siteid,proxyid",path="./");
		}
	}

	function delete(rc){

		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));

		if(isEditor && rc.$.validateCSRFTokens(context=arguments.rc.proxyid)){
			getBean('proxy').loadBy(proxyid=arguments.rc.proxyid).delete();
		}

		variables.fw.redirect(action="cproxy.list",append="siteid",path="./");
    }
    
    function deletecredential(rc){

		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));

		if(isEditor && rc.$.validateCSRFTokens(context=arguments.rc.credentialid)){
			getBean('proxyCredential').loadBy(credentialid=arguments.rc.credentialid).delete();
		}

		variables.fw.redirect(action="cproxy.edit",append="siteid,proxyid",path="./");
    }
    
    function deleteevent(rc){
		
		var isEditor=listFindNoCase('editor,module',rc.$.getBean('permUtility').getModulePermType('#variables.moduleid#',rc.siteid));

		if(isEditor && rc.$.validateCSRFTokens(context=arguments.rc.eventid)){
			getBean('proxyEvent').loadBy(eventid=arguments.rc.eventid).delete();
		}

		variables.fw.redirect(action="cproxy.edit",append="siteid,proxyid",path="./");
	}

}
