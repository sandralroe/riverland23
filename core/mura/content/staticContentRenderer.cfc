/* license goes here */
/**
 * This provides static content rendering functionality
 */
component extends="contentRenderer" output="false" hint="This provides static content rendering functionality" {

	public function createHREF(required type, required filename, required siteid, required contentid, required target="", required targetParams="", required querystring="", string context="", string stub="", string indexFile="index.htm", boolean complete="false") output=false {
		var href="";
		var tp="";
		var begin=iif(arguments.complete,de('#application.settingsManager.getSite(arguments.siteID).getScheme()#://#application.settingsManager.getSite(arguments.siteID).getDomain()##application.configBean.getServerPort()#'),de(''));
		var staticIndexFile = "index.htm";
		var contentBean = "";
		var rsFile = "";
		switch ( arguments.type ) {
			case  "Link":
			case  "File":
				contentBean=getBean('contentManager').getActiveContent(arguments.contentID,arguments.siteid);
				rsFile=getBean('fileManager').read(contentBean.getfileid());
				href="/#application.settingsManager.getSite(arguments.siteid).getExportLocation()#/#replace(arguments.contentid, '-', '', 'ALL')#.#rsfile.fileExt#";
				break;
			default:
				href="/#application.settingsManager.getSite(arguments.siteid).getExportLocation()#/#arguments.filename##iif(not len(arguments.filename),de('/'),de(''))##staticIndexFile#";
				break;
		}
		if ( arguments.target == "_blank" ) {
			tp=iif(arguments.targetParams != "",de(",'#arguments.targetParams#'"),de(""));
			href="javascript:newWin=window.open('#href#','NewWin#replace('#rand()#','.','')#'#tp#);newWin.focus();void(0);";
		}
		return href;
	}

	public function addlink(required type, required filename, required title, string target="", string targetParams="", required contentid, required siteid, string querystring="", string context="", string stub="", string indexFile="index.cfm") output=false {
		var link ="";
		var href ="";
		var staticIndexFile = "index.htm";
		if ( request.contentBean.getcontentid() == arguments.contentid ) {
			link='<a href="#staticIndexFile#" class="current">#arguments.title#</a>';
		} else {
			href=createHREF(arguments.type,arguments.filename,arguments.siteid,arguments.contentid,arguments.target,iif(arguments.filename eq request.contentBean.getfilename(),de(''),de(arguments.targetParams)),arguments.queryString,arguments.context,arguments.stub,arguments.indexFile);
			link='<a href="#href#" #iif(request.contentBean.getparentid() eq arguments.contentid,de("class=current"),de(""))#>#arguments.title#</a>';
		}
		return link;
	}

}
