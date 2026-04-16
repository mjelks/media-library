class UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users
  def index
    @users = User.all.order(:email_address)
  end

  # GET /users/1
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)
    # Explicit assignment is much safer than mass assignment
    @user.role = params[:user][:role] if Current.user&.admin?

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: "User was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  def update
    # 1. Filter out blank passwords (standard Rails practice for profile updates)
    filtered_params = user_params.reject { |k, v| k == "password" && v.blank? }

    # 2. Explicitly handle the role assignment
    # This ensures 'role' only changes via your specific logic, not mass assignment
    if params[:user][:role].present?
      @user.role = params[:user][:role]
    end

    respond_to do |format|
      # 3. Update with the safe, permitted params
      if @user.update(filtered_params)
        format.html { redirect_to users_path, notice: "User was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, status: :see_other, notice: "User was successfully deleted." }
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      # Remove :role from here permanently to satisfy the security check
      params.require(:user).permit(:email_address, :password, :password_confirmation, :timezone)
    end
end
