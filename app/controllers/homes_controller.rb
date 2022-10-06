class HomesController < ApplicationController
  before_action :set_home, only: %i[ show edit update destroy ]

  # GET /homes or /homes.json
  def index
    render 'homes/index'
  end

    # Only allow a list of trusted parameters through.
    def home_params
      params.fetch(:home, {})
    end
end
