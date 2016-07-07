#= require ./namespace

class App.RequirementManager.Controller
  constructor: (@element) ->
    # These two pieces of data are used to determine the form_input_prefix
    @selected_requirements = new App.RequirementManager.Store
    @loading_spinner = $(@element).find('[data-loading-spinner]')
    @next_index = 0
    @base_object_name = $(@element).attr 'data-base-object-name'
    @_init_existing_requirements()
    @_init_available_rules()
    @_init_new_requirement_positivity_toggles()
    @_init_searcher()
    @_init_add_buttons()
    @_listen_for_destroy_requirement_links()
    @hide_loading_spinner()
    
  
  _init_existing_requirements: ->
    # find the fieldsets generated by simple_fields_for and replace them with our
    # requirement_row template
    $existing_requirement_elements = $(@element).find '[data-existing-requirement]'
    $existing_requirement_elements.each (i, element) =>
      requirement = App.RequirementManager.Requirement.from_element(element)
      $(element).remove()
      @select_requirement requirement

  _init_available_rules: ->
    @available_rules = new App.RequirementManager.Store
    $(@element).find('[data-available-rule]')
      .each (_i, element) =>
        @available_rules.add App.RequirementManager.Rule.from_element element
        $(element).remove()

  _init_new_requirement_positivity_toggles: ->
    @new_requirement_positivity_toggles = $(@element).find('[data-new-requirement-positivity-toggle]').map (_i, toggle_button_element ) =>
      new App.RequirementManager.NewRequirementPositivityToggle toggle_button_element, controller: @

  _init_searcher: ->
    @searcher = new App.RequirementManager.Searcher $(@element).find('[data-rule-searcher]')[0], controller: @
  
  _init_add_buttons: ->
    add_button_element = $(@element).find('[data-add-button]')[0]
    new App.RequirementManager.AddButton add_button_element, controller: @
  
  add_requirement_from_rule_searcher: (attrs) ->
    chosen_rule_id = Number $(@searcher.element).val()
    chosen_rule = @available_rules.find chosen_rule_id
    if chosen_rule && (@new_requirement_positive_value == true || @new_requirement_positive_value == false)
      requirement = new App.RequirementManager.Requirement
        rule_id: chosen_rule.id
        rule_name: chosen_rule.name
        positive: @new_requirement_positive_value
      @select_requirement requirement
      @available_rules.remove chosen_rule.id
      @searcher.reset()
      @new_requirement_positive_value = null
      @new_requirement_positivity_toggles.each (_i, toggle) =>
        toggle.removeActive()
  
  _listen_for_destroy_requirement_links: ->
    $(@element).on 'click', '[data-destroy-requirement-link]', (evt) =>
      evt.preventDefault()
      target_rule_id = $(evt.target).attr('data-destroy-requirement-rule-id')
      # evt.target might be the inner content of the link
      unless !!target_rule_id
        link = $(evt.target).parents('[data-destroy-requirement-rule-id]')
        target_rule_id = $(link).attr('data-destroy-requirement-rule-id')
      
      @remove_requirement target_rule_id

  select_new_requirement_positivity: (value) ->
    @new_requirement_positive_value = value
    @new_requirement_positivity_toggles.each (_i, toggle) =>
      if toggle.requirement_positive == value
        toggle.setActive()
      else
        toggle.removeActive()

  
  select_requirement: (requirements) ->
    requirements_row = new App.RequirementManager.RequirementRow requirements,
      controller: @, index: @next_index
    @next_index++
    $(@element).find('[data-selected-requirements]').append requirements_row.to_html()
    @selected_requirements.add requirements

    
  # We remove by rule_id because the requirement might not have an id if it was just added
  remove_requirement: (rule_id) ->
    requirement_row_element = $(@element).find("[data-requirement-row][data-requirement-rule-id=\"#{rule_id}\"]")[0]
    requirement_rule_id = Number $(requirement_row_element).attr('data-requirement-rule-id')
    requirement = @selected_requirements.find requirement_rule_id
    

    # hide the row and mark it for destroy
    $(requirement_row_element).hide()
    $(requirement_row_element).find('[data-destroy-requirement-input]').val('1')
    
    # update our lists
    @selected_requirements.remove requirement.rule_id
    @available_rules.add requirement.to_rule()
    
    # reset the searcher
    @searcher.reset()

    
  hide_loading_spinner: (callback) ->
    $(@loading_spinner).hide callback
    
  show_loading_spinner: (callback) ->
    $(@loading_spinner).show callback

# fix select2 typing in modal
$.fn.modal.Constructor.prototype.enforceFocus = -> {}