module OpenProject::Checkout::CheckoutHelper
  class << self
    def supported_scm
      Object.const_defined?("REDMINE_SUPPORTED_SCM") ? REDMINE_SUPPORTED_SCM :
                                                       OpenProject::Scm::Manager.vendors
    end
  end
end
