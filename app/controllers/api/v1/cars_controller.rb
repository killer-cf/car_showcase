class Api::V1::CarsController < ApplicationController
  before_action :set_car, only: %i[show update destroy]

  # GET /cars
  def index
    @cars = Car.all

    render json: { cars: @cars }
  end

  # GET /cars/1
  def show
    render json: { car: @car.as_json(except: %i[status])}
  end

  # POST /cars
  def create
    @car = Car.new(car_params)

    if @car.save
      render json: { car: @car }, status: :created
    else
      render json: { errors: @car.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cars/1
  def update
    if @car.update(car_params)
      render json: { car: @car }, status: 204
    else
      render json: { errors: @car.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /cars/1
  def destroy
    @car.destroy!
  end

  private

  def set_car
    @car = Car.find(params[:id])
  end

  def car_params
    params[:car][:status] = params[:car][:status].to_i
    params.require(:car).permit(:name, :year, :status, :brand_id, :model_id)
  end
end
