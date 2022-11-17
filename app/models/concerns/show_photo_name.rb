module ShowPhotoName
    extend ActiveSupport::Concern
    include AbstractController::Translation
    def show_file_name_for(field:, numCharacters: 50)
        @field_string = field.to_s
        @field_file_name = @field_string + "_file_name"
        
        if self.send(field).present?
            if self.send(@field_file_name).size > numCharacters
                self.send(@field_file_name)[0,numCharacters-8] + "..." +  self.send(@field_file_name)[-8,8]
            else
                self.send(@field_file_name)
            end
        else
            I18n.t('.activerecord.attributes.select') + " " + (self.class).human_attribute_name(@field_string).downcase
        end
    end
end