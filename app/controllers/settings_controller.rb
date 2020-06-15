# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :set_setting, only: %i[show edit update destroy]

  # GET /settings/1
  # GET /settings/1.json
  def show; end

  def create
    @setting = Setting.new(setting_params)

    respond_to do |format|
      if @setting.save
        format.html { redirect_to [:edit, @setting], notice: 'Setting was successfully created.' }
        format.json { render :show, status: :created, location: @setting }
      else
        format.html { render :edit }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /settings/1/edit
  def edit; end

  # PATCH/PUT /settings/1
  # PATCH/PUT /settings/1.json
  def update
    respond_to do |format|
      if @setting.update(setting_params)
        format.html { redirect_to [:edit, @setting], notice: 'Setting was successfully updated.' }
        format.json { render :show, status: :ok, location: @setting }
      else
        format.html { render :edit }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_setting
    @setting = Setting.first || Setting.new
  end

  # Only allow a list of trusted parameters through.
  def setting_params
    params.require(:setting).permit(:program, :args, :brightness, :image, :movement, :local_image, :resize_method)
  end
end
