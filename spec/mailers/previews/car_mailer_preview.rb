# Preview all emails at http://localhost:3000/rails/mailers/car
class CarMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/car/car_sold
  def car_sold
    CarMailer.with(car: create(:car)).car_sold
  end
end
