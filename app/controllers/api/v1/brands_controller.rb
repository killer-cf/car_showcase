class Api::V1::BrandsController < ApplicationController
  before_action :authenticate, except: %i[index index_models]
  before_action :set_brand, only: %i[show update destroy]

  def index
    @brands = Brand.all

    render json: @brands
  end

  def show
    render json: @brand
  end

  def create
    @brand = authorize Brand.new(brand_params)

    if @brand.save
      render json: @brand, status: :created
    else
      render json: { errors: @brand.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @brand.update(brand_params)
      render status: :no_content
    else
      render json: { errors: @brand.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @brand.destroy!
  end

  def index_models
    @models = Brand.find(params[:id]).models

    render json: @models
  end

  private

  def set_brand
    @brand = authorize Brand.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name)
  end
end
