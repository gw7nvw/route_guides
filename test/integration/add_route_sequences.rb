require 'test_helper'

class AddRouteSequences < ActionDispatch::IntegrationTest

  def setup
    init()
  end

# select-place -> select-place  -> add-route -> select place
# select-place -> add-place -> select-place -> add-place -> add-route -> select place
# edit-place -> view
# edit-route -> view
# split-route -> select-place -> view
# split-route -> select-place -> add-place -> view
# split-route -> select-place -> edit-place -> view
# split-route -> select-place -> add-place -> edit-place -> view


