Rails.application.routes.draw do
  devise_for :users
  resources :homes
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  get "users/registration_newform" => 'users#registration_newform', :as => :user_registration_newform
  get "users/session_newform" => 'users#session_newform', :as => :user_session_newform
  get "users/registration_thank_you" => 'users#registration_thank_you', :as => :registration_thank_you

  #resources :job_favorites, only: [:index]
  #resources :job_applications, only: [:index]

  resources :jobs, only: [:index, :show], param: :name_id, :path => "trabajos"
  #match 'jobs' => redirect {|params,request| "/trabajos?#{(request.params.except :name_id).to_query}" }, :via => [:get]

  #resources :companies, only: [:show, :index], param: :name_id, :path => "empresas"  do
  resources :companies do
    get 'trabajos', to: 'jobs#index', as: :companies_jobs
    resources :jobs, only: [:show], param: :name_id , :path => "trabajos"
    #post 'statistics', to: 'companies#statistics'
  end


  #get '/companies', to: redirect {|params,request| "/empresas?#{request.params.to_query}" } , as: :companies_old
  #match 'companies/:name_id' => redirect {|params,request| "/empresas/#{params[:name_id]}?#{(request.params.except :name_id).to_query}" }, :via => [:get]
  #match 'companies/:company_name_id/jobs/:name_id' => redirect {|params,request| "/empresas/#{params[:company_name_id]}/trabajos/#{params[:name_id]}?#{((request.params.except :name_id).except :company_name_id).to_query}" }, :via => [:get]

  #resources :companies, only: [] do
  #  resources :company_favorites, only: [:create]
  #  resources :jobs, only: [] do
  #    resources :job_favorites, only: [:create]
  #    resources :job_applications, only: [:create, :new]
  #  end
  #  resources :company_terms, only: [:index, :create]
  #end
  #resources :company_favorites, only: [:index]
  


  namespace :admin do
    get '/', to: 'dashboard#index'
    get '/dashboard', to: 'dashboard#index'
    get '/analytics', to: 'analytics#index'
    get	'/company_info', to:	'companies#show'
    get	'/company_info/edit', to:	'companies#edit'
    patch '/company_info', to:	'companies#update'
    resources :industries



    resources :jobs do
      member do
        get :block
      end
    end 

    resources :companies do
      get 'jobs_syncro', on: :member
      get 'stats', on: :member
    end

    resources :company_views, only: [:index]
    resources :job_views, only: [:index]

    resources :job_applications, only: [:index, :show, :destroy] do
      get 'send_mail', on: :member
      get 'accept', on: :member
      get 'reject', on: :member
      get 'positive_reject', on: :member
      get 'put_on_standby', on: :member
      get 'to_pending', on: :member
      get 'detailed', on: :member
    end


    resources :users, except: %i[create new] do
      member do
        get :login
      end
    end
    resources :user_informations, except: [:create, :new, :destroy]
  end


end