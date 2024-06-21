require_dependency "calendars_controller"

module RedmineAdvancedRoadmap
  module CalendarsControllerPatch
    def self.included(base)
      base.class_eval do

        around_action :add_milestones, :only => [:show]

        def add_milestones
          yield
          view = ActionView::Base.with_empty_template_cache.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, nil)
          view.class_eval do
            include ApplicationHelper
          end
          milestones = []
          @query.becomes(Query).milestones(:conditions => ["effective_date BETWEEN ? AND ?",
                                            @calendar.startdt,
                                            @calendar.enddt]).each do |milestone|
            milestones << {:name => milestone.name,
                           :url => url_for(:controller => :milestones,
                                           :action => :show,
                                           :id => milestone.id, :only_path => true),
                           :day => milestone.effective_date.day}
          end
          response.body += view.render(:partial => "hooks/calendars/milestones",
                                       :locals => {:milestones => milestones})
        end

      end
    end
  end
end
