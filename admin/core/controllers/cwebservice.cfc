/* License goes here */

component extends="controller" {


	function before(rc){

		if(
			not getCurrentUser().isAdminUser()
		){
			secure(arguments.rc);
		}

		param name='arguments.rc.clientid' default='';
        param name='arguments.rc.clientsecret' default='';
		param name='arguments.rc.name' default='';
		param name='arguments.rc.description' default='';
		param name='arguments.rc.granttype' default='basic';
		param name='arguments.rc.redirecturl' default='';
		param name='arguments.rc.userid' default='';

	}

	function save(rc){
        if(not isdefined('arguments.rc.siteid')){
        	arguments.rc.siteID=session.siteid;
        	variables.fw.redirect(action="cwebservice.list",append="siteid",path="./");
        }

		rc.bean=getBean('oauthClient').loadBy(clientid=arguments.rc.clientid).set(arguments.rc).validate();

		var isNew=rc.bean.getIsNew();

        if(rc.$.validateCSRFTokens(context=arguments.rc.clientid)){
			rc.bean.save();
		}

		if(!isNew && not rc.bean.hasErrors()){
			variables.fw.redirect(action="cwebservice.list",append="siteid",path="./");
		}
	}

	function delete(rc){
		if(rc.$.validateCSRFTokens(context=arguments.rc.clientid)){
			getBean('oauthClient').loadBy(clientid=arguments.rc.clientid).delete();

		}

		variables.fw.redirect(action="cwebservice.list",append="siteid",path="./");
	}

}
