/* License goes here */

var currentPageFavoriteID = "";
var favoriteExists = false;

function effectFunction()
{
	$("#favoriteListMore").animate({opacity: 'toggle'});
	return false;

}

function saveFavorite(userID, siteID, favoriteName, favoriteLocation, favoriteType)
{
	//if (!favoriteExists){
		$("#addFavorite").fadeOut();
		//location.href= url + "?" + pars;

		$.ajax({
		   type: "GET",
		   url: Mura.corepath + '/modules/v1/favorites/ajax/saveFavorite.cfm',
		   data: 'userID=' + userID + '&siteid=' + siteID + '&favoriteName=' + favoriteName + '&favoriteLocation=' + favoriteLocation + '&favoriteType=' + favoriteType + '&cacheid=' + Math.random(),
		   success: showSaveFavoriteResponse
		   });
	//}
	return false;
}

function showSaveFavoriteResponse(originalRequest)
{
	var r = eval( '(' + originalRequest + ')' );
	var iid = r.lid;
	var mover=document.createElement("DIV");
	var li=document.createElement("LI");
	li.setAttribute("id","favorite" + iid);
	li.setAttribute("style", "display:none");
	li.innerHTML=r.link;
	currentPageFavoriteID=r.favoriteid;
	mover.appendChild(li);

	$("#favoriteList").prepend(mover.innerHTML);
	$("#favoriteTip").fadeOut();
	$("#favorite" + iid).fadeIn();

}

function showDeleteFavoriteResponse(originalRequest)
{
	//put returned XML in the textarea
	//$('favoriteStatus').innerHTML = originalRequest.responseText;
}

function deleteFavorite(favoriteID, id)
{
	$.ajax({
		  type: "GET",
		   url: Mura.corepath + '/modules/v1/favorites/ajax/deleteFavorite.cfm',
		   data: 'favoriteID=' + favoriteID  + '&cacheid=' + Math.random(),
		   });

	var menuItems = document.getElementById('favoriteList').parentNode.getElementsByTagName('LI');	// Get an array of all favorite items
	menuLength = (menuItems.length - 1);
	if (menuLength == 1){
		$("#favoriteTip").fadeIn();
	}
	$("#" +id).fadeOut();
	$("#" +id).remove();
	if (favoriteID == currentPageFavoriteID)
	{
		$("#addFavorite").fadeIn();
	}

	return false;
}
