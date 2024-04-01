class CarMailer < ApplicationMailer
  default from: 'Car Showcase'
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.car_mailer.car_sold.subject
  #
  def car_sold
    @car = params[:car]

    mail to: 'costa.kilder@live.com', subject: 'Car sold'
  end

  def car_resume
    @store_id = params[:store_id]
    @count = Car.where(store_id: @store_id).sold.count

    mail to: 'costa.kilder@live.com', subject: 'Car resume'
  end
end
