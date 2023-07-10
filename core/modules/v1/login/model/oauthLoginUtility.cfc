component extends="mura.baseobject" accessors=true output=false {

	public function updateOrCreateUserAccount(oAuth) {

		var m = application.serviceFactory.getBean('m').init(session.siteid);

		var userBean = m.getBean('user').loadBy(remoteId=arguments.oAuth.id);
		var oauthsetting = getBean('oauthSetting').loadBy(siteid=session.siteid);

		// First try to load user by email
		// (this is for new admin user accounts that were previously created by another site admin)
		if (arguments.oAuth.email != 'donotreply@domain.com') {
			var adminUserIterator = m.getFeed('user')
				.setIsPublic(0)
				.where()
				.prop('email').isEQ(arguments.oAuth.email)
				.prop('isPublic').isEQ(0)
				.getIterator();

			// this is for public user accounts that already exist with the same email returned by oauth
			var publicUserIterator = m.getFeed('user')
				.setIsPublic(1)
				.where()
				.prop('email').isEQ(arguments.oAuth.email)
				.prop('isPublic').isEQ(1)
				.getIterator();

			if (adminUserIterator.hasNext()) {
	      // This means an admin account already exists matching the oAuth.email
				// We will update the user's remoteId value and set the isNew value to 0.
				userBean = adminUserIterator.next();
				userBean.setRemoteId(arguments.oAuth.id);
				userBean.setIsNew('0'); // Needed because isNew is 1 for some reason.
			} else if (publicUserIterator.hasNext()) {
				// This means a public account already exists matching the oAuth.email
				// We will update the user's remoteId value and set the isNew value to 0.
				userBean = publicUserIterator.next();
				userBean.setRemoteId(arguments.oAuth.id);
				userBean.setIsNew('0'); // Needed because isNew is 1 for some reason.
			}
		}

		// // Handle for difference between facebook and Google returned oAuth objects
		// if (!structKeyExists(arguments.oAuth, 'given_name')) {
		// 	if (structKeyExists(arguments.oAuth, 'first_name')) {
		// 		oAuth.given_name = arguments.oAuth.first_name;
		// 	} else {
		// 		oAuth.given_name = arguments.oAuth.name.split(' ')[1];
		// 	}
		// }
		// if (!structKeyExists(arguments.oAuth, 'family_name')) {
		// 	if (structKeyExists(arguments.oAuth, 'last_name')) {
		// 		arguments.oAuth.family_name = arguments.oAuth.last_name;
		// 	} else {
		// 		nameArray = arguments.oAuth.name.split(" ");
		// 		arguments.oAuth.family_name = ArrayToList(arraySlice(nameArray, 2), " ");
		// 	}
		// }
		//
		// if (isNull(arguments.oAuth.email)) {
		// 	oAuth.email = 'donotreply@domain.com';
		// 	arguments.oAuth.username = arguments.oAuth.name & createUUID();
		// } else {
		// 	arguments.oAuth.username = arguments.oAuth.email;
		// }

    // Copy across user's info from oAuth if it is a brand new user
		if (userBean.getIsNew()) {
			userBean.setState(''); //This is prevent the state value from triggering an address
			userBean.setPassword(createUUID());
			userBean.setUsername(arguments.oAuth.username); //Unique?
			userBean.setRemoteId(arguments.oAuth.id);
			if(len(arguments.oAuth.given_name)){
				userBean.setFname(arguments.oAuth.given_name);
			} else {
				userBean.setFname('N/A');
			}
			if(len(arguments.oAuth.family_name)){
				userBean.setLname(arguments.oAuth.family_name);
			} else {
				userBean.setLname('N/A');
			}
			
			userBean.setEmail(arguments.oAuth.email); //unique?
			userBean.setAddressId('');
		}

		// Set baselines for lockdown check
		var isNewAdmin = false;
		var isNewSuperUser = false;

		arguments.oAuth.domain = listLast(arguments.oAuth.email, '@');

		// only allow users from a specififed domain list
		var allowedDomain = oauthsetting.getAllowedDomain();
		if (len(allowedDomain) && !listFindNoCase(allowedDomain, arguments.oAuth.domain)) {
			userBean.setInActive(0);
		}

		// If user's email domain is in the allowedAdminDomain list, add them to admin group.
		var allowedAdminDomain = oauthsetting.getAllowedAdminDomain();
		if (listFindNoCase(allowedAdminDomain, arguments.oAuth.domain)) {
			userBean.setIsPublic(0);
		}

		var adminGroupId = m.getBean('user').loadby(GroupName='Admin').get('UserId');

		var allowedAdminGroupEmailList = oauthsetting.getAllowedAdminGroupEmailList();
		if (listFindNoCase(allowedAdminGroupEmailList, arguments.oAuth.email)) {
			userBean.setIsPublic(0);
			userBean.setGroupID(groupid=adminGroupId,append=true);
			isNewAdmin = true;
		}

		// If user's email address is in the allowedS2EmailList, make them superuser and add them to admin group.
	
		var allowedS2EmailList = oauthsetting.getAllowedS2EmailList();
		if (listFindNoCase(allowedS2EmailList, arguments.oAuth.email)) {
			userBean.setIsPublic(0);
			userBean.setS2(1);
			userBean.setGroupID(groupid=adminGroupId,append=true);
			isNewSuperUser = true;
		}

		var isAdmin = listFindNoCase(userBean.getGroupId(), adminGroupId) || isNewAdmin;
		var isSuperUser = userBean.getS2() == '1' || isNewSuperUser;
		var isExistingUser = userBean.getIsNew() == 0;
		arguments.oAuth.inActive = userBean.getInActive();

		userBean.setLastUpdateBy('System');
		
		var enableLockdown = m.siteConfig().getEnableLockdown();

		if (enableLockdown == 'development' || enableLockdown == 'maintenance' || enableLockdown == 'archived') {
			var letin=false;
			if ( ((enableLockdown == "development" || enableLockdown == 'archived') && isExistingUser) || isSuperUser) {
				// If site is in development or achived mode, only allow pre-existing user accounts through. An exception to this is new super users.
				var letin=true;
			} else if ( enableLockdown == "maintenance" && isAdmin) {
				// If the site is in maintenance mode, only allow admin user accounts through.
				var letin=false;
			}
			if(letin){
				if(getBean('configBean').getValue(property="sessionBasedLockdown",defaultValue=true)){
					getSession().passedLockdown=true;
				} else {
					m.getBean('utility').setCookie(name="passedLockdown", value=true, expires='session');
				}
				userBean.save();
				userBean.login();
			}
		} else {
			// Site is in production mode
			userBean.save();
			userBean.login();
		}

		return true;
	}

}
