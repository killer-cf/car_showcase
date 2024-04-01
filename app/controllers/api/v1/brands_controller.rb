class Api::V1::BrandsController < ApplicationController
  before_action :authenticate
  before_action :set_brand, only: %i[show update destroy]

  # GET /brands
  def index
    @brands = Brand.all

    render json: { brands: @brands }
  end

  # GET /brands/1
  def show
    render json: @brand
  end

  # POST /brands
  def create
    @brand = authorize Brand.new(brand_params)

    if @brand.save
      render json: @brand, status: :created
    else
      render json: { errors: @brand.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /brands/1
  def update
    if @brand.update(brand_params)
      render status: :no_content
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
    @brand = authorize Brand.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name)
  end
end
