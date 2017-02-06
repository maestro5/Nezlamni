$ ->
  $('.comment-edit-link').click (e) ->
    e.preventDefault()
    comment_id = $(this).data('commentId')
    $('#comment_' + comment_id).hide()
    $('#comment-' + comment_id + '-edit').show()
