module OpenProject::Checkout
  class Hooks < Redmine::Hook::ViewListener
    # Renders the checkout URL
    #
    # Context:
    # * :params => Current parameters
    # * :project => Current project
    #
    def view_common_error_details(context={})
      params = context[:params]
      project = context[:project]
      repository = project ? project.repository : nil

      if params[:controller] == "repository"
        show_repository_context(context, context[:project], context[:repository])
      end
    end

    def view_repositories_show_contextual(context)
      show_repository_context(context, context[:project], context[:repository])
    end

    private

    def show_repository_context(context, project, repository)
      return unless repository && (
        Setting.checkout_display_checkout_info == 'everywhere' || (
          Setting.checkout_display_checkout_info == 'browse' &&
          context[:request].params[:action] == 'show'
        )
      )

      protocols = repository.checkout_protocols.select do |p|
        p.access_rw(User.current)
      end

      path = context[:controller].instance_variable_get("@path")
      default = protocols.find(&:default?) || protocols.first

      context.merge!({
        :repository => repository,
        :protocols => protocols,
        :default_protocol => default,
        :checkout_path => path
      })

      options = {:partial => "openproject_checkout_hooks/view_repositories_show_contextual"}
      context[:controller].send(:render_to_string, {:locals => context}.merge(options))
    end
  end
end
