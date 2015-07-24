require_dependency 'repositories_helper'

module OpenProject::Checkout
  module RepositoriesHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :show_settings_save_button?, :checkout
      end
    end

    module InstanceMethods

      ##
      # As this plugin adds settings to the repository settings page, always show the save button
      def show_settings_save_button_with_checkout?(repository)
        true
      end
    end
  end
end

RepositoriesHelper.send(:include, OpenProject::Checkout::RepositoriesHelperPatch)
