$(document).on 'turbolinks:load', ->
  $('#edit-account').on 'ajax:error', (e, data, status, xhr) ->
    model_name = Object.keys(data.responseJSON)[0]
    errors = data.responseJSON[model_name]

    # remove errors
    $('.has-error').removeClass 'has-error'
    $('.has-feedback').removeClass 'has-feedback'
    $('.help-block').remove()
    $('.form-control-feedback').remove()

    # add errors
    for i of errors
      el = $('#' + model_name + '_' + i)
      el.closest('.form-group').addClass 'has-error has-feedback'
      el.after '<span class="fa fa-exclamation-circle form-control-feedback"></span>'
      m = errors[i].length - 1
      while m >= 0
        el.after '<small class="help-block">' + errors[i][m] + '</small>'
        m--
  