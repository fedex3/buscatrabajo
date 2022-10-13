class HomeController < ApplicationController
  before_action :set_home, only: %i[ show edit update destroy ]

  # GET /homes or /homes.json
  def index
    #render 'home/index'
  end

    # Only allow a list of trusted parameters through.
    def home_params
      params.fetch(:home, {})
    end
end
