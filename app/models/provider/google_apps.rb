class Provider::GoogleApps < Provider::Provider
  def profile_link
    @uid
  end
end
