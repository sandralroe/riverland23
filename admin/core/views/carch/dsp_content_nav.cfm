<!--- license goes here --->
<cfoutput>
<div id="newContentMenu" class="addNew hide">
  <ul id="newContentOptions">
  <!--- Need class="first" and class="last" on these list items --->
    <li id="newZoom"><a href="" id="newZoomLink"><i class="mi-search-plus"></i>#application.rbFactory.getKeyValue(session.rb,"sitemanager.zoom")#</a></li>
    <li id="newContent"><a href="" id="newContentLink"><i class="mi-plus"></i>#application.rbFactory.getKeyValue(session.rb,"sitemanager.addcontent")#</a></li>
    <li id="newCopy"><a href="" id="newCopyLink"><i class="mi-copy"></i>#application.rbFactory.getKeyValue(session.rb,"sitemanager.copy")#</a></li>
    <li id="newCopyAll"><a href="" id="newCopyAllLink"><i class="mi-clone"></i>#application.rbFactory.getKeyValue(session.rb,"sitemanager.copyall")#</a></li>
	  <li id="newPaste"><a href="" id="newPasteLink"><i class="mi-paste"></i>#application.rbFactory.getKeyValue(session.rb,"sitemanager.paste")#</a></li>
  </ul>
</div>

<div id="newContentDialog" title="Add New Content" class="hide">
  <p>
  	<span class="ui-icon ui-icon-alert" style="float:left; margin:0 7px 20px 0;"></span>
  	<span id="newContentContainer"></span>
  </p>
</div>
</cfoutput>
