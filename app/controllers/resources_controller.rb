class ResourcesController < ApplicationController
    def index
        @active_tab = params[:tab] || "resources"
      end
end
