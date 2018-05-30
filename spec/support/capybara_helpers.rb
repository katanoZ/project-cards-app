module CapybaraHelpers
  def facebook_login_setup
    OmniAuth.config.test_mode = true
    params = Faker::Omniauth.facebook
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(params)
  end
end
