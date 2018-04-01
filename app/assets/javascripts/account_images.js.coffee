$ ->
  Dropzone.autoDiscover = false
  $('#account-images').dropzone
    paramName: 'imageable[image]'
    addRemoveLinks: true
    url: $(this).attr('data-action')
    init: ->
      @on 'removedfile', (file) ->
        if file.xhr
          # console.log(file.xhr.responseURL + '/' + JSON.parse(file.xhr.response).id);
          img_id = JSON.parse(file.xhr.response).id
          $.ajax
            url: file.xhr.responseURL + '/' + img_id
            type: 'DELETE'
      @on 'success', (file, image) ->