class ExpeditionsController < ApplicationController
  def index
    @expeditions = Expedition.all

    render json: @expeditions
  end
end
