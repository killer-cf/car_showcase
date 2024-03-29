class Api::V1::CarsController < ApplicationController
  before_action :authenticate, except: %i[index show]
  before_action :set_car, only: %i[show update destroy activate sell]

  def index
    @cars = car_filter

    render json: @cars
  end

  def show
    render json: @car
  end

  def create
    @car = authorize Car.new(car_params.merge(store_id: params[:store_id]))

    if @car.save
      render json: @car, status: :created
    else
      render json: { errors: @car.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @car.update(car_params)
      render status: :no_content
    else
      render json: { errors: @car.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @car.destroy!
  end

  def activate
    @car.active!
  end

  def sell
    return unless @car.sold!

    CarMailer.with(car: @car).car_sold.deliver_later
  end

  private

  def set_car
    @car = authorize Car.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Car with id: #{params[:id]} not found" }, status: :not_found
  end

  def car_params
    params[:car][:status] = params[:car][:status].to_i
    params.require(:car).permit(:name, :year, :status, :brand_id, :model_id, :images)
  end

  def car_filter
    @cars = Car.active.page(params[:page]).per(params[:per_page] || 20)

    if params[:store].present?
      store = Store.find_by(name: params[:store])
      @cars = @cars.where(store_id: store.id) if store
    end

    if params[:brand].present?
      brand = Brand.find_by(name: params[:brand])
      @cars = @cars.where(brand_id: brand.id) if brand
    end

    if params[:model].present?
      model = Model.find_by(name: params[:model])
      @cars = @cars.where(model_id: model.id) if model
    end

    @cars = @cars.where('name LIKE ?', "%#{params[:search]}%") if params[:search].present?

    @cars
  end
end
