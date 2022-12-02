if Rails.env.development?
	ENV['DATABASE_USER'] = "pguser"
	ENV['DATABASE_PASSWORD'] = "pg"
	ENV['HOST'] = "127.0.0.1"
	ENV['MAIL_FROM'] = "federicoianamor@gmail.com"
	ENV['SITE_NAME'] = "Busca_trabajo"


	ENV['MAIL_SMTP'] = 'ewhweh'
	ENV['MAIL_USER'] = 'jejrej'
	ENV['MAIL_PASSWORD'] = 'warherh'


	ENV['COUNTRIES'] = 'AR'

	ENV['DEFAULT_COUNTRY'] = 'AR'

	ENV['HTTP_HOST'] = 'http://localhost:3000'

	ENV['HTTP_PROTOCOL'] = 'http'

	ENV['COMPANY_DEFAULT_NUMBER'] = '30'
	ENV['COMPANY_DEFAULT_ORDER'] = 'created_at'
	ENV['COMPANY_ORDER_COLUMNS'] = 'relevance,created_at'
	ENV['COMPANY_CONTROLLERS'] = 'companies'
	ENV['COMPANY_RECOMMENDATIONS'] = '4'
	ENV['COMPANIES_ACTIVE'] = "1"

	ENV['JOB_DEFAULT_NUMBER'] = '30'
	ENV['JOB_DEFAULT_ORDER'] = 'relevance'
	ENV['JOB_ORDER_COLUMNS'] = 'relevance,created_at'
	ENV['JOB_CONTROLLERS'] = 'jobs'
	ENV['JOB_RECOMMENDATIONS'] = '4'
	ENV['JOB_TECHNOLOGY_CATEGORY_ID'] = '4'
	ENV['JOBS_ACTIVE'] = "1"

	ENV['SEARCH_DEFAULT_NUMBER'] = '3'

	ENV['MAIL_ALERT_TO'] = 'federicoianamor@gmail.com'
	ENV['MAIL_ALERT_CC'] = ''

	ENV['TECHONOLOGY_INDUSTRY'] = '2'

	ENV['HOME_COMPANIES'] = '6'
	ENV['HOME_JOBS'] = '8'
	ENV['HOME_ADVICES'] = '6'
	ENV['HOME_COACHING'] = '3'

	ENV['COMPANY_FACEBOOK'] = 'true'
	ENV['COMPANY_TWITTER'] = 'true'
	ENV['COMPANY_LINKEDIN'] = 'true'
	ENV['ADMIN_PAGE_SIZE'] = '100'



	ENV['SOCIAL_NETWORK_FACEBOOK'] = 'false'
	ENV['SOCIAL_NETWORK_TWITTER'] = 'true'
	ENV['SOCIAL_NETWORK_LINKEDIN'] = 'true'
	ENV['SOCIAL_NETWORK_EMAIL'] = 'true'
	ENV['SOCIAL_NETWORK_WHATSAPP'] = 'true'

	ENV['COMPANIES_AUTO_ADMIN'] = '379,380'
 end
