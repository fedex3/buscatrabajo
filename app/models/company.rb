class Company < ApplicationRecord
  require 'rss'
  require 'httparty'
  include ShowPhotoName
  attr_accessor :terms_accepted

  has_many :company_stories, as: :storiable, :dependent => :destroy
  has_many :company_countries
  has_many :company_states

  paginates_per 10

  has_many :company_favorites
  has_many :users, through: :company_favorites
  has_many :company_speeches, :dependent => :destroy  #TODO: remove after all is merged
  has_many :company_videos, :dependent => :destroy    #TODO: remove after all is merged
  has_many :company_photos, :dependent => :destroy    #TODO: remove after all is merged
  has_many :company_views
  has_many :company_reaches
  has_many :advices
  has_many :advice_companies
  has_many :jobs
  has_many :offices
  has_and_belongs_to_many :company_special_events
	has_and_belongs_to_many :industries
	has_and_belongs_to_many(:recommended_companies,
    :join_table => "recommended_companies",
    :foreign_key => "company_id",
    :association_foreign_key => "recommended_company_id",
    :class_name => "Company")

  accepts_nested_attributes_for :company_stories, allow_destroy: true

	has_attached_file :main_photo, {
      default_url: ActionController::Base.helpers.asset_path("missing.webp"),
  		#url: "/system/projects/logos/:hash.:extension",
	    hash_secret: "longSecretString",
      :styles => {:small => "396x263#", :medium => "500x332#", :large => "1600x400#"}
	}

	validates_attachment_content_type :main_photo, content_type: /\Aimage/
  validates_attachment_file_name :main_photo, matches: [/png\Z/i, /jpe?g\Z/i, /webp\Z/i]

  has_attached_file :cover_photo, {
      default_url: ActionController::Base.helpers.asset_path("missing.webp"),
	    hash_secret: "longSecretString",
      :styles => {:thumbnail => "150x", :large => "1600x400#"}
	}

	validates_attachment_content_type :cover_photo, content_type: /\Aimage/
  validates_attachment_file_name :cover_photo, matches: [/png\Z/i, /jpe?g\Z/i, /webp\Z/i, /gif\Z/i]

  process_in_background :main_photo, processing_image_url: "/images/:style/processing.webp"
  process_in_background :cover_photo, processing_image_url: "/images/:style/processing.webp"

	has_attached_file :logo, {
      default_url: ActionController::Base.helpers.asset_path("missing.webp"),
  		#url: "/system/projects/logos/:hash.:extension",
	    hash_secret: "longSecretString",
      :styles => {:thumbnail => "120x100",  :small => "300x300"},
      :convert_options => { :small => "-gravity center -extent 300x300"} #Makes the image a perfect square adding white space to the sides
	}

	validates_attachment_content_type :logo, content_type: /\Aimage/
  validates_attachment_file_name :logo, matches: [/png\Z/i, /svg\Z/i, /jpe?g\Z/i, /webp\Z/i]
  validates_attachment_size :logo, :in => 0.megabytes..1.megabytes

  has_attached_file :icon, {
    default_url: ActionController::Base.helpers.asset_path("missing.webp"),
      #url: "/system/projects/logos/:hash.:extension",
      hash_secret: "longSecretString",
      :styles => {:thumbnail => "150x",  :small => "120x100"},
      :convert_options => { :thumbnail => "-gravity center -extent 150x150"} #Makes the image a perfect square adding white space to the sides
  }

  validates_attachment_content_type :icon, content_type: /\Aimage/
  validates_attachment_file_name :icon, matches: [/png\Z/i, /jpe?g\Z/i, /webp\Z/i]
  validates_attachment_size :icon, :in => 0.megabytes..1.megabytes
  after_save :tinify_photos , if: Proc.new { |company| (company.saved_change_to_main_photo_updated_at? ||
    company.saved_change_to_cover_photo_updated_at? || 
    company.saved_change_to_logo_updated_at? || 
    company.saved_change_to_icon_updated_at?) && 
    Rails.env.production?}

	validates :name, length: { minimum: 1, maximum: 100}
	validates :name_id, uniqueness: {case_sensitive: false}
 	validates :industries, :length => { :minimum => 1 }  ##ASK: why don't use presence true only ?
 	validates :views, numericality: { greater_than_or_equal_to: 0}
  validates :summary, length: { minimum: 1, maximum: 140}
  validates :long_summary, length: { minimum: 1, maximum: 300}, allow_blank: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :jobs_email, format: { with: VALID_EMAIL_REGEX }

  validates :terms_accepted_email, presence: true, format: { with: VALID_EMAIL_REGEX }, if: :terms_accepted
  validates :terms_accepted_phone, length: { minimum: 7, maximum: 300}, if: :terms_accepted
  validates :terms_accepted_name, length: { minimum: 5, maximum: 300}, if: :terms_accepted
  validates :terms_accepted_position, length: { minimum: 2, maximum: 300}, if: :terms_accepted

  validates :link_for_proactive_interviews, presence: true, if: :proactive_interviews
	before_validation :create_name_id
	before_save :create_recommended_companies
  after_save :update_urls

  enum job_provider_type: %i[mibucle other avature greenhouse workday hiringroom publicis]
  enum pack: %i[pack_gold pack_silver pack_bronze pack_free]
  enum jobs_process_status: %i[jobs_dont_apply jobs_pending jobs_finished jobs_processing]

  scope :by_q, -> (q) { joins(:industries, :companies_industries, :company_speeches, :company_stories, :jobs).where("lower(companies.name) LIKE ? OR lower(companies.state) LIKE ? OR lower(industries.name) LIKE ? OR lower(company_speeches.detail) LIKE ? OR lower(company_stories.detail)  LIKE ? OR lower(jobs.name) LIKE ?", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%").distinct}
  scope :by_state, -> (state) {  joins(:company_states).where('company_states.state_full_name = ?', state) }
  scope :by_country, -> (country) { joins(:company_countries).where('company_countries.country_alpha2 = ?', country) }
  scope :by_not_this_country, -> (country) { joins(:company_countries).where.not('company_countries.country_alpha2 = ?', country) }
  scope :by_name, -> (q) { where("lower(name) LIKE ?", "%#{q}%") }
  scope :listable, -> { active.from_date}
  scope :from_date, -> { where("date_trunc('day', companies.from_date) <= ?", Date.today) }
	scope :active, -> { where(active: true) }
  scope :gold, -> { where(pack: 0) }
  scope :silver, -> { where(pack: 1) }
  scope :bronze, -> { where(pack: 2) }
  scope :free, -> { where(pack: 3) }
  scope :bronze_and_free, -> { where(pack: [2,3]) }
  scope :not_show_only_in_special_events, -> { where(show_only_in_special_events: false) }
  scope :featured_on_home, -> { where(home: true) }
  scope :featured_on_chile_home, -> { where(featured_on_chile_home: true) }
  scope :featured_on_spain_home, -> { where(featured_on_spain_home: true) }
  scope :featured_on_mexico_home, -> { where(featured_on_mexico_home: true) }
  scope :featured_on_colombia_home, -> { where(featured_on_colombia_home: true) }
	scope :default_order, -> { order(name: :asc) }
	scope :order_by_date, -> { order(created_at: :desc) }
  scope :order_by_home, -> { order(home: :desc, created_at: :desc) }
  scope :order_by_relevance, -> { order(views: :desc) }
  scope :order_by_default, -> { order(views: :desc) }
	scope :order_by_name, -> { order(name: :asc) }
  scope :order_by_name_desc, -> { order(name: :desc) }
  scope :order_by_pack, -> { order(pack: :asc) }
  scope :order_by_is_special_event_gold_first, -> { order(is_special_event_gold: :desc) }
  scope :order_by_user_count, -> { joins(:users).group(:id).order('COUNT(users.id) DESC')}
  scope :has_users, -> { joins(:users).uniq }
  scope :faved_last_month , -> { joins(:users).uniq.select{|comp| comp.company_favorites.select{|fav| fav.created_at > (Date.today - 1.month)}.count > 0} }

  scope :order_by_order_in_event, -> { order(order_in_event: :asc) }
  scope :by_manual_order, -> { order('manual_order asc NULLS LAST') }

  scope :with_photo, -> { where.not(main_photo_url: ["missing.webp", nil] ) }
	scope :without_photo, -> { where(main_photo_url: ["missing.webp", nil]) }
	scope :get_and_order_by_ids, ->(ids) {
    order = sanitize_sql_array(
      ["position((',' || companies.id::text || ',') in ?)", ids.join(',') + ',']
    )
    where(:id => ids).order(order)
  }
  scope :order_by_country_photo_and_manual, -> (locale, add_order = nil) {
    
    selected_order = (add_order == 'created_at' ? 'created_at DESC' : 'manual_order asc NULLS LAST')
    all_order = <<~SQL
      CASE WHEN (main_photo_url IS NOT NULL AND main_photo_url <> 'missing.webp') THEN 0 ELSE 1 END,
      CASE WHEN company_countries.country_alpha2 = '#{locale}' THEN 0 ELSE 1 END,
      #{selected_order}
    SQL
    joins(:company_countries).order(all_order)
  }

  def id_name
    id.to_s + ' - ' + name
  end

  def free?
    pack_free?
  end

  def listable
    active && from_date <= DateTime.now.strftime("%Y-%m-%d")
  end

  def jobs_syncronizable?
    avature?
  end

  def jobs_syncro
    if avature?
      jobs_syncro_avature
    end
  end

  def update_urls
    if main_photo(:small).to_s != main_photo_url
      self.update_column(:main_photo_url,main_photo(:small).to_s)
    end
    if icon(:small).to_s != icon_url
      self.update_column(:icon_url,icon(:small).to_s)
    end
    if logo.to_s != logo_url
      self.update_column(:logo_url,logo(:original).to_s)
    end
  end

	def create_recommended_companies
		recommendations = Set.new

		#Dejo que se encuentren recomendaciones aunque no llegue su from_Date aun, para dejar todo bien en las vacaciones
		industries.each do |industry|
			if active
        industry.companies.listable.order_by_date.limit(ENV['COMPANY_RECOMMENDATIONS'].to_i - recommendations.size + 1).each do |recommended_company|
  				Rails.logger.debug('Company :' + industry.name + ' ' + recommended_company.name)
  				recommendations << recommended_company
  			end
      else
        industry.companies.from_date.order_by_date.limit(ENV['COMPANY_RECOMMENDATIONS'].to_i - recommendations.size + 1).each do |recommended_company|
          Rails.logger.debug('Company :' + industry.name + ' ' + recommended_company.name)
          recommendations << recommended_company
        end
      end
			break if recommendations.size > ENV['COMPANY_RECOMMENDATIONS'].to_i #> para no traer a mi mismo, por las dudas
		end

		#Si no llegue al numero, completo con las mas nuevas
		if recommendations.size <= ENV['COMPANY_RECOMMENDATIONS'].to_i
			Company.listable.order_by_date.limit(ENV['COMPANY_RECOMMENDATIONS'].to_i + 1).each do |recommended_company|
				unless recommendations.include?(recommended_company)
					recommendations << recommended_company
				end
			end
		end

		self.recommended_companies.destroy_all
		self.recommended_companies << (recommendations - [self]).take(ENV['COMPANY_RECOMMENDATIONS'].to_i)
	end

	def create_name_id
		self.name_id = Url.friendly(name)
	end
  
  def multioffice?
    !!(offices.listable.count > 1)
  end

  def office
    offices.listable.first if offices.listable.count == 1
  end

  def viewed!
    self.update_column(:views, self.views+1)
  end

  def industries_names
    self.industries.map(&:name).join(' | ')
  end

  def stories
    c_stories = self.company_stories.order_by_date
    c_stories = c_stories.empty? && !self.offices.listable.empty? ? self.offices.listable.first.stories : []
  end

  def update_recommended_jobs
    jobs.active.map{|x| x.calculate_recommended_jobs}
  end

  def reach
    # Impresiones:
    #   Página de empresa
    company_page_views = self.company_reaches.last.total_company_page_views

    #   Avisos de trabajo
    jobs_views = self.company_reaches.last.total_jobs_views

    #   Notas firmadas por esa empresa
    advices_views = self.company_reaches.last.total_advices_views

    # TODO:
    #   Avisos en la home
    #   Avisos en resultados de búsqueda
    #   Menciones de empresa en newsletter
    #   Menciones de avisos en newsletter
    #   Redes sociales
    return company_page_views + jobs_views + advices_views
  end

  def reach_evolution
    # Devuelve el porcentaje de crecimiento o decrecimiento del reach comparando el del último día con el del día anterior
    # Traigo el último reach y el anteultimo y los comparo. reaches[0] es el anteúltimo y reaches[1] es el último.
    reach_evolution_array = Array.new
    reaches = self.company_reaches.last(2)
    reach_evolution_array << ((reaches[1].company_page_views - reaches[0].company_page_views) * 100) / (reaches[0].company_page_views.nonzero? || 1)
    reach_evolution_array << ((reaches[1].jobs_views - reaches[0].jobs_views) * 100) / (reaches[0].jobs_views.nonzero? || 1)
    reach_evolution_array << ((reaches[1].advices_views - reaches[0].advices_views) * 100) / (reaches[0].advices_views.nonzero? || 1)
    puts reach_evolution_array.inspect
    return reach_evolution_array
  end

  def engagement
    # Porcentaje de postulaciones por vista de anuncio
    jobs_views = self.company_reaches.last.total_jobs_views
    job_applications = self.company_reaches.last.total_job_applications
    return (job_applications * 100) / (jobs_views.nonzero? || 1)
  end

  def engagement_comparison
    # Comparo el engagement de esta empresa con el engagement de todas las empresas en mibucle
    # y le digo si está por debajo, igual o encima del promedio.
    if self.engagement < average_engagement
      engagement_comparison_result = -1
    elsif self.engagement > average_engagement
      engagement_comparison_result = 1
    else
      engagement_comparison_result = 0
    end
  end

  # Comentado para el futuro, cuando tengamos datos y podramos comprarar por mes
  # def engagement_evolution
  #   reaches = self.company_reaches.last(2)
  #   engagement_0 = (reaches[0].job_applications * 100) / (reaches[0].jobs_views.nonzero? || 1)
  #   engagement_1 = (reaches[1].job_applications * 100) / (reaches[1].jobs_views.nonzero? || 1)
  #   engagement = ((engagement_1 - engagement_0) * 100) / (engagement_0.nonzero? || 1)
  #   return engagement
  # end

  def average_engagement
    companies_engagement_sum = 0
    Company.all.each do |company|
      companies_engagement_sum = companies_engagement_sum + company.engagement
    end
    average_engagement = companies_engagement_sum / (Company.all.count.nonzero? || 1)
  end

  def ime
    ime_result = 0

    self.reach_evolution.each do |reach|
      if reach > 0
        ime_result = ime_result + 11
      end
    end

    if self.engagement_comparison == 1
      ime_result = ime_result + 34
    elsif self.engagement_comparison == 0
      ime_result = ime_result + 30
    end

    if self.offices_completeness == 100
      ime_result = ime_result + 33
    elsif self.offices_completeness > 79
      ime_result = ime_result + 30
    elsif self.offices_completeness > 49 && self.offices_completeness < 80
      ime_result = ime_result + 15
    end

    return ime_result
  end

  def offices_completeness
    offices = self.offices
    total_items = offices.count * 4
    items_completed = 0

    offices.each do |office|
      items_completed += 1 if office.has_five_active_photos?
      items_completed += 1 if office.has_one_active_video?
      items_completed += 1 if office.has_three_speeches?
      items_completed += 1 if office.has_four_stories?
    end

    (items_completed * 100) / (total_items.nonzero? || 1)
  end

  def jobs_views
    self.jobs.sum(:views)
  end

  def advices_views
    self.advices.sum(:views)
  end

  def job_applications_counter
    self.jobs.sum(:application_counter)
  end

  def last_company_profile_update_date
    last_items = Array.new
    last_company_photo = self.company_photos.order(:created_at).last
    last_company_video = self.company_videos.order(:created_at).last
    last_company_speech = self.company_speeches.order(:created_at).last

    last_items << last_company_photo.created_at if last_company_photo.present?
    last_items << last_company_video.created_at if last_company_video.present?
    last_items << last_company_speech.created_at if last_company_speech.present?

    last_items.sort! { |a,b|  DateTime.parse(a.to_s) <=> DateTime.parse(b.to_s) }.reverse
    last_items.reverse.first.strftime("%d/%m/%Y") if last_items.present?
  end

  def add_whatsapp_button_click
    self.whatsapp_button_counter += 1
  end
  def add_email_button_click
    self.email_button_counter += 1
  end
  def add_show_jobs_button_click
    self.show_jobs_counter += 1
  end

  private
    def tinify_photos #Compresses all images uploaded with paperclip. Must add "after_save :tinify_photos , if: Proc.new { |instance| instance.saved_change_to_´attachment_name´_updated_at?}"
      paths = [self.main_photo.path(:original), self.main_photo.path(:small), self.main_photo.path(:medium), self.main_photo.path(:large),
        self.logo.path(:original), self.logo.path(:thumbnail), self.logo.path(:small),
        self.cover_photo.path(:original), self.cover_photo.path(:thumbnail), self.cover_photo.path(:large),
        self.icon.path(:original), self.icon.path(:thumbnail), self.icon.path(:small)]
      TinifyToS3.perform_async(paths)
    end
end