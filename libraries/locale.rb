module Locale
  class << self
    def up_to_date?(file_path, lang_settings)
      locale = IO.read(file_path)
      lang_settings.all? { |lang|
        locale.include?(lang)
      }
    end
  end
end
