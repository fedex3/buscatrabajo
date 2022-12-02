module FriendlyUrl
  extend ActiveSupport::Concern
  def friendly_url(text)
    text = text.gsub('.',' ').gsub(':',' ').gsub(';',' ').gsub('(',' ').gsub(')',' ').gsub(',',' ').gsub(' - ','-').gsub('  ',' ').gsub('/','-').gsub('¿','').gsub('?','').gsub('!','').gsub('¡','').gsub('%','').gsub('&','').gsub('$','').gsub('"','').gsub(' - ','').gsub(' ','-')
    text = text.mb_chars.unicode_normalize(:nfkd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
    text = text.parameterize(separator: '-')
    return text
  end
end