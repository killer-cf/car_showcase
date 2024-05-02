class Api::V1::BrandsController < ApplicationController
  before_action :authenticate, except: %i[index index_models]
  before_action :set_brand, only: %i[show update destroy]

  def index
    if params[:page].present?
      @brands = Brand.page(params[:page]).per(params[:per_page] || 20)
      render json: @brands, meta: pagination_dict(@brands)
    else
      @brands = Brand.all
      render json: @brands
    end
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
    if params[:page].present?
      @models = Brand.find(params[:id]).models.page(params[:page]).per(params[:per_page] || 20)
      render json: @models, meta: pagination_dict(@models)
    else
      @models = Brand.find(params[:id]).models
      render json: @models
    end
  end

  private

  def set_brand
    @brand = authorize Brand.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name)
  end
end
