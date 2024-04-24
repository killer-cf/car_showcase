class Api::V1::ModelsController < ApplicationController
  before_action :authenticate, except: %i[index]

  def index
    @models = Model.page(params[:page]).per(params[:per_page] || 20)

    render json: @models, meta: pagination_dict(@models)
  end

  def create
    @model = authorize Model.new(model_params)

    if @model.save
      render json: @model, status: :created
    else
      render json: { errors: @model.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @model = authorize Model.find(params[:id])
    @model.destroy!
  end

  private

  def model_params
    params.require(:model).permit(:name, :brand_id)
  end
end
