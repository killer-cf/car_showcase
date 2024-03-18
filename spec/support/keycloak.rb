RSpec.configure do |config|
  config.before(:suite) do
    $private_key = OpenSSL::PKey::RSA.generate(1024)
  end
end
