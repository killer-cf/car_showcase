class Api::V1::ModelsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]

  # GET /models
  def index
    @models = Model.all

    render json: { models: @models }
  end

  # GET /models/1
  def show
    render json: { model: @model }
  end

  # POST /models
  def create
    @model = Model.new(model_params)

    puts @model.inspect

    if @model.save
      render json: { model: @model }, status: :created
    else
      render json: { errors: @model.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /models/1
  def update
    if @model.update(model_params)
      render json: { model: @model }, status: 204
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
