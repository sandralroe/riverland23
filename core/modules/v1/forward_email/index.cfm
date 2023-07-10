<!--- License goes here --->
<cfoutput>
<div id="svForwardEmail" class="mura-forward-email">
   <cfif variables.$.event('emailID') eq ''>
   <em>#variables.$.rbKey('email.emailiderror')#</em>
   <cfelse>
   <#variables.$.getHeaderTag('subHead1')#>#application.emailManager.read(variables.$.event('emailID')).getSubject()#</#variables.$.getHeaderTag('subHead1')#>
   <cfif listfind(variables.$.event('doaction'),"forwardEmail")>
   <p>#variables.$.rbKey('email.forwarded')#</p>
   </cfif>
   <form name="forwardFrm" action="?nocache=1" method="post" format="html" onsubmit="return Mura.validateForm(this);" novalidate="novalidate" >
   <fieldset>
   <legend>#variables.$.rbKey('email.uptofive')#<legend>
   <ul>
   <li><input name="to1" data-message="#htmlEditFormat(variables.$.rbKey('email.emailrequired'))#" data-validate="email" data-required="true"></li>
   <li><input name="to2" data-message="#htmlEditFormat(variables.$.rbKey('email.emailvalidate'))#" data-validate="email" data-required="no"></li>
   <li><input name="to3" data-message="#htmlEditFormat(variables.$.rbKey('email.emailvalidate'))#" data-validate="email" data-required="no"></li>
   <li><input name="to4" data-message="#htmlEditFormat(variables.$.rbKey('email.emailvalidate'))#" data-validate="email" data-required="no"></li>
   <li><input name="to5" data-message="#htmlEditFormat(variables.$.rbKey('email.emailvalidate'))#" data-validate="email" data-required="no"></li>
   </ul>

   <div>
       #variables.$.dspObject_Include(thefile='datacollection/dsp_form_protect.cfm')#
   </div>

   <input name="doaction" value="forwardEmail" type="hidden"/>
   <input name="emailid" value="#HTMLEditFormat(variables.$.event('emailID'))#" type="hidden"/>
   <input name="from" value="#HTMLEditFormat(variables.$.event('from'))#" type="hidden"/>
   <input name="origin" value="#HTMLEditFormat(variables.$.event('origin'))#" type="hidden"/>
   <fieldset>
   <input class="submit" type="submit" value="#HTMLEditFormat(variables.$.rbKey('email.submit'))#"/>
   </form>
   </cfif>
</div>
</cfoutput>
