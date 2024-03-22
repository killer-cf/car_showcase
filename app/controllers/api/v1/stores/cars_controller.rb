class Api::V1::Stores::CarsController < ApplicationController
  before_action :authenticate
  before_action :set_car, only: %i[update destroy activate]

  private

  def set_car
    @car = authorize Car.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Car not found' }, status: :not_found
  end

  def car_params
    params[:car][:status] = params[:car][:status].to_i
    params.require(:car).permit(:name, :year, :status, :brand_id, :model_id)
  end
end
