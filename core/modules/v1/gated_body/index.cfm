<cfscript>
  if(isDefined('objectparams.formid') && len(objectparams.formid)){
    formid=objectparams.formid;
  } else {
    formid=m.siteConfig('gatedFormID');
  }
</cfscript>
<cfoutput> 
    <script>
        gated_href_label="#esapiEncode('javascript',m.content('title'))#";
        gated_href=window.location.href;
    </script>
    <cfif (len(formid))>
    #m.dspObject(object="form",objectid=formid)#
    <cfelse>
    #m.dspObject(object="deny")#
    </cfif>
</cfoutput>
