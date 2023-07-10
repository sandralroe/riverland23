/* license goes here */
/**
 * This provides plugin config xml custom settings functionality
 */
component extends="mura.bean.bean" output="false" hint="This provides plugin config xml custom settings functionality" {
	property name="name" type="string" default="" required="true";
	property name="hint" type="string" default="" required="true";
	property name="type" type="string" default="TextBox" required="true";
	property name="required" type="string" default="false" required="true";
	property name="validation" type="string" default="" required="true";
	property name="regex" type="string" default="" required="true";
	property name="message" type="string" default="" required="true";
	property name="label" type="string" default="" required="true";
	property name="settingValue" type="string" default="" required="true";
	property name="optionList" type="string" default="" required="true";
	property name="optionListLabel" type="string" default="" required="true";

	public function init() output=false {
		super.init(argumentCollection=arguments);
		variables.instance.name="";
		variables.instance.hint="";
		variables.instance.type="TextBox";
		variables.instance.required="false";
		variables.instance.validation="";
		variables.instance.regex="";
		variables.instance.message="";
		variables.instance.label="";
		variables.instance.settingValue="";
		variables.instance.optionList="";
		variables.instance.optionLabelList="";
		return this;
	}

	public function setConfigBean(configBean) output=false {
		variables.configBean=arguments.configBean;
		return this;
	}

	public function set(theXML, moduleID) output=false {
		var i="";

		for(i in ListToArray("name,type,hint,required,validation,regex,message,label,optionlist,optionlabellist")){
			
			if(structKeyExists(arguments.theXML,i)){
				var args={
					'#i#'=arguments.theXML[i].xmlText
				};
			} else if (structKeyExists(arguments.theXML.xmlAttributes,i)){
				var args={
					'#i#'=arguments.theXML.xmlAttributes[i]
				};
			}
			invoke(this,"set#i#",args);
		}

		setModuleID(arguments.moduleID);
		loadSettingValue();
		return this;
	}

	public function getName() output=false {
		return variables.instance.name;
	}

	public function setName(String name) output=false {
		variables.instance.name = trim(arguments.name);
	}

	public function getModuleID() output=false {
		return variables.instance.ModuleID;
	}

	public function setModuleID(String ModuleID) output=false {
		variables.instance.ModuleID = trim(arguments.ModuleID);
	}

	public function getHint() output=false {
		return variables.instance.Hint;
	}

	public function setHint(String Hint) output=false {
		variables.instance.Hint = trim(arguments.Hint);
	}

	public function getType() output=false {
		return variables.instance.Type;
	}

	public function setType(String Type) output=false {
		variables.instance.Type = trim(arguments.Type);
	}

	public function getRequired() output=false {
		return variables.instance.Required;
	}

	public function setRequired(String Required) output=false {
		variables.instance.Required = trim(arguments.Required);
	}

	public function getValidation() output=false {
		return variables.instance.validation;
	}

	public function setValidation(String validation) output=false {
		variables.instance.validation = trim(arguments.validation);
	}

	public function getRegex() output=false {
		return variables.instance.Regex;
	}

	public function setRegex(String Regex) output=false {
		variables.instance.Regex = trim(arguments.Regex);
	}

	public function getMessage() output=false {
		return variables.instance.Message;
	}

	public function setMessage(String Message) output=false {
		variables.instance.Message = trim(arguments.Message);
	}

	public function getLabel() output=false {
		if ( len(variables.instance.Label) ) {
			return variables.instance.Label;
		} else {
			return variables.instance.name;
		}
	}

	public function setLabel(String Label) output=false {
		variables.instance.Label = trim(arguments.Label);
	}

	public function getSettingValue() output=false {
		return variables.instance.SettingValue;
	}

	public function setSettingValue(String SettingValue) output=false {
		variables.instance.SettingValue = trim(arguments.SettingValue);
	}

	public function getOptionList() output=false {
		return variables.instance.optionList;
	}

	public function setOptionList(String OptionList) output=false {
		variables.instance.OptionList = trim(arguments.OptionList);
	}

	public function getOptionLabelList() output=false {
		return variables.instance.OptionLabelList;
	}

	public function setOptionLabelList(String OptionLabelList) output=false {
		variables.instance.OptionLabelList = trim(arguments.OptionLabelList);
	}

	public function renderSetting(required theValue="useMuraDefault") output=false {
		var renderValue= arguments.theValue;
		var optionValue= "";
		var str="";
		var key=getName();
		var o=0;

		switch ( getType() ) {
			case  "Text":
			case  "TextBox":
				savecontent variable="str" {
						writeOutput("<input type=""text"" name=""#key#"" id=""#key#"" label=""#XMLFormat(getlabel())#"" value=""#HTMLEditFormat(renderValue)#"" required=""#getRequired()#""");
						if ( len(getvalidation()) ) {

							writeOutput("validate=""#getValidation()#""");
						}
						if ( getvalidation() == "Regex" ) {

							writeOutput("regex=""#getRegex()#""");
						}
						if ( len(getMessage()) ) {

							writeOutput("message=""#XMLFormat(getMessage())#""");
						}

						writeOutput("/>");
				}
				break;
			case  "TextArea":
				savecontent variable="str" {
						writeOutput("<textarea name=""#key#"" id=""#key#"" label=""#XMLFormat(getlabel())#"" required=""#getRequired()#""");
						if ( len(getMessage()) ) {

							writeOutput("message=""#XMLFormat(getMessage())#""");
						}

						writeOutput(">#HTMLEditFormat(renderValue)#</textarea>");
				}
				break;
			case  "Select":
			case  "SelectBox":
			case  "MultiSelectBox":

				savecontent variable="str" {
						writeOutput("<select name=""#key#"" id=""#key#"" label=""#XMLFormat(getlabel())#"" required=""#getRequired()#""");
						if ( len(getMessage()) ) {

							writeOutput("message=""#XMLFormat(getMessage())#""");
						}
						if ( getType() == "MultiSelectBox" ) {

							writeOutput("multiple");
						}

						writeOutput(">");
						if ( listLen(getOptionList(),'^') ) {
							for ( o=1 ; o<=listLen(getOptionList(),'^') ; o++ ) {
								optionValue=listGetAt(getOptionList(),o,'^');

								writeOutput("<option value=""#XMLFormat(optionValue)#""");
								if ( optionValue == renderValue || listFind(renderValue,optionValue) ) {

									writeOutput("selected");
								}

								writeOutput(">");
								if ( len(getOptionLabelList()) ) {

									writeOutput("#listGetAt(getOptionLabelList(),o,'^')#");
								} else {

									writeOutput("#optionValue#");
								}

								writeOutput("</option>");
							}
						}

						writeOutput("</select>");
				}
				break;
			case  "Radio":
			case  "RadioGroup":
				savecontent variable="str" {
						if ( listLen(getOptionList(),'^') ) {
							for ( o=1 ; o<=listLen(getOptionList(),'^') ; o++ ) {
								optionValue=listGetAt(getOptionList(),o,'^');

								writeOutput("<label class=""radio inline""><input type=""radio"" id=""#key#"" name=""#key#"" value=""#XMLFormat(optionValue)#""");
								if ( optionValue == renderValue ) {

									writeOutput("checked");
								}

								writeOutput("/>");
								if ( len(getOptionLabelList()) ) {

									writeOutput("#listGetAt(getOptionLabelList(),o,'^')#");
								} else {

									writeOutput("#optionValue#");
								}

								writeOutput("</label>");
							}

							writeOutput("</select>");
						}
				}
				break;
		}
		return str;
	}

	public function loadSettingValue() output=false {
		var rs="";

		var qs=new Query();
		qs.addParam(name="name",cfsqltype="cf_sql_varchar", value=getName());
		qs.addParam(name="moduleid",cfsqltype="cf_sql_varchar", value=getModuleID());

		rs=qs.execute(sql="select * from tpluginsettings where name= :name and moduleid= :moduleid").getResult();

		setSettingValue(rs.settingValue);
	}

}
