<cfimport prefix="ui" taglib="/core/mura/customtags/configurator/ui">
<cfswitch expression="#attributes.type#">
<cfcase value="textarea">
<ui:textarea attributecollection="#attributes#">
</cfcase>
<cfcase value="color">
<ui:color attributecollection="#attributes#">
</cfcase>
<cfcase value="image">
<ui:image attributecollection="#attributes#">
</cfcase>
<cfcase value="file">
<ui:file attributecollection="#attributes#">
</cfcase>
<cfcase value="html">
<ui:html attributecollection="#attributes#">
</cfcase>
<cfcase value="select">
<ui:select attributecollection="#attributes#">
</cfcase>
<cfcase value="radio">
<ui:radio attributecollection="#attributes#">
</cfcase>
<cfcase value="dispenser">
<ui:dispenser attributecollection="#attributes#">
</cfcase>
<cfcase value="modal">
<ui:modal attributecollection="#attributes#">
</cfcase>
<cfcase value="markdown">
<ui:markdown attributecollection="#attributes#">
</cfcase>
<cfcase value="fieldlist">
<ui:fieldlist attributecollection="#attributes#">
</cfcase>
<cfcase value="hidden">
<ui:hidden attributecollection="#attributes#">
</cfcase>
<cfcase value="toggle">
    <ui:toggle attributecollection="#attributes#">
    </cfcase>
<cfcase value="custom_name_value_array">
    <ui:name_value_array attributecollection="#attributes#">
</cfcase>
<cfcase value="name_value_array">
    <ui:name_value_array attributecollection="#attributes#">
</cfcase>
<cfdefaultcase>
<ui:text attributecollection="#attributes#">
</cfdefaultcase>
</cfswitch>