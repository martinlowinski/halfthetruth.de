module Jekyll
  # Sass plugin to convert .scss to .css
  # 
  # Note: This is configured to use the new css like syntax available in sass.
  require 'sass'
  class ScssConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /scss/i
    end

    def output_ext(ext)
      ".css"
    end

    def convert(content)
      begin
        puts "Performing Sass Conversion."
        # Without it the output is the default nested style, however you can
        # choose either :expanded, :compact or :compressed as per the Output
        # Style options from the sass reference page.
        engine = Sass::Engine.new(content, :syntax => :scss, :load_paths => ["./css/"], :style => :compressed)
        engine.render
      rescue StandardError => e
        puts "!!! SASS Error: " + e.message
      end
    end
  end
end
