module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def countries_list
    countries = Rails.cache.fetch("country_names/es", expires_in: 12.hours) do
      ISO3166::Country.all.map{|x| [x.translation(:es) ? x.translation(:es) : x.name,x.alpha2]}.sort_by!{ |x| x[0] }
    end
    return countries
  end

  def reduced_countries_list
    countries = Rails.cache.fetch("reduced_country_names", expires_in: 12.hours) do
      countries = [["Argentina", "AR"], ["Brasil", "BR"], ["Bolivia", "BO"], ["Chile", "CL"], ["Colombia", "CO"], ["Costa Rica", "CR"], ["Ecuador", "EC"], ["España", "ES"], ["México DF", "MX"], ["Panamá", "PA"], ["Paraguay", "PY"], ["Perú", "PE"], ["República Dominicana", "DO"], ["Uruguay", "UY"], ["Venezuela", "VE"], ["Mostrar más paises", "MAS"]]
    end
    return countries
  end
end
