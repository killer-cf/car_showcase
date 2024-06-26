class Api::V1::StoresController < ApplicationController
  before_action :authenticate, except: %i[index show]
  before_action :set_store, only: %i[show update destroy]

  def index
    @stores = Store.all.page(params[:page]).per(params[:per_page] || 20)

    render json: @stores, meta: pagination_dict(@stores)
  end

  def show
    render json: @store
  end

  def create
    @store = authorize Store.new(store_params)

    if @store.save
      render json: @store, status: :created
    else
      render json: { errors: @store.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @store.update(store_params)
      render status: :no_content
    else
      render json: { errors: @store.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @store.destroy!
  end

  private

  def set_store
    @store = authorize Store.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :tax_id, :phone, :user_id)
  end
end
