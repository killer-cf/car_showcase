class Api::V1::StoresController < ApplicationController
  before_action :set_store, only: %i[show update destroy]

  # GET /stores
  def index
    @stores = Store.all

    render json: @stores
  end

  # GET /stores/1
  def show
    render json: @store
  end

  # POST /stores
  def create
    @store = Store.new(store_params)

    if @store.save
      render json: @store, status: :created
    else
      render json: { errors: @store.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /stores/1
  def update
    if @store.update(store_params)
      render status: :no_content
    else
      render json: { errors: @store.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /stores/1
  def destroy
    @store.destroy!
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :tax_id, :phone)
  end
end
