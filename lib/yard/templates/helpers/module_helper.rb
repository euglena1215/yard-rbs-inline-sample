# frozen_string_literal: true
module YARD
  module Templates
    module Helpers
      # Helper methods for managing module objects.
      module ModuleHelper
        # Prunes the method listing by running the verifier and removing attributes/aliases
        # @rbs list: Array[CodeObjects::Base] -- a list of methods
        # @rbs hide_attributes: bool -- whether to prune attribute methods from the list
        # @rbs return: Array[CodeObjects::Base] -- a pruned list of methods
        def prune_method_listing(list, hide_attributes = true)
          list = run_verifier(list)
          list = list.reject {|o| run_verifier([o.parent]).empty? }
          list = list.reject {|o| o.is_alias? unless CodeObjects::Proxy === o.namespace }
          list = list.reject {|o| o.is_attribute? unless CodeObjects::Proxy === o.namespace } if hide_attributes
          list
        end
      end
    end
  end
end
