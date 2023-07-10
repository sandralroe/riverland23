/* license goes here */
/**
 * This provides reminder bean functionality
 */
component extends="mura.baseobject" output="false" hint="This provides reminder bean functionality" {
	variables.instance=structNew();
	variables.instance.contentid="";
	variables.instance.email="";
	variables.instance.isSent=0;
	variables.instance.remindHour=0;
	variables.instance.remindMinute=0;
	variables.instance.siteID="";
	variables.instance.errors=structnew();
	variables.instance.isNew=1;
	variables.instance.RemindInterval=0;

	public function init() output=false {
		return this;
	}

	public function set(required property, propertyValue) output=false {
		if ( !isDefined('arguments.reminder') ) {
			if ( isSimpleValue(arguments.property) ) {
				return getValue(argumentCollection=arguments);
			}
			arguments.reminder=arguments.property;
		}
		var prop = "";
		var tempFunc="";
		if ( isquery(arguments.reminder) ) {
			setcontentID(arguments.reminder.contentid);
			setEmail(arguments.reminder.email);
			setIsSent(arguments.reminder.isSent);
			setRemindHour(arguments.reminder.remindHour);
			setRemindMinute(arguments.reminder.remindMinute);
			setSiteID(arguments.reminder.siteID);
			setRemindInterval(arguments.reminder.RemindInterval);
		} else if ( isStruct(arguments.reminder) ) {
			for ( prop in arguments.reminder ) {
				if ( isdefined("variables.instance.#prop#") ) {
					tempFunc=this["set#prop#"];
					tempFunc(arguments.reminder['#prop#']);
				}
			}
		}
	}

	public struct function getAllValues() output=false {
		return variables.instance;
	}

	public function validate() output=false {
		variables.instance.errors=structnew();
		if ( REFindNoCase("^[^@%*<>' ]+@[^@%*<>' ]{1,255}\.[^@%*<>' ]{2,5}",variables.instance.email) != 0 ) {
			variables.instance.errors.email="The 'email' address that you provided mus be in a valid format.";
		}
	}

	public function setcontentId(required string ContentId) output=false {
		variables.instance.ContentId = trim(arguments.ContentId);
	}

	public function getcontentId() output=false {
		return variables.instance.ContentId;
	}

	public function setEmail(required string Email) output=false {
		variables.instance.Email = trim(arguments.Email);
	}

	public function getEmail() output=false {
		return variables.instance.Email;
	}

	public function setIsSent(required numeric IsSent) output=false {
		variables.instance.IsSent =arguments.IsSent;
	}

	public function getIsSent() output=false {
		return variables.instance.IsSent;
	}

	public function setRemindDate(required string RemindDat) output=false {
		variables.instance.RemindDat = trim(arguments.RemindDat);
	}

	public function getRemindDate() output=false {
		return variables.instance.RemindDat;
	}

	public function setRemindHour(required numeric RemindHour) output=false {
		variables.instance.RemindHour =arguments.RemindHour;
	}

	public function getRemindHour() output=false {
		return variables.instance.RemindHour;
	}

	public function setRemindMinute(required numeric RemindMinute) output=false {
		variables.instance.RemindMinute =arguments.RemindMinute;
	}

	public function getRemindMinute() output=false {
		return variables.instance.RemindMinute;
	}

	public function setSiteID(required string SiteID) output=false {
		variables.instance.SiteID = trim(arguments.SiteID);
	}

	public function getSiteID() output=false {
		return variables.instance.SiteID;
	}

	public function setIsNew(required numeric IsNew) output=false {
		variables.instance.IsNew = arguments.IsNew;
	}

	public function getIsNew() output=false {
		return variables.instance.IsNew;
	}

	public function setRemindInterval(required numeric RemindInterval) output=false {
		variables.instance.RemindInterval = arguments.RemindInterval;
	}

	public function getRemindInterval() output=false {
		return variables.instance.RemindInterval;
	}

}
