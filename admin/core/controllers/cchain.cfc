/* License goes here */

component extends="controller" {

	variables.moduleid="00000000000000000000000000000000019";

	function before(rc){

		if ( (not listFind(session.mura.memberships,'Admin;#variables.settingsManager.getSite(arguments.rc.siteid).getPrivateUserPoolID()#;0') && !listFind(session.mura.memberships,'S2')) && !( variables.permUtility.getModulePerm('#variables.moduleid#',arguments.rc.siteid) && variables.permUtility.getModulePerm('00000000000000000000000000000000000',arguments.rc.siteid)) ) {
			secure(arguments.rc);
		}

		param name='arguments.rc.chainid' default='';
		param name='arguments.rc.name' default='';
		param name='arguments.rc.description' default='';
		param name='arguments.rc.userid' default='';
		param name='arguments.rc.groupid' default='';
		param name='arguments.rc.requestid' default='';
		param name='arguments.rc.actionid' default='';
		param name='arguments.rc.actiontype' default='';

	}

	function save(rc){
        if(not isdefined('arguments.rc.siteid')){
        	arguments.rc.siteID=session.siteid;
        	variables.fw.redirect(action="cchain.list",append="siteid",path="./");
        }
		
		var bean=getBean('approvalChain').loadBy(chainID=arguments.rc.chainID).set(arguments.rc);

		if(!listFindNoCase('editor,module',variables.permUtility.getModulePermType('#variables.moduleid#',arguments.rc.siteid))){
			bean.getErrors()['permission']='You do not have permission to edit approval chains';
		} else if(rc.$.validateCSRFTokens(context=arguments.rc.chainid)){
			bean.save();
		}

		if(not bean.hasErrors()){
			variables.fw.redirect(action="cchain.list",append="siteid",path="./");
		}
	}

	function delete(rc){

		if(listFindNoCase('editor,module',variables.permUtility.getModulePermType('#variables.moduleid#',arguments.rc.siteid))
			&& rc.$.validateCSRFTokens(context=arguments.rc.chainid)
		){
			getBean('approvalChain').loadBy(chainID=arguments.rc.chainID).delete();
		}
		
		variables.fw.redirect(action="cchain.list",append="siteid",path="./");
	}

}

	

