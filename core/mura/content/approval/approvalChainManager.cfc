/* license goes here */
component extends="mura.baseobject"  hint="This provides approval chain service level logic functionality"{

	function getRequestFeed(siteID){
		return getBean('beanFeed').setEntityName('approvalRequest').setTable('tapprovalrequests').setSiteID(arguments.siteID);
	}

	function getChainFeed(siteID){
		return getBean('beanFeed').setEntityName('approvalChain').setTable('tapprovalchains').setSiteID(arguments.siteID);
	}

	function getActionFeed(siteID){
		return getBean('beanFeed').setEntityName('approvalAction').setTable('tapprovalactions').setSiteID(arguments.siteID);
	}

	function getMembershipFeed(siteID){
		return getBean('beanFeed').setEntityName('approvalMembership').setTable('tapprovalmemberships').setSiteID(arguments.siteID);
	}

}
