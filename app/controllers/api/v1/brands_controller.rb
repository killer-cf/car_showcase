class Api::V1::BrandsController < ApplicationController
  before_action :set_brand, only: %i[show update destroy]

  # GET /brands
  def index
    @brands = Brand.all

    render json: { brands: @brands }
  end

  # GET /brands/1
  def show
    render json: { brand: @brand }
  end

  # POST /brands
  def create
    @brand = Brand.new(brand_params)

    if @brand.save
      render json: { brand: @brand }, status: :created
    else
      render json: { errors: @brand.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /brands/1
  def update
    if @brand.update(brand_params)
      render json: { brand: @brand }, status: 204
    else
      render json: { errors: @brand.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /brands/1
  def destroy
    @brand.destroy!
  end

  private

  def set_brand
    @brand = Brand.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name)
  end
end
