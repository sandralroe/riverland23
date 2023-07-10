/* License goes here */

function saveRate(id){

	var frm=document.getElementById(id);
	$.post(
		   Mura.corepath + "/modules/vs/rater/ajax/saveRate.cfm",
		   {contentID: frm.contentID.value, siteID: frm.siteID.value, userID: frm.userID.value, rate:frm.rate.value},
		   function(data){showRatingResponse(data);}
		   );
}
