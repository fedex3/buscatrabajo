class Job < ApplicationRecord
  include ShowPhotoName

  belongs_to :company, optional: true
  belongs_to :level, optional: true
  belongs_to :industry, optional: true
  has_many :job_countries
  has_many :job_states

  has_many :job_applications

  has_and_belongs_to_many(:recommended_jobs,
  :join_table => "recommended_jobs",
  :foreign_key => "job_id",
  :association_foreign_key => "recommended_job_id",
  :class_name => "Job")

  has_attached_file :photo, {
    default_url: ActionController::Base.helpers.asset_path("missing.webp"),
  	#url: "/system/projects/logos/:hash.:extension",
	  hash_secret: "longSecretString",
    :styles => {:thumbnail => "200x133",  :small => "400x266#"},
    :convert_options => { :thumbnail => "-gravity center -extent 200x133"} 
}

  process_in_background :photo, processing_image_url: "/images/:style/processing.webp"

  validates_attachment_content_type :photo, content_type: /\Aimage/
  validates_attachment_file_name :photo, matches: [/png\Z/i, /jpe?g\Z/i, /webp\Z/i]
  after_save :tinify_photos , if: Proc.new { |job| job.saved_change_to_photo_updated_at? && Rails.env.production?}

  validates :name, length: { minimum: 1, maximum: 100}
  validates :detail, length: { minimum: 1, maximum: 20000}
  validates :name_id, presence: true, :uniqueness => {case_sensitive: false, :scope => :company_id}
  validates :url, length: { minimum: 0, maximum: 500}
  validates :country, length: { presence: true, allow_blank: false}
  validates :views, numericality: { greater_than_or_equal_to: 0}
  validates :application_counter, numericality: { greater_than_or_equal_to: 0}
  validates :from_date, length: { presence: true, allow_blank: false}
  validates :end_date, length: { presence: true, allow_blank: false}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX }, if: :validate_email?

  before_validation :create_name_id
  before_validation :remove_email
  after_save :update_urls
  #after_create :update_order

  enum provider: %i[mibucle other avature greenhouse workday hiringroom publicis]

  scope :from_date, -> { where("date_trunc('day', jobs.from_date) <= ?", Date.today) }
  scope :end_date, -> { where("date_trunc('day', jobs.end_date) >= ?", Date.today) }
  scope :published, -> { where(published: true) }
  scope :active, -> { where(active: true) }
  scope :listable, -> { active.published.from_date.end_date}
  scope :company_listable, -> {  joins(:company).where("companies.active = true and companies.published = true and date_trunc('day', companies.from_date) <= ?", Date.today) }
  scope :company_listable_not_only_special_events, -> {  joins(:company).where("companies.active = true and companies.show_only_in_special_events = false and companies.published = true and date_trunc('day',companies.from_date) <= ?", Date.today) }
  scope :not_proactive_interview, -> { where.not(name: "Entrevistas proactivas" ) }
  scope :by_company_in_special_event, -> (special_event_code) { joins(:company).where("companies.id IN (?)", Company.joins(:company_special_events).where(company_special_events: { code: special_event_code }).ids) }
  scope :by_year, lambda { |year| where('extract(year from created_at) = ?', year) }

  scope :by_company, -> (company) { where company_id: company }
  scope :by_industry, -> (industry) { where industry_id: industry }
  scope :by_level, -> (level) { where level_id: level }
  scope :by_part_time, -> (part_time) { where part_time: part_time }
  scope :by_state, -> (state) { joins(:job_states).where('job_states.state_full_name = ?', state) }
  scope :by_country, -> (country) { joins(:job_countries).where('job_countries.country_alpha2 = ?', country) }
  scope :by_not_this_country, -> (country) { joins(:job_countries).where.not('job_countries.country_alpha2 = ?', country) }
  scope :by_remote, -> (remote) { where remote: remote }

  scope :by_q, -> (q) { joins(:industry, :company).where("lower(jobs.name) LIKE ? OR lower(jobs.detail) LIKE ? OR lower(jobs.state) LIKE ? OR lower(companies.name) LIKE ? OR lower(industries.name) LIKE ?", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%")}

  scope :default_order, -> { order(name: :asc) }
  scope :order_by_date, -> { order(created_at: :desc) }
  scope :order_by_relevance, -> { order(order: :asc) }
  scope :order_by_default, -> { order(order: :asc) }
  scope :order_by_name, -> { order(name: :asc) }

  scope :with_photo, -> { where.not(photo_url: ["missing.webp", nil] ) }
  scope :without_photo, -> { where(photo_url: ["missing.webp", nil]) }
  scope :get_and_order_by_ids, ->(ids) {
    order = sanitize_sql_array(
      ["position((',' || jobs.id::text || ',') in ?)", ids.join(',') + ',']
    )
    where(:id => ids).order(order)
  }

  class << self

		def update_order
			actual_order = 1


			companies_order = {}
			companies_queue = {}
			Company.packs.each do |pack|
				Job.joins(:company).listable.where("companies.pack = ?", pack.last).shuffle.each do |job|
					companies_order[job.company_id] = 0 unless companies_order.include?(job.company_id)
		      companies_order[job.company_id] += 1
		      if companies_order[job.company_id] == 1
						job.update(order: actual_order)
						actual_order += 1
					else
						companies_queue[job.company_id] = [] unless companies_queue.include?(job.company_id)
						companies_queue[job.company_id] << job.id
					end
				end
			end

			while companies_queue.keys.length > 0 do
				companies_queue.keys.each do |company_id|
					Job.find(companies_queue[company_id].shift).update(order: actual_order)
					companies_queue.delete(company_id) if companies_queue[company_id].length == 0
					actual_order += 1
				end
			end
		end

    def reorder_by_country_and_all_remotes(jobs:, locale: 'AR', order:)
      return [] if jobs.empty?
      jobs_ids = jobs.pluck(:id)
      field_order = order == 'created_at' ? 'created_at' : 'order'
      direct_order = order == 'created_at' ? 'desc' : 'asc'
      by_country_not_remote = self.where(id: jobs_ids).by_country(locale).by_remote([false, nil]).order("jobs.#{field_order} #{direct_order}").pluck(:id)
      by_country_remote = self.where(id: jobs_ids).by_country(locale).by_remote(true).order("jobs.#{field_order} #{direct_order}").pluck(:id)
      by_not_country_remote = self.where(id: jobs_ids).by_not_this_country(locale).by_remote(true).order("jobs.#{field_order} #{direct_order}").pluck(:id)
      by_not_country = self.where(id: jobs_ids).by_not_this_country(locale).by_remote([false, nil]).order("jobs.#{field_order} #{direct_order}").pluck(:id)
      new_order_jobs_ids = by_country_not_remote + by_country_remote + by_not_country_remote + by_not_country
      self.get_and_order_by_ids(new_order_jobs_ids)
    end
	end

	def id_name
		id.to_s + ' - ' + company.name + ' - ' + name
	end

	def validate_email?
		email.present?
	end

  def update_urls
    if photo(:small).to_s != photo_url
      self.update_column(:photo_url,photo(:small).to_s)
    end
  end

	def create_recommended_jobs
		return if !mibucle? && !other?
		calculate_recommended_jobs
	end

	def calculate_recommended_jobs
		recommendations = Set.new

    if company&.jobs.present?
      company.jobs.listable.order_by_date.limit(ENV['JOB_RECOMMENDATIONS'].to_i + 1).each do |recommended_job|
        recommendations << recommended_job
      end
    end

		#Si no llegue al numero, completo con las mas nuevas
		if recommendations.size <= ENV['JOB_RECOMMENDATIONS'].to_i  && company.active
			Job.company_listable.listable.order_by_date.limit(ENV['JOB_RECOMMENDATIONS'].to_i + 1).each do |recommended_job|
				unless recommendations.include?(recommended_job)
					recommendations << recommended_job
				end
			end
		end

		self.recommended_jobs.destroy_all
		self.recommended_jobs << (recommendations - [self]).take(ENV['JOB_RECOMMENDATIONS'].to_i)
	end

	def create_name_id
		self.name_id = Url.friendly(name) if publicis_id.blank?
	end

  def increment_counter
    self.update_column(:application_counter, application_counter + 1)
  end

  def update_order
  	return if !mibucle? && !other?
  	Job.update_order
  end

  def listable
    published && active && Time.current.between?(from_date, end_date)
  end

  def remove_email
		emails = detail.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i)
		emails.each do |email|
			self.detail = self.detail.gsub(email,'')
		end
  end

  def self.recommended_jobs(locale)
    jobs = Job.company_listable_not_only_special_events.listable.joins(:company).preload(:company, :level, :industry).select("jobs.level_id, jobs.active, jobs.updated_at, jobs.industry_id, jobs.part_time, jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.state, jobs.country, jobs.remote")
    jobs = jobs.with_photo.by_country(locale).last(6)
  end

  private
    def tinify_photos #Compresses all images uploaded with paperclip. Must add "after_save :tinify_photos , if: Proc.new { |instance| instance.saved_change_to_´attachment_name´_updated_at?}"
      paths = [self.photo.path(:original), self.photo.path(:thumbnail), self.photo.path(:small)]
      TinifyToS3.perform_async(paths)
    end
end
