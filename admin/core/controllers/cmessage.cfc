/* license goes here */
component extends="controller" output="false" {

	public function before(rc) output=false {
		if ( !session.mura.isLoggedin || !listFind(session.mura.memberships,'S2IsPrivate') ) {
			location(url="#application.configBean.getContext()#/", addtoken=false );
		}
	}

}
