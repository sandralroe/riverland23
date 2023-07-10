/* License goes here */

function saveRate(id){
	var thisform = Form.serialize(document.getElementById(id));
	var myAjax = new Ajax.Request(
	 assetpath + "/includes/display_objects/rater/ajax/saveRate.cfm", 
	{
		method: 'post', 
		postBody: thisform, 
		onComplete: showRatingResponse
	});
	
}
