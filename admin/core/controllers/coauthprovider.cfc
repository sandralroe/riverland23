/* License goes here */

component extends="controller" {


	function before(rc){

		if(
			not getCurrentUser().isAdminUser()
		){
			secure(arguments.rc);
		}

		param name='arguments.rc.providerid' default=createUUID();
		param name='arguments.rc.name' default='';
		param name='arguments.rc.clientid' default='';
		param name='arguments.rc.clientsecret' default='';

	}

	function save(rc){
        if(not isdefined('arguments.rc.siteid')){
        	arguments.rc.siteID=session.siteid;
        	variables.fw.redirect(action="coauthprovider.list",append="siteid",path="./");
        }

		rc.bean=getBean('oauthprovider').loadBy(providerid=arguments.rc.providerid).set(arguments.rc).validate();

        var isNew=rc.bean.getIsNew();

        if(rc.$.validateCSRFTokens(context=arguments.rc.providerid)){
			rc.bean.save();
		}

		if(!isNew && not rc.bean.hasErrors()){
			variables.fw.redirect(action="coauthprovider.list",append="siteid",path="./");
		}
    }
    
   	function delete(rc){
		if(rc.$.validateCSRFTokens(context=arguments.rc.providerid)){
			getBean('oauthprovider').loadBy(providerid=arguments.rc.providerid).delete();
		}

		variables.fw.redirect(action="coauthprovider.list",append="siteid",path="./");
    }
}
