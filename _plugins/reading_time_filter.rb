module ReadingTimeFilter
    include Liquid::StandardFilters
  
    def reading_time(input)
      # Get words count.
      total_words = get_plain_text(input).split.size
  
      # Load configuration.
      config = @context.registers[:site].config["reading_time"]
  
      # Setup default value.
      if ! config
        second_plural = "seconds"
        minute_singular = "minute"
        minute_plural = "minutes"
      else
        second_plural = config["second_plural"] ? config["second_plural"] : "seconds"
        minute_singular = config["minute_singular"] ? config["minute_singular"] : "minute"
        minute_plural = config["minute_plural"] ? config["minute_plural"] : "minutes"
      end
  
      # Average reading words per minute.
      words_per_minute = 100.0
  
      # Calculate reading time.
      case total_words
      when 0 .. words_per_minute / 2 - 1
        return "Less than 1 #{minute_singular}"
      when words_per_minute / 2 .. words_per_minute
        return "1 #{minute_singular}"
      else
        minutes = (total_words.to_f / words_per_minute).ceil
        return "#{minutes} #{minute_plural}";
      end
    end
  
    def get_plain_text(input)
      strip_html(input)
    end
  end
  
  Liquid::Template.register_filter(ReadingTimeFilter)