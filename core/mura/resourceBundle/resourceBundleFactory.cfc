/* license goes here */
/**
 * This provides locale specific resource bundles
 */
component extends="mura.baseobject" output="false" hint="This provides locale specific resource bundles" {
	variables.resourceBundles=structNew();
	variables.parentFactory="";
	variables.resourceDirectory="";
	variables.configBean="";
	variables.settingsManager="";
	variables.locale="";

	public function init(required any parentFactory="", required any resourceDirectory="", required any locale="en_US") output=false {
		variables.parentFactory = arguments.parentFactory;
		variables.locale = arguments.locale;
		variables.configBean=getBean("configBean");
		variables.settingsManager=getBean("settingsManager");

		if ( !len(arguments.resourceDirectory) ) {
			variables.resourceDirectory=getDirectoryFromPath(getCurrentTemplatePath()) & "resources/";
		} else {
			variables.resourceDirectory=arguments.resourceDirectory;
		}
		if(!listFind('/,\',right(variables.resourceDirectory,1))){
			variables.resourceDirectory = variables.resourceDirectory  & '/';
		}

		return this;
	}

	public function getResourceBundle(required string locale="#variables.locale#") output=false {
		if ( !structKeyExists(variables.resourceBundles,"#arguments.locale#") ) {
			variables.resourceBundles["#arguments.locale#"]=new mura.resourceBundle.resourceBundle(arguments.locale,variables.resourceDirectory);
		}
		return variables.resourceBundles["#arguments.locale#"];
	}

	public function getUtils(required string locale="#variables.locale#") output=false {
		return getResourceBundle(arguments.locale).getUtils().init(arguments.locale);
	}

	public function getKeyStructure(required string locale="#variables.locale#", key) output=false {
		return getResourceBundle(arguments.locale).getKeyStructure(arguments.key);
	}

	public function getKeyValue(required locale="#variables.locale#", key, required boolean useMuraDefault="false") output=false {

		var keyValue=getResourceBundle(arguments.locale).getKeyValue(arguments.key,true);

		if ( keyValue != "muraKeyEmpty" ) {
			return keyValue;
		} else if ( isObject(variables.parentFactory) ) {
			keyValue=variables.parentFactory.getKeyValue(arguments.locale,arguments.key,true);
			if ( keyValue != "muraKeyEmpty" ) {
				return keyValue;
			}
		}
		var primaryRBLocale=application.configBean.getValue(property='primaryRBLocale',defaultValue="en_US");

		if ( arguments.locale != primaryRBLocale) {
			keyValue = getResourceBundle(primaryRBLocale).getKeyValue(arguments.key,true);
			if ( keyValue != "muraKeyEmpty" ) {
				return keyValue;
			} else if ( isObject(variables.parentFactory) ) {
				keyValue=variables.parentFactory.getKeyValue(primaryRBLocale,arguments.key,true);
				if ( keyValue != "muraKeyEmpty" ) {
					return keyValue;
				}
			}
		}
		if ( arguments.useMuraDefault ) {
			return "muraKeyEmpty";
		} else {
			return arguments.key & "_missing";
		}
	}

	public function getKey(key) output=false {
		return getKeyValue(variables.locale,arguments.key);
	}

	/**
	 * Switches Java locale to CF locale (for CF6)
	 */
	public function CF2Java(string cflocale="#variables.lang#_#variables.country#") output=false {
		var testLocale=trim(arguments.cflocale);
		if ( testLocale == "Server" ) {
			testLocale=getLocale();
		}
		switch ( testLocale ) {
			case  "Dutch (Belgian)":
				return "nl_BE";
				break;
			case  "Dutch (Standard)":
				return "nl_NL";
				break;
			case  "English (Australian)":
				return "en_AU";
				break;
			case  "English (Canadian)":
				return "en_CA";
				break;
			case "English (UK)":
			case "English (United Kingdom)":
				return "en_GB";
				break;
			case  "English (New Zealand)":
				return "en_NZ";
				break;
			case  "English (US)":
			case  "english (united states)":
			case  "english":
				return "en_US";
				break;
			case  "French (Belgian)":
				return "fr_BE";
				break;
			case  "French (Canadian)":
				return "fr_CA";
				break;
			case  "French (Standard)":
				return "fr_FR";
				break;
			case  "French (Swiss)":
				return "fr_CH";
				break;
			case  "German (Austrian)":
				return "de_AT";
				break;
			case  "German (Standard)":
				return "de_DE";
				break;
			case  "German (Swiss)":
				return "de_CH";
				break;
			case  "Italian (Standard)":
				return "it_IT";
				break;
			case  "Italian (Swiss)":
				return "it_CH";
				break;
			case  "Norwegian (Bokmal)":
				return "no_NO";
				break;
			case  "Norwegian (Nynorsk)":
				return "no_NO";
				break;
			case  "Portuguese (Brazilian)":
				return "pt_BR";
				break;
			case  "Portuguese (Standard)":
				return "pt_PT";
				break;
			case  "Spanish (Mexican)":
				return "es_MX";
				break;
			case  "Spanish (Modern)":
				return "es_ES";
				break;
			case  "Spanish (United States)":
				return "es_US";
				break;
			case  "Spanish (Standard)":
				return "es_ES";
				break;
			case  "Swedish":
				return "sv_SE";
				break;
			case  "Japanese":
				return "ja_JP";
				break;
			case  "Korean":
				return "ko_KR";
				break;
			case  "Chinese (China)":
				return "zh_CN";
				break;
			case  "Chinese (Hong Kong)":
				return "zh_HK";
				break;
			case  "Chinese (Taiwan)":
				return "zh_TW";
				break;
			//  Lucee
			case  "arabic":
				return "ar";
				break;
			case  "arabic (united arab emirates)":
				return "ar";
				break;
			case  "arabic (bahrain)":
				return "ar";
				break;
			case  "arabic (algeria)":
				return "ar";
				break;
			case  "arabic (egypt)":
				return "ar";
				break;
			case  "arabic (iraq)":
				return "ar";
				break;
			case  "arabic (jordan)":
				return "ar";
				break;
			case  "arabic (kuwait)":
				return "ar";
				break;
			case  "arabic (lebanon)":
				return "ar";
				break;
			case  "arabic (libya)":
				return "ar";
				break;
			case  "arabic (morocco)":
				return "ar";
				break;
			case  "arabic (oman)":
				return "ar";
				break;
			case  "arabic (qatar)":
				return "ar";
				break;
			case  "arabic (saudi arabia)":
				return "ar";
				break;
			case  "arabic (sudan)":
				return "ar";
				break;
			case  "arabic (syria)":
				return "ar";
				break;
			case  "arabic (tunisia)":
				return "ar";
				break;
			case  "arabic (yemen)":
				return "ar";
				break;
			case  "hindi (india)":
				return "hi_IN";
				break;
			case  "hebrew":
				return "iw_IL";
				break;
			case  "hebrew (israel)":
				return "iw_IL";
				break;
			case  "japanese (japan)":
				return "ja_JP";
				break;
			case  "korean (south korea)":
				return "ko_KY";
				break;
			case  "thai":
				return "vi_VN";
				break;
			case  "thai (thailand)":
				return "vi_VN";
				break;
			case  "vietnamese":
				return "vi_VN";
				break;
			case  "vietnamese (vietnam)":
				return "vi_VN";
				break;
			case  "chinese":
				return "ch_CN";
				break;
			case  "belarusian":
				return "be_BY";
				break;
			case  "belarusian (belarus)":
				return "be_BY";
				break;
			case  "bulgarian":
				return "bg_BG";
				break;
			case  "bulgarian (bulgaria)":
				return "bg_BG";
				break;
			case  "catalan":
				return "ca_ES";
				break;
			case  "catalan (spain)":
				return "ca_ES";
				break;
			case  "czech":
				return "cs_CZ";
				break;
			case  "czech (czech republic)":
				return "cs_CZ";
				break;
			case  "danish":
				return "da_DK";
				break;
			case  "danish (denmark)":
				return "da_DK";
				break;
			case  "german":
				return "de_DE";
				break;
			case  "german (austria)":
				return "de_AT";
				break;
			case  "german (switzerland)":
				return "de_CH";
				break;
			case  "german (germany)":
				return "de_DE";
				break;
			case  "german (luxembourg)":
				return "de_LU";
				break;
			case  "greek":
				return "el_GR";
				break;
			case  "greek (greece)":
				return "el_GR";
				break;
			case  "english (australia)":
				return "en_AU";
				break;
			case  "english (canada)":
				return "en_CA";
				break;
			case  "english (ireland)":
				return "en_IE";
				break;
			case  "english (india)":
				return "en_IN";
				break;
			case  "english (south africa)":
				return "en_ZA";
				break;
			case  "spanish":
				return "es_ES";
				break;
			case  "spanish (argentina)":
				return "es_BO";
				break;
			case  "spanish (bolivia)":
				return "es_UY";
				break;
			case  "spanish (chile)":
				return "es_CL";
				break;
			case  "spanish (colombia)":
				return "es_CO";
				break;
			case  "spanish (costa rica)":
				return "es_CR";
				break;
			case  "spanish (dominican republic)":
				return "es_DO";
				break;
			case  "spanish (ecuador)":
				return "es_EC";
				break;
			case  "spanish (spain)":
				return "es_ES";
				break;
			case  "spanish (guatemala)":
				return "es_GT";
				break;
			case  "spanish (honduras)":
				return "es_HN";
				break;
			case  "spanish (mexico)":
				return "es_MX";
				break;
			case  "spanish (nicaragua)":
				return "es_NI";
				break;
			case  "spanish (panama)":
				return "es_PA";
				break;
			case  "spanish (peru)":
				return "es_PE";
				break;
			case  "spanish (puerto rico)":
				return "es_PR";
				break;
			case  "spanish (paraguay)":
				return "es_PY";
				break;
			case  "spanish (el salvador)":
				return "es_SV";
				break;
			case  "spanish (uruguay)":
				return "es_UY";
				break;
			case  "spanish (venezuela)":
				return "es_VE";
				break;
			case  "estonian":
				return "et_EE";
				break;
			case  "estonian (estonia)":
				return "et_EE";
				break;
			case  "finnish":
				return "fi_FI";
				break;
			case  "finnish (finland)":
				return "fi_FI";
				break;
			case  "french":
				return "fr_FR";
				break;
			case  "french (belgium)":
				return "fr_BE";
				break;
			case  "french (canada)":
				return "fr_CA";
				break;
			case  "french (switzerland)":
				return "fr_CH";
				break;
			case  "french (france)":
				return "fr_FR";
				break;
			case  "french (luxembourg)":
				return "fr_LU";
				break;
			case  "croatian":
				return "hr_HR";
				break;
			case  "croatian (croatia)":
				return "hr_HR";
				break;
			case  "hungarian":
				return "hu_HU";
				break;
			case  "hungarian (hungary)":
				return "hu_HU";
				break;
			case  "icelandic":
				return "is_IS";
				break;
			case  "icelandic (iceland)":
				return "is_IS";
				break;
			case  "italian":
				return "it_IT";
				break;
			case  "italian (switzerland)":
				return "it_CH";
				break;
			case  "italian (italy)":
				return "it_IT";
				break;
			case  "lithuanian":
				return "lt_LT";
				break;
			case  "lithuanian (lithuania)":
				return "lt_LT";
				break;
			case  "latvian":
				return "lv_LV";
				break;
			case  "latvian (latvia)":
				return "lv_LV";
				break;
			case  "macedonian":
				return "mk_MK";
				break;
			case  "macedonian (macedonia)":
				return "mk_MK";
				break;
			case  "dutch":
				return "nl_NL";
				break;
			case  "dutch (belgium)":
				return "nl_BE";
				break;
			case  "dutch (netherlands)":
				return "nl_NL";
				break;
			case  "norwegian":
				return "no_NO";
				break;
			case  "norwegian (norway)":
				return "no_NO";
				break;
			case  "polish":
				return "pl_PL";
				break;
			case  "polish (poland)":
				return "pl_PL";
				break;
			case  "portuguese":
				return "pt_PT";
				break;
			case  "portuguese (brazil)":
				return "pt_BR";
				break;
			case  "portuguese (portugal)":
				return "pt_PT";
				break;
			case  "romanian":
				return "ro_RO";
				break;
			case  "romanian (romania)":
				return "ro_RO";
				break;
			case  "russian":
				return "ru_RU";
				break;
			case  "russian (russia)":
				return "ru_RU";
				break;
			case  "slovak":
				return "sk_SK";
				break;
			case  "slovak (slovakia)":
				return "sk_SK";
				break;
			case  "slovenian":
				return "sl_SI";
				break;
			case  "slovenian (slovenia)":
				return "sl_SI";
				break;
			case  "albanian":
				return "sq_AL";
				break;
			case  "albanian (albania)":
				return "sq_AL";
				break;
			case  "serbian":
				return "sh_YU";
				break;
			case  "serbian (bosnia and herzegovina)":
				return "sh_YU";
				break;
			case  "serbian (serbia and montenegro)":
				return "sh_YU";
				break;
			case  "swedish (sweden)":
				return "sv_SE";
				break;
			case  "turkish":
				return "tr_TR";
				break;
			case  "turkish (turkey)":
				return "tr_TR";
				break;
			case  "ukrainian":
				return "uk_UA";
				break;
			case  "ukrainian (ukraine)":
				return "uk_UA";
				break;
			case "welsh":
			case "welsh (united kingdom)":
				return "cy_GB";
				break;
			default:
				//  it's probably already a java locale'
				if ( !len(testLocale) ) {
					return getLocale();
				} else {
					return testLocale;
				}
				break;
		}
	}

	public function setAdminLocale(required mySession="#getSession()#") output=false {
		var utils="";
		//  make sure that a locale and language resouce bundle have been set in the users session
		if ( !structKeyExists(arguments.mySession,"dateKey") ) {
			arguments.mySession.dateKey="";
		}
		if ( !structKeyExists(arguments.mySession,"dateKeyformat") ) {
			arguments.mySession.dateKeyformat="";
		}
		if ( !structKeyExists(arguments.mySession,"rb") ) {
			arguments.mySession.rb="";
		}
		if ( !structKeyExists(arguments.mySession,"locale") ) {
			arguments.mySession.locale="";
		}
		//   session.rb is used to tell mura what resource bundle to use for lan translations
		if ( !Len(arguments.mySession.rb) ) {
			if ( application.configBean.getDefaultLocale() != "Server" ) {
				if ( application.configBean.getDefaultLocale() == "Client" ) {
					arguments.mySession.rb=listFirst(cgi.HTTP_ACCEPT_LANGUAGE,';');
				} else {
					if ( listFind(server.coldfusion.supportedlocales,application.configBean.getDefaultLocale()) ) {
						arguments.mySession.rb=application.configBean.getDefaultLocale();
					} else {
						arguments.mySession.rb=application.rbFactory.CF2Java(application.configBean.getDefaultLocale());
					}
				}
			} else {
				arguments.mySession.rb=application.rbFactory.CF2Java(getLocale());
			}
		}
		//  session.locale  is the locale that mura uses for date formating
		if ( !len(arguments.mySession.locale) ) {
			if ( application.configBean.getDefaultLocale() != "Server" ) {
				if ( application.configBean.getDefaultLocale() == "Client" ) {
					arguments.mySession.locale=listFirst(cgi.HTTP_ACCEPT_LANGUAGE,';');
					arguments.mySession.dateKey="";
					arguments.mySession.dateKeyFormat="";
				} else {
					arguments.mySession.locale=application.configBean.getDefaultLocale();
					arguments.mySession.dateKey="";
				}
			} else {
				arguments.mySession.locale=getLocale();
				arguments.mySession.dateKey="";
				arguments.mySession.dateKeyFormat="";
			}
		}
		//  set locale for current page request
		setLocale(mySession.locale);
		//  now we create a date so we can parse it and figure out the date format and then create a date validation key
		if ( !len(arguments.mySession.dateKey) || !len(arguments.mySession.dateKeyFormat) ) {
			utils=getUtils(arguments.mySession.locale);
			arguments.mySession.dateKey=utils.getJSDateKey();
			arguments.mySession.dateKeyFormat=utils.getJSDateKeyFormat();
		}
		arguments.mySession.localeHasDayParts=findNoCase('AM',LSTimeFormat(createTime(0,0,0),  'medium'));
	}

	public function resetSessionLocale(required mySession="#getSession()#") output=false {
		arguments.mySession.locale=application.settingsManager.getSite(arguments.mySession.siteID).getJavaLocale();
		arguments.mySession.localeHasDayParts=true;
		arguments.mySession.dateKey="";
		arguments.mySession.dateKeyFormat="";
		setAdminLocale(arguments.mySession);
	}

}
