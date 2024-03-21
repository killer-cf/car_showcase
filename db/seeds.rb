# Users
users = [
  { name: 'Kilder Costa', tax_id: '44300248044', keycloak_id: '4212522b-d21b-4848-bee2-38547bcf115e', role: :owner },
  { name: 'Leticia Costa', tax_id: '69645714001', keycloak_id: 'key2', role: :owner },
  { name: 'Joao Alfredo', tax_id: '56951210004', keycloak_id: 'key3', role: :super },
  { name: 'Filiphe', tax_id: '23358613011', keycloak_id: 'key4', role: :admin },
  { name: 'Danilo', tax_id: '99170375003', keycloak_id: 'key5', role: :admin }
]

users.each do |user|
  User.find_or_create_by!(user)
end

# Stores
stores = [
  { name: 'Killers', tax_id: '21709361000181', phone: '111-111-1111', user_id: User.find_by(name: 'Kilder Costa').id },
  { name: 'Gujs', tax_id: '81547553000160', phone: '222-222-2222', user_id: User.find_by(name: 'Leticia Costa').id }
]

stores.each do |store|
  Store.find_or_create_by!(store)
end

# Employees
employees = [
  { store_id: Store.first.id, user_id: User.find_by(role: :admin, name: 'Filiphe').id },
  { store_id: Store.last.id, user_id: User.find_by(role: :admin, name: 'Danilo').id }
]

employees.each do |employee|
  Employee.find_or_create_by!(employee)
end

# Brands
brands = ['Ford', 'Tesla', 'BYD']

brands.each do |brand|
  Brand.find_or_create_by!(name: brand)
end

# Models
brand_models = {
  'Ford' => ['Focus', 'Fiesta', 'Mustang'],
  'Tesla' => ['Model S', 'Model 3', 'Model X'],
  'BYD' => ['Qin', 'Tang', 'Song']
}

brands = Brand.all
brands.each do |brand|
  models = brand_models[brand.name]
  models.each do |model_name|
    Model.find_or_create_by!(name: model_name, brand_id: brand.id)
  end
end

# Cars
stores = Store.all
stores.each do |store|
  10.times do |i|
    model = Model.all.sample
    brand = model.brand
    year = 2015 + i
    status = rand < 0.2 ? :inactive : :active
    car = {
      name: "#{brand.name} #{model.name} #{year}",
      year: year,
      status: status,
      brand_id: brand.id,
      model_id: model.id,
      store_id: store.id
    }
    Car.find_or_create_by!(car)
  end
end
