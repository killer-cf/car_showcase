class Api::V1::CarsController < ApplicationController
  def index
    @cars = car_filter

    render json: { cars: @cars }
  end

  def show
    @car = Car.find(params[:id])
    render json: { car: @car.as_json(except: %i[status]) }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Car with id: #{params[:id]} not found" }, status: :not_found
  end

  private

  def car_params
    params[:car][:status] = params[:car][:status].to_i
    params.require(:car).permit(:name, :year, :status, :brand_id, :model_id)
  end

  def car_filter
    @cars = Car.page(params[:page]).per(params[:per_page] || 20)

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
