const errorHandler = function(response) {
  alert(response.responseJSON["error"])
}

function uploadImage(file, success, width, height) {
  var form_data = new FormData();
  form_data.append('file', file);
  $.ajax({
        url: 'images/upload.json', // point to server-side controller method
        headers: {
                'width': width,
                'height': height,
            },
        dataType: 'json', // what to expect back from the server
        cache: false,
        contentType: false,
        processData: false,
        data: form_data,
        type: 'post',
        success: success,
        error: errorHandler
    });
}

function destroyImage(public_id, success) {
  $.ajax({
        url: `images/${public_id}.json`, // point to server-side controller method
        dataType: 'json', // what to expect back from the server
        cache: false,
        contentType: false,
        processData: false,
        type: 'delete',
        success: success,
        error: errorHandler
    });
}