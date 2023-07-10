<!--- License goes here --->
<cfoutput>
  <cfscript>
    param rc.isGroupSearch = 0;
    if (rc.muraAction eq 'core:cusers.list'){
      rc.isGroupSearch = 1;
    }
  </cfscript>
  <form class="form-inline" novalidate="novalidate" action="" method="get" name="form1" id="siteSearch">
    <div class="mura-search">
      <span class="mura-input-set">
      <input id="search" name="search" type="text" value="#esapiEncode('html', rc.$.event('search'))#" placeholder="#rc.isGroupSearch or rc.muraAction eq 'core:cusers.list' ? rbKey('user.searchforgroups') : rbKey('user.searchforusers')#" />
      <button type="button" class="btn" onclick="submitForm(document.forms.form1);">
        <i class="mi-search"></i>
      </button>
    </span>
    <cfif not rc.isGroupSearch or rc.muraAction eq 'core:cusers.listUsers'>
      <button type="button" class="btn" onclick="actionModal();window.location='./?muraAction=cUsers.advancedSearch&amp;ispublic=#esapiEncode('url',rc.ispublic)#&amp;siteid=#esapiEncode('url',rc.siteid)#&amp;newSearch=true'" value="#rbKey('user.advanced')#">
        #rbKey('user.advanced')#
      </button>
    </cfif>  
      <input type="hidden" name="siteid" value="#esapiEncode('html', rc.siteid)#" />
      <input type="hidden" name="ispublic" value="#esapiEncode('html', rc.ispublic)#" />
      <input type="hidden" name="isGroupSearch" value="#rc.isGroupSearch#" />
      <input type="hidden" name="muraAction" value="cUsers.search" />
    </div>
  </form>
</cfoutput>