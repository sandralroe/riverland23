component extends="mura.bean.bean"{
    remote function updatePrivacyMXP(){
        param name="privacyStatus" default='';

		if(arguments.mxp_opt_out){
			getBean('utility').setCookie(name='MXP_OPT_OUT',value=true);
			getBean('utility').setCookie(name='MXP_ANON',value=true);
			// privacyStatus = 'opted out';
		}

		if(arguments.mxp_opt_in){
			structDelete(cookie,'mxp_opt_out');
            structDelete(cookie,'mxp_anon');
            // privacyStatus = 'opted in'
        }

        return privacyStatus;
    }

    remote function privacyStatus(){
        param name="currentPrivacyStatus" default=false;
        
        if (isDefined('cookie.mxp_anon')){
            currentPrivacyStatus = true;
        }

        return currentPrivacyStatus;
    }
}