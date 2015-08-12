module ApplicationHelper
    def register_flash_message(key,message)
        flash[key]=message
    end

    def display_flash_messages()
        render 'shared/flash_messages', :messages => flash
    end

    def display_flash_errors()
        render 'shared/error_messages'
    end
end
