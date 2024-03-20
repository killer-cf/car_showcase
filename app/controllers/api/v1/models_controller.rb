class Api::V1::ModelsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]

  # GET /models
  def index
    @models = Model.all

    render json: @models
  end

  # GET /models/1
  def show
    render json: @model
  end

  # POST /models
  def create
    @model = Model.new(model_params)

    if @model.save
      render json: @model, status: :created
    else
      render json: { errors: @model.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /models/1
  def update
    if @model.update(model_params)
      render status: :no_content
    else
      render json: { errors: @model.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /models/1
  def destroy
    @model.destroy!
  end

  private

  def set_model
    @model = Model.find(params[:id])
  end

  def model_params
    params.require(:model).permit(:name, :brand_id)
  end
end
