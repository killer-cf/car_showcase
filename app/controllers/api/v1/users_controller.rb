class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.page(params[:page]).per(params[:per_page] || 20)

    render json: @users, meta: pagination_dict(@users)
  end

  def show
    render json: @user
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render status: :no_content
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy!
  end

  def show_by_supabase_id
    @user = User.find_by(supabase_id: params[:supabase_id])

    render json: @user
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User with supabase id: #{params[:supabase_id]} not found" }, status: :not_found
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User with id: #{params[:id]} not found" }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:name, :tax_id, :avatar, :email, :supabase_id)
  end
end
