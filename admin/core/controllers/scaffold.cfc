/* License goes here */
component extends="controller" output="false" {

	public function before(rc) output=false {
		if ( !isDefined('session.siteid')

				|| !(
					(
						listFind(session.mura.memberships,'Admin;#variables.settingsManager.getSite(session.siteid).getPrivateUserPoolID()#;0')
						&& variables.permUtility.getModulePerm('00000000000000000000000000000000000',session.siteid)
						&& !listFindNoCase('assembler,sites,updateSites',listLast(rc.muraAction,"."))
					)
					|| listFind(session.mura.memberships,'S2')
				)
		) {
			secure(arguments.rc);
		}
	}

	public function updateSites(rc) output=false {


	}

}
