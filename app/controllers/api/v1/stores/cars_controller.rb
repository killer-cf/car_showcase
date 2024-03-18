class Api::V1::Stores::CarsController < ApplicationController
  before_action :authenticate, :require_admin!
  before_action :set_car, only: %i[update destroy]

  def create
    @car = Car.new(car_params)

    if @car.save
      render json: { car: @car }, status: :created
    else
      render json: { errors: @car.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @car.update(car_params)
      render json: { car: @car }, status: 204
    else
      render json: { errors: @car.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @car.destroy!
  end

  private

  def set_car
    @car = Car.find(params[:id])
  end

  def car_params
    params[:car][:status] = params[:car][:status].to_i
    params.require(:car).permit(:name, :year, :status, :brand_id, :model_id).merge(store_id: params[:store_id])
  end
end